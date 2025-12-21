<script lang="ts">
	import { z } from 'zod/v4';
	import { toast } from 'svelte-sonner';
	import settingsStore from '$lib/stores/config-store';
	import { m } from '$lib/paraglide/messages';
	import { navigationSettingsOverridesStore, resetNavigationVisibility } from '$lib/utils/navigation.utils';
	import { SettingsPageLayout } from '$lib/layouts';
	import { Switch } from '$lib/components/ui/switch/index.js';
	import { useSidebar } from '$lib/components/ui/sidebar/context.svelte.js';
	import { createSettingsForm } from '$lib/utils/settings-form.util';
	import { Separator } from '$lib/components/ui/separator';
	import { Label } from '$lib/components/ui/label';
	import AccentColorPicker from '$lib/components/accent-color/accent-color-picker.svelte';
	import { applyAccentColor } from '$lib/utils/accent-color-util';
	import { ApperanceIcon, MonitorSpeakerIcon, DockIcon, EnvironmentsIcon, SmartphoneIcon } from '$lib/icons';

	let { data } = $props();
	const currentSettings = $derived($settingsStore || data.settings!);
	const isReadOnly = $derived.by(() => $settingsStore?.uiConfigDisabled);

	const formSchema = z.object({
		mobileNavigationMode: z.enum(['floating', 'docked']),
		mobileNavigationShowLabels: z.boolean(),
		sidebarHoverExpansion: z.boolean(),
		accentColor: z.string(),
		glassEffectEnabled: z.boolean(),
		enableGravatar: z.boolean()
	});

	// Track local override state using the shared store
	let persistedState = $state(navigationSettingsOverridesStore.current);

	// Sidebar context is only available in desktop view
	let sidebar: ReturnType<typeof useSidebar> | null = null;
	try {
		sidebar = useSidebar();
	} catch {
		// Sidebar context not available (mobile view)
	}

	let { formInputs } = $derived(
		createSettingsForm({
			schema: formSchema,
			currentSettings,
			getCurrentSettings: () => $settingsStore || data.settings!,
			successMessage: m.navigation_settings_saved(),
			onReset: () => applyAccentColor(currentSettings.accentColor)
		})
	);

	function setLocalOverride(key: 'mode' | 'showLabels', value: any) {
		const currentOverrides = navigationSettingsOverridesStore.current;
		navigationSettingsOverridesStore.current = { ...currentOverrides, [key]: value };
		persistedState = navigationSettingsOverridesStore.current;
		if (key === 'mode') resetNavigationVisibility();
	}

	function clearLocalOverride(key: 'mode' | 'showLabels') {
		const currentOverrides = navigationSettingsOverridesStore.current;
		const newOverrides = { ...currentOverrides };
		delete newOverrides[key];
		navigationSettingsOverridesStore.current = newOverrides;
		persistedState = navigationSettingsOverridesStore.current;
		if (key === 'mode') resetNavigationVisibility();
		toast.success(m.clear_local_override());
	}

	// Navigation Mode state
	const modeHasOverride = $derived(persistedState.mode !== undefined);
	let modeScopeInternal = $state<'server' | 'local' | null>(null);
	const modeScope = $derived(modeScopeInternal ?? (modeHasOverride ? 'local' : 'server'));
	const modeDisplayValue = $derived(modeScope === 'local' ? persistedState.mode : $formInputs.mobileNavigationMode.value);

	$effect(() => {
		if (!modeHasOverride && modeScopeInternal === 'local') {
			modeScopeInternal = 'server';
		}
	});

	function handleModeSelect(mode: 'floating' | 'docked') {
		if (modeScope === 'local') {
			setLocalOverride('mode', mode);
		} else {
			$formInputs.mobileNavigationMode.value = mode;
		}
	}

	function handleModeScopeChange(newScope: 'server' | 'local') {
		if (newScope === 'local' && !modeHasOverride) {
			setLocalOverride('mode', $formInputs.mobileNavigationMode.value);
		} else if (newScope === 'server' && modeHasOverride) {
			clearLocalOverride('mode');
		}
		modeScopeInternal = newScope;
	}

	// Show Labels state
	const labelsHasOverride = $derived(persistedState.showLabels !== undefined);
	let labelsScopeInternal = $state<'server' | 'local' | null>(null);
	const labelsScope = $derived(labelsScopeInternal ?? (labelsHasOverride ? 'local' : 'server'));
	const labelsDisplayValue = $derived(labelsScope === 'local' ? persistedState.showLabels : $formInputs.mobileNavigationShowLabels.value);

	$effect(() => {
		if (!labelsHasOverride && labelsScopeInternal === 'local') {
			labelsScopeInternal = 'server';
		}
	});

	function handleLabelsChange(checked: boolean) {
		if (labelsScope === 'local') {
			setLocalOverride('showLabels', checked);
		} else {
			$formInputs.mobileNavigationShowLabels.value = checked;
		}
	}

	function handleLabelsScopeChange(newScope: 'server' | 'local') {
		if (newScope === 'local' && !labelsHasOverride) {
			// Create override with current server value
			setLocalOverride('showLabels', $formInputs.mobileNavigationShowLabels.value);
		} else if (newScope === 'server' && labelsHasOverride) {
			clearLocalOverride('showLabels');
		}
		labelsScopeInternal = newScope;
	}
