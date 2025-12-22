<script lang="ts">
	import { ArcaneButton } from '$lib/components/arcane-button/index.js';
	import * as DropdownMenu from '$lib/components/ui/dropdown-menu/index.js';
	import HeaderCard from '$lib/components/header-card.svelte';
	import StatCard from '$lib/components/stat-card.svelte';
	import type { Snippet } from 'svelte';
	import type { Action } from '$lib/components/arcane-button/index.js';
	import { EllipsisIcon, type IconType } from '$lib/icons';

	export interface ActionButton {
		id: string;
		action: Action;
		label: string;
		loadingLabel?: string;
		loading?: boolean;
		disabled?: boolean;
		onclick: () => void;
		showOnMobile?: boolean;
	}

	export interface StatCardConfig {
		title: string;
		value: string | number;
		subtitle?: string;
		icon: IconType;
		iconColor?: string;
		bgColor?: string;
		class?: string;
	}

	interface Props {
		title: string;
		subtitle?: string;
		icon?: IconType;
		actionButtons?: ActionButton[];
		statCards?: StatCardConfig[];
		mainContent: Snippet;
		additionalContent?: Snippet;
		class?: string;
		containerClass?: string;
	}

	let {
		title,
		subtitle,
		icon: Icon,
		actionButtons = [],
		statCards = [],
		mainContent,
		additionalContent,
		class: className = '',
		containerClass = 'space-y-8 pb-5 md:space-y-10 md:pb-5'
	}: Props = $props();

	const firstButton = $derived(actionButtons[0]);
	const restButtons = $derived(actionButtons.slice(1));
</script>

<div class="{containerClass} {className}">
	<HeaderCard>
		<div class="flex items-center justify-between gap-4">
			<div class="flex flex-1 items-center gap-3 sm:gap-4">
				{#if Icon}
					<div
						class="bg-primary/10 text-primary ring-primary/20 flex size-8 shrink-0 items-center justify-center rounded-lg ring-1 sm:size-10"
					>
						<Icon class="size-4 sm:size-5" />
					</div>
				{/if}
				<div class="min-w-0">
					<h1 class="text-3xl font-bold tracking-tight">{title}</h1>
					{#if subtitle}
						<p class="text-muted-foreground mt-1 text-sm sm:text-base">{subtitle}</p>
					{/if}
				</div>
			</div>

			{#if statCards && statCards.length > 0}
				<div class="hidden flex-1 items-center justify-center md:flex">
					<div class="border-border/50 relative overflow-hidden rounded-full border">
						<div class="bg-muted/50 absolute inset-0"></div>
						<div class="relative flex items-center gap-4 px-4 py-1.5 backdrop-blur-md">
							{#each statCards as card, i}
								{#if i > 0}
									<div class="bg-border/50 h-4 w-px"></div>
								{/if}
								<StatCard
									variant="mini"
									title={card.title}
									value={card.value}
									icon={card.icon}
									iconColor={card.iconColor}
									class={card.class}
								/>
							{/each}
						</div>
					</div>
				</div>
			{/if}

			<div class="flex flex-1 items-center justify-end gap-2">
				{#if actionButtons.length > 0}
					<!-- LG: Show all buttons -->
					<div class="hidden lg:flex items-center gap-2">
						{#each actionButtons as button (button.id)}
							<ArcaneButton
								action={button.action}
								customLabel={button.label}
								loadingLabel={button.loadingLabel}
								loading={button.loading}
								disabled={button.disabled}
								onclick={button.onclick}
								size="sm"
							/>
						{/each}
					</div>

					<!-- MD & SM: Show first button + dropdown for rest -->
					<div class="flex lg:hidden items-center gap-2">
						{#if firstButton}
							<ArcaneButton
								action={firstButton.action}
								customLabel={firstButton.label}
								loadingLabel={firstButton.loadingLabel}
								loading={firstButton.loading}
								disabled={firstButton.disabled}
								onclick={firstButton.onclick}
								size="sm"
							/>
						{/if}

						{#if restButtons.length > 0}
							<DropdownMenu.Root>
								<DropdownMenu.Trigger>
									{#snippet child({ props })}
										<ArcaneButton {...props} action="base" tone="outline" size="icon" class="size-8 shrink-0">
											<span class="sr-only">More actions</span>
											<EllipsisIcon class="size-4" />
										</ArcaneButton>
									{/snippet}
								</DropdownMenu.Trigger>

								<DropdownMenu.Content align="end" class="min-w-[160px]">
									<DropdownMenu.Group>
										{#each restButtons as button (button.id)}
											<DropdownMenu.Item onclick={button.onclick} disabled={button.disabled || button.loading}>
												{button.loading ? button.loadingLabel || button.label : button.label}
											</DropdownMenu.Item>
										{/each}
									</DropdownMenu.Group>
								</DropdownMenu.Content>
							</DropdownMenu.Root>
						{/if}
					</div>
				{/if}
			</div>
		</div>
	</HeaderCard>

	{@render mainContent()}

	{#if additionalContent}
		{@render additionalContent()}
	{/if}
</div>
