<script setup lang="ts">
/**
 * WatcherPriceStatus - Displays last price, trend, and time ago
 */
import { PriceDisplay } from '../display'

defineProps<{
  lastPrice: number | null
  targetPrice: number
  currency: string
  isPriceBelowTarget: boolean
  trend: { direction: 'up' | 'down' | 'stable', percent: number }
  lastCheckedAgo: string
}>()
</script>

<template>
  <!-- Price Status -->
  <div 
    v-if="lastPrice !== null" 
    class="p-3 rounded-xl bg-white/5 mb-4"
  >
    <div class="flex items-center justify-between">
      <div>
        <div class="text-xs text-white/50 mb-1">📊 Last price</div>
        <PriceDisplay 
          :price="lastPrice" 
          :currency="currency" 
          size="lg"
          :highlight="isPriceBelowTarget"
        />
      </div>
      <div class="text-right">
        <div class="text-xs text-white/50 mb-1">{{ lastCheckedAgo }}</div>
        <div 
          class="flex items-center gap-1 text-sm font-medium"
          :class="{
            'text-green-400': trend.direction === 'down',
            'text-red-400': trend.direction === 'up',
            'text-white/50': trend.direction === 'stable'
          }"
        >
          <span v-if="trend.direction === 'down'">📉 ↓</span>
          <span v-else-if="trend.direction === 'up'">📈 ↑</span>
          <span v-else>─</span>
          {{ trend.percent.toFixed(1) }}%
        </div>
      </div>
    </div>
  </div>

  <!-- No data yet -->
  <div 
    v-else 
    class="p-3 rounded-xl bg-white/5 mb-4 text-center text-white/50 text-sm"
  >
    ⏳ Waiting for first check...
  </div>
</template>