</script>

{#snippet scopeToggle(scope: 'server' | 'local', onScopeChange: (s: 'server' | 'local') => void, serverDisabled: boolean)}
	<div class="bg-muted/50 inline-flex rounded-md p-0.5 text-xs">
		<button
			type="button"
			onclick={() => onScopeChange('server')}
			disabled={serverDisabled}
			class="flex items-center gap-1.5 rounded px-2 py-1 transition-all duration-150 {scope === 'server'
				? 'bg-background text-foreground shadow-sm'
				: 'text-muted-foreground hover:text-foreground'} {serverDisabled ? 'cursor-not-allowed opacity-50' : ''}"
		>
			<EnvironmentsIcon class="size-3" />
			<span>{m.server_default()}</span>
		</button>
		<button
			type="button"
			onclick={() => onScopeChange('local')}
			class="flex items-center gap-1.5 rounded px-2 py-1 transition-all duration-150 {scope === 'local'
				? 'bg-background text-foreground shadow-sm'
				: 'text-muted-foreground hover:text-foreground'}"
		>
			<SmartphoneIcon class="size-3" />
			<span>{m.this_device()}</span>
		</button>
	</div>
{/snippet}

<SettingsPageLayout
	title={m.appearance_title()}
	description={m.appearance_description()}
	icon={ApperanceIcon}
	pageType="form"
	showReadOnlyTag={isReadOnly}
