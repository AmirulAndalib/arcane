<script lang="ts">
	import * as Tabs from '#lib/components/ui/tabs';
	import * as Dialog from '#lib/components/ui/dialog';
	import { ArcaneButton } from '#lib/components/arcane-button/index.js';
	import { toast } from 'svelte-sonner';
	import { getContext, onMount } from 'svelte';
	import { SettingsPageLayout } from '#lib/layouts';
	import settingsStore from '#lib/stores/config-store';
	import { m } from '#lib/paraglide/messages';
	import { useUrlTab } from '#lib/hooks/use-url-tab.svelte';
	import { notificationService } from '#lib/services/notification-service';
	import { type NotificationProviderKey, NOTIFICATION_PROVIDER_KEYS } from '#lib/types/notifications';
	import { NotificationsIcon } from '#lib/icons';
	import { TabBar, type TabItem } from '#lib/components/tab-bar';
	import { BuiltInProviderForm } from './providers';
	import {
		cloneNotificationProviderFormState,
		createNotificationProviderFormState,
		createNotificationSettingsByProvider,
		getNotificationProviderDefinition,
		notificationProviderFormValuesToSettings,
		type NotificationProviderFormState,
		type NotificationSettingsByProvider,
		updateNotificationProviderFormState
	} from '#lib/utils/notification-providers';
	import { extractApiErrorMessage } from '#lib/utils/api';

	let { data } = $props();

	// UI state
	let isLoading = $state(false);
	let isTesting = $state(false);
	let showUnsavedDialog = $state(false);
	let pendingTestAction: (() => Promise<void>) | null = $state(null);
	const urlTab = useUrlTab<NotificationProviderKey>({
		validTabs: () => NOTIFICATION_PROVIDER_KEYS,
		defaultTab: () => 'email'
	});
	const providerTab = $derived(urlTab.value);
	const providerTabItems = NOTIFICATION_PROVIDER_KEYS.map(
		(provider) =>
			({
				value: provider,
				label: getNotificationProviderDefinition(provider).label()
			}) satisfies TabItem
	);

	const isReadOnly = $derived.by(() => $settingsStore.uiConfigDisabled);

	type SettingsFormState = {
		hasChanges: boolean;
		isLoading: boolean;
		saveFunction: (() => Promise<void>) | null;
		resetFunction: (() => void) | null;
	};
	type ProviderFormRef = { isValid: () => boolean };

	const formState = getContext<SettingsFormState | undefined>('settingsFormState');
	let providerFormRefs = $state<Partial<Record<NotificationProviderKey, ProviderFormRef>>>({});
	let savedSettings = $state<NotificationSettingsByProvider>(createNotificationSettingsByProvider());
	let providerValues = $state<NotificationProviderFormState>(createNotificationProviderFormState());
	let providerBaselines = $state<NotificationProviderFormState>(createNotificationProviderFormState());
	const changedProviders = $derived.by(() =>
		NOTIFICATION_PROVIDER_KEYS.filter(
			(provider) => JSON.stringify(providerValues[provider]) !== JSON.stringify(providerBaselines[provider])
		)
	);
	const hasChanges = $derived(changedProviders.length > 0);

	function hasSavedCredential(settings: NotificationSettingsByProvider[NotificationProviderKey], field: string) {
		return settings?.config ? Object.prototype.hasOwnProperty.call(settings.config, field) : false;
	}

	// Sync with settings form context
	$effect(() => {
		if (formState) {
			formState.hasChanges = hasChanges;
			formState.isLoading = isLoading;
			formState.saveFunction = onSubmit;
			formState.resetFunction = resetForm;
		}
	});

	onMount(() => {
		savedSettings = createNotificationSettingsByProvider(data?.notificationSettings ?? []);
		providerValues = createNotificationProviderFormState(savedSettings);
		providerBaselines = cloneNotificationProviderFormState(providerValues);
	});

	async function onSubmit() {
		if (NOTIFICATION_PROVIDER_KEYS.some((provider) => providerFormRefs[provider]?.isValid() === false)) {
			toast.error(m.common_form_errors());
			return;
		}

		isLoading = true;

		try {
			const errors: string[] = [];
			for (const provider of changedProviders) {
				try {
					const settings = notificationProviderFormValuesToSettings(provider, providerValues[provider]);
					const saved = await notificationService.updateSettings(provider, settings);
					savedSettings = { ...savedSettings, [provider]: saved };
					providerBaselines = updateNotificationProviderFormState(providerBaselines, provider, providerValues[provider]);
				} catch (error) {
					errors.push(
						m.notifications_saved_failed({
							provider: getNotificationProviderDefinition(provider).label(),
							error: extractApiErrorMessage(error)
						})
					);
				}
			}

			if (errors.length === 0) {
				toast.success(m.general_settings_saved());
			} else {
				errors.forEach((err) => toast.error(err));
			}
		} catch (error) {
			console.error('Error saving notification settings:', error);
			toast.error(m.settings_notifications_save_error());
		} finally {
			isLoading = false;
		}
	}

	function resetForm() {
		providerValues = cloneNotificationProviderFormState(providerBaselines);
	}

	async function testNotification(provider: NotificationProviderKey, testType: string = 'simple') {
		if (hasChanges) {
			pendingTestAction = () => executeTest(provider, testType);
			showUnsavedDialog = true;
			return;
		}
		await executeTest(provider, testType);
	}

	async function executeTest(provider: NotificationProviderKey, testType: string = 'simple') {
		isTesting = true;
		try {
			const result = await notificationService.testNotification(provider, testType);
			if (result?.data?.warning) {
				toast.warning(m.notifications_test_warning({ warning: result.data.warning }));
			} else {
				toast.success(m.notifications_test_success({ provider: getNotificationProviderDefinition(provider).label() }));
			}
		} catch (error) {
			toast.error(m.notifications_test_failed({ error: extractApiErrorMessage(error) }));
		} finally {
			isTesting = false;
		}
	}

	async function handleSaveAndTest() {
		showUnsavedDialog = false;
		await onSubmit();
		if (pendingTestAction) {
			await pendingTestAction();
			pendingTestAction = null;
		}
	}
