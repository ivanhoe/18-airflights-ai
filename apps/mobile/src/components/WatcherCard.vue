<script setup lang="ts">
/**
 * WatcherCard - Displays a price watcher with status and actions
 * Composed of: WatcherHeader, WatcherPriceStatus, WatcherActions
 */
import type { PriceWatcher } from '../composables/usePriceWatcher'
import { PriceDisplay } from './display'
import { WatcherHeader, WatcherPriceStatus, WatcherActions } from './watcher'
import { formatDate } from '../composables'

defineProps<{
  watcher: PriceWatcher
  isPriceBelowTarget: boolean
  trend: { direction: 'up' | 'down' | 'stable', percent: number }
  lastCheckedAgo: string
}>()

const emit = defineEmits<{
  (e: 'toggle', id: string): void
  (e: 'delete', id: string): void
  (e: 'viewHistory', watcher: PriceWatcher): void
}>()
</script>

<template>
  <div 
    class="card transition-all duration-300"
    :class="{
      'border-green-500/30 bg-green-500/5': isPriceBelowTarget,
      'opacity-60': !watcher.isActive
    }"
  >
    <!-- Header: Route + Status -->
    <WatcherHeader
      :origin="watcher.origin"
      :destination="watcher.destination"
      :is-active="watcher.isActive"
      :is-price-below-target="isPriceBelowTarget"
    />

    <!-- Info Grid -->
    <div class="grid grid-cols-2 gap-3 text-sm mb-4">
      <div class="flex items-center gap-2 text-white/70">
        <span>📅</span>
        <span>{{ formatDate(watcher.travelDate) }}</span>
      </div>
      <div class="flex items-center gap-2 text-white/70">
        <span>🎯</span>
        <span>Meta: <PriceDisplay :price="watcher.targetPrice" :currency="watcher.currency" size="sm" /></span>
      </div>
    </div>

    <!-- Price Status -->
    <WatcherPriceStatus
      :last-price="watcher.lastPrice"
      :target-price="watcher.targetPrice"
      :currency="watcher.currency"
      :is-price-below-target="isPriceBelowTarget"
      :trend="trend"
      :last-checked-ago="lastCheckedAgo"
    />

    <!-- Actions -->
    <WatcherActions
      :is-active="watcher.isActive"
      @view-history="emit('viewHistory', watcher)"
      @toggle="emit('toggle', watcher.id)"
      @delete="emit('delete', watcher.id)"
    />
  </div>
</template>
