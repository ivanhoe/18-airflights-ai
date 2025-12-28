<script setup lang="ts">
/**
 * FlightSegment - Displays a single flight segment with airline, route, and class info
 */
import { formatDuration, formatTime, formatShortDate } from '../../composables'

interface Airport {
  id?: string
  time?: string
}

interface Segment {
  airline?: string
  airline_logo?: string
  flight_number?: string
  airplane?: string
  departure_airport?: Airport
  arrival_airport?: Airport
  duration?: string | number
  travel_class?: string
  legroom?: string
}

defineProps<{
  segment: Segment
}>()
</script>

<template>
  <div class="bg-white/[0.04] backdrop-blur-md rounded-2xl p-4 border border-white/[0.08]">
    <!-- Airline Header -->
    <div class="flex items-center gap-3 mb-4">
      <img
        v-if="segment.airline_logo"
        :src="segment.airline_logo"
        :alt="segment.airline"
        class="w-10 h-10 rounded-lg"
      />
      <div v-else class="w-10 h-10 bg-violet-500/30 rounded-lg flex items-center justify-center text-[13px] font-bold">
        {{ segment.flight_number?.split(' ')[0] }}
      </div>
      <div>
        <div class="font-semibold text-[15px]">{{ segment.airline }}</div>
        <div class="text-[13px] text-violet-300">{{ segment.flight_number }} · {{ segment.airplane }}</div>
      </div>
    </div>

    <!-- Route -->
    <div class="flex items-center justify-between">
      <div class="text-center">
        <div class="text-2xl font-bold">{{ segment.departure_airport?.id }}</div>
        <div class="text-[15px] text-violet-300 mt-1">{{ formatTime(segment.departure_airport?.time ?? null) }}</div>
        <div class="text-[13px] text-violet-400 mt-0.5">{{ formatShortDate(segment.departure_airport?.time ?? '') }}</div>
      </div>

      <div class="flex-1 px-4">
        <div class="relative">
          <div class="border-t border-dashed border-violet-400/50"></div>
          <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 bg-violet-900/90 backdrop-blur-sm px-3 py-1 rounded-full border border-violet-500/30">
            <span class="text-[13px] text-violet-200 font-medium">{{ formatDuration(segment.duration ?? null) }}</span>
          </div>
        </div>
      </div>

      <div class="text-center">
        <div class="text-2xl font-bold">{{ segment.arrival_airport?.id }}</div>
        <div class="text-[15px] text-violet-300 mt-1">{{ formatTime(segment.arrival_airport?.time ?? null) }}</div>
        <div class="text-[13px] text-violet-400 mt-0.5">{{ formatShortDate(segment.arrival_airport?.time ?? '') }}</div>
      </div>
    </div>

    <!-- Class & Legroom -->
    <div class="flex gap-2 mt-4">
      <span v-if="segment.travel_class" class="text-[13px] bg-violet-500/20 px-3 py-1.5 rounded-lg">
        {{ segment.travel_class }}
      </span>
      <span v-if="segment.legroom" class="text-[13px] bg-white/10 px-3 py-1.5 rounded-lg">
        {{ $t('results.legroom', { value: segment.legroom }) }}
      </span>
    </div>
  </div>
</template>