</script>

<SettingsPageLayout
	title={m.notifications_title()}
	description={m.notifications_description()}
	icon={NotificationsIcon}
	pageType="form"
	showReadOnlyTag={isReadOnly}
>
	{#snippet mainContent()}
		<fieldset disabled={isReadOnly} class="relative w-full min-w-0">
			<Tabs.Root value={providerTab} class="flex min-h-0 w-full min-w-0 flex-col">
				<TabBar items={providerTabItems} value={providerTab} onValueChange={urlTab.select} class="self-start" />

				{#each NOTIFICATION_PROVIDER_KEYS as provider (provider)}
					<Tabs.Content value={provider} class="mt-4 space-y-4">
						<BuiltInProviderForm
							bind:this={providerFormRefs[provider]}
							{provider}
							bind:values={providerValues[provider]}
							disabled={isReadOnly}
							{isTesting}
							hasExistingCredentials={savedSettings[provider] !== null}
							hasExistingPassword={provider === 'signal' && hasSavedCredential(savedSettings.signal, 'password')}
							hasExistingToken={provider === 'signal' && hasSavedCredential(savedSettings.signal, 'token')}
							onTest={(testType) => testNotification(provider, testType)}
						/>
					</Tabs.Content>
				{/each}
			</Tabs.Root>
		</fieldset>
	{/snippet}
</SettingsPageLayout>

<Dialog.Root bind:open={showUnsavedDialog}>
	<Dialog.Content>
		<Dialog.Header>
			<Dialog.Title>{m.notifications_unsaved_changes_title()}</Dialog.Title>
			<Dialog.Description>
				{m.notifications_unsaved_changes_description()}
			</Dialog.Description>
		</Dialog.Header>
		<Dialog.Footer>
			<ArcaneButton action="cancel" onclick={() => (showUnsavedDialog = false)} />
			<ArcaneButton action="confirm" onclick={handleSaveAndTest} customLabel={m.notifications_unsaved_changes_save_and_test()} />
		</Dialog.Footer>
	</Dialog.Content>
</Dialog.Root>