>
	{#snippet mainContent()}
		<div class="space-y-8">
			<!-- Appearance Section -->
			<div class="space-y-4">
				<h3 class="text-lg font-medium">{m.appearance_title()}</h3>
				<div class="bg-card rounded-lg border shadow-sm">
					<div class="space-y-6 p-6">
						<!-- Accent Color -->
						<div class="grid gap-4 md:grid-cols-[1fr_1.5fr] md:gap-8">
							<div>
								<Label class="text-base">{m.accent_color()}</Label>
								<p class="text-muted-foreground mt-1 text-sm">{m.accent_color_description()}</p>
							</div>
							<div>
								<AccentColorPicker
									previousColor={currentSettings.accentColor}
									bind:selectedColor={$formInputs.accentColor.value}
									disabled={isReadOnly}
								/>
							</div>
						</div>

						<Separator />

						<!-- Glass Effect -->
						<div class="grid gap-4 md:grid-cols-[1fr_1.5fr] md:gap-8">
							<div>
								<Label class="text-base">{m.glass_effect_title()}</Label>
								<p class="text-muted-foreground mt-1 text-sm">{m.glass_effect_description()}</p>
							</div>
							<div class="flex items-center gap-2">
								<Switch
									id="glassEffectEnabled"
									bind:checked={$formInputs.glassEffectEnabled.value}
									disabled={isReadOnly}
									onCheckedChange={(checked) => {
										$formInputs.glassEffectEnabled.value = checked;
									}}
								/>
								<Label for="glassEffectEnabled" class="font-normal">
									{$formInputs.glassEffectEnabled.value ? m.glass_effect_enabled() : m.glass_effect_disabled()}
								</Label>
							</div>
						</div>

						<Separator />

						<!-- User Avatars -->
						<div class="grid gap-4 md:grid-cols-[1fr_1.5fr] md:gap-8">
							<div>
								<Label class="text-base">{m.general_user_avatars_heading()}</Label>
								<p class="text-muted-foreground mt-1 text-sm">{m.general_user_avatars_description()}</p>
							</div>
							<div class="flex items-center gap-2">
								<Switch
									id="enableGravatar"
									bind:checked={$formInputs.enableGravatar.value}
									disabled={isReadOnly}
									onCheckedChange={(checked) => {
										$formInputs.enableGravatar.value = checked;
									}}
								/>
								<Label for="enableGravatar" class="font-normal">
									{m.general_enable_gravatar_label()}
								</Label>
							</div>
						</div>
					</div>
				</div>
			</div>

			<!-- Desktop Sidebar Section -->
			<div class="space-y-4">
				<h3 class="text-lg font-medium">{m.navigation_desktop_sidebar_title()}</h3>
				<div class="bg-card rounded-lg border shadow-sm">
					<div class="space-y-6 p-6">
						<div class="grid gap-4 md:grid-cols-[1fr_1.5fr] md:gap-8">
							<div>
								<Label class="text-base">{m.navigation_sidebar_hover_expansion_label()}</Label>
								<p class="text-muted-foreground mt-1 text-sm">{m.navigation_sidebar_hover_expansion_description()}</p>
							</div>
							<div class="flex items-center gap-2">
								<Switch
									id="sidebarHoverExpansion"
									checked={$formInputs.sidebarHoverExpansion.value}
									disabled={isReadOnly}
									onCheckedChange={(checked) => {
										$formInputs.sidebarHoverExpansion.value = checked;
										if (sidebar) {
											sidebar.setHoverExpansion(checked);
										}
									}}
								/>
								<Label for="sidebarHoverExpansion" class="font-normal">
									{$formInputs.sidebarHoverExpansion.value
										? m.navigation_sidebar_hover_expansion_enabled()
										: m.navigation_sidebar_hover_expansion_disabled()}
								</Label>
							</div>
						</div>
					</div>
				</div>
			</div>

			<!-- Mobile Appearance Section -->
			<div class="space-y-4">
				<h3 class="text-lg font-medium">{m.navigation_mobile_appearance_title()}</h3>
				<div class="bg-card rounded-lg border shadow-sm">
					<div class="space-y-6 p-6">
						<!-- Navigation Mode -->
						<div class="grid gap-4 md:grid-cols-[1fr_1.5fr] md:gap-8">
							<div>
								<Label class="text-base">{m.navigation_mode_label()}</Label>
								<p class="text-muted-foreground mt-1 text-sm">{m.navigation_mode_description()}</p>
							</div>
							<div class="space-y-3">
								{@render scopeToggle(modeScope, handleModeScopeChange, isReadOnly)}

								<!-- Segmented Control -->
								<div class="bg-muted/50 relative flex rounded-lg p-1">
									<div
										class="bg-background absolute top-1 bottom-1 rounded-md shadow-sm transition-all duration-200 ease-out"
										style="width: calc(50% - 4px); left: {modeDisplayValue === 'floating' ? '4px' : 'calc(50% + 0px)'};"
									></div>

									<button
										type="button"
										onclick={() => handleModeSelect('floating')}
										class="relative z-10 flex flex-1 items-center justify-center gap-2 rounded-md px-3 py-2.5 text-sm font-medium transition-colors duration-150 {modeDisplayValue ===
										'floating'
											? 'text-foreground'
											: 'text-muted-foreground hover:text-foreground/80'}"
									>
										<MonitorSpeakerIcon class="size-4" />
										<span>{m.navigation_mode_floating()}</span>
									</button>

									<button
										type="button"
										onclick={() => handleModeSelect('docked')}
										class="relative z-10 flex flex-1 items-center justify-center gap-2 rounded-md px-3 py-2.5 text-sm font-medium transition-colors duration-150 {modeDisplayValue ===
										'docked'
											? 'text-foreground'
											: 'text-muted-foreground hover:text-foreground/80'}"
									>
										<DockIcon class="size-4" />
										<span>{m.navigation_mode_docked()}</span>
									</button>
								</div>
							</div>
						</div>

						<Separator />

						<!-- Show Labels -->
						<div class="grid gap-4 md:grid-cols-[1fr_1.5fr] md:gap-8">
							<div>
								<Label class="text-base">{m.navigation_show_labels_label()}</Label>
								<p class="text-muted-foreground mt-1 text-sm">{m.navigation_show_labels_description()}</p>
							</div>
							<div class="space-y-3">
								{@render scopeToggle(labelsScope, handleLabelsScopeChange, isReadOnly)}

								<div class="flex items-center gap-3">
									<Switch id="mobileNavigationShowLabels" checked={labelsDisplayValue} onCheckedChange={handleLabelsChange} />
									<span class="text-sm font-medium">
										{labelsDisplayValue ? m.on() : m.off()}
									</span>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	{/snippet}
</SettingsPageLayout>
