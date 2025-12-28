<script setup lang="ts">
/**
 * FlightSimpleView - Simple grid view for direct flights without segment details
 */
import { formatDuration, formatTime } from '../../composables'

defineProps<{
  airline: string | null
  airlineCode: string | null
  stops: number
  duration: string | number | null
  departureAt: string | null
}>()
</script>

<template>
  <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
    <div class="bg-white/[0.04] backdrop-blur-md p-4 rounded-xl border border-white/[0.08]">
      <span class="block text-[13px] text-white/50 mb-1">{{ $t('results.airline') }}</span>
      <span class="text-[17px] font-semibold">{{ airline || airlineCode || 'N/A' }}</span>
    </div>
    <div class="bg-white/[0.04] backdrop-blur-md p-4 rounded-xl border border-white/[0.08]">
      <span class="block text-[13px] text-white/50 mb-1">{{ $t('results.stops') }}</span>
      <span class="text-[17px] font-semibold">{{ stops === 0 ? $t('results.direct') : $t('results.stop_count', { count: stops }, stops) }}</span>
    </div>
    <div class="bg-white/[0.04] backdrop-blur-md p-4 rounded-xl border border-white/[0.08]">
      <span class="block text-[13px] text-white/50 mb-1">{{ $t('results.duration') }}</span>
      <span class="text-[17px] font-semibold">{{ formatDuration(duration) }}</span>
    </div>
    <div class="bg-white/[0.04] backdrop-blur-md p-4 rounded-xl border border-white/[0.08]">
      <span class="block text-[13px] text-white/50 mb-1">{{ $t('results.departure') }}</span>
      <span class="text-[17px] font-semibold">{{ formatTime(departureAt) }}</span>
    </div>
  </div>
</template>
