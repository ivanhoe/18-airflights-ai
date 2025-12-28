<script setup lang="ts">
/**
 * FlightPriceHeader - Displays price, duration, and stops for a flight offer
 */
import { PriceDisplay } from '../display'
import { formatDuration } from '../../composables'

defineProps<{
  price: number
  currency: string
  duration: string | number | null
  stops: number
  isFirst?: boolean
}>()
</script>

<template>
  <div :class="[
    'rounded-2xl p-4 border mb-4 backdrop-blur-md transition-all duration-200',
    isFirst
      ? 'bg-gradient-to-br from-emerald-500/20 to-green-500/20 border-emerald-500/30'
      : 'bg-white/[0.04] border-white/[0.08]'
  ]">
    <div class="flex items-start justify-between">
      <div>
        <PriceDisplay :price="price" :currency="currency" size="xl" highlight />
        <div class="text-[13px] text-green-300/80 mt-1">{{ currency }} {{ $t('results.total') }}</div>
      </div>

      <div class="text-right">
        <div class="text-lg font-semibold">{{ formatDuration(duration) }}</div>
        <div class="text-[13px] text-violet-300 mt-1">
          {{ stops === 0 ? $t('results.direct') : $t('results.stop_count', { count: stops }, stops) }}
        </div>
      </div>
    </div>
  </div>
</template>
