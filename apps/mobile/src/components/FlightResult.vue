<script setup lang="ts">
/**
 * FlightResult - Displays a flight offer with price and segments
 * Composed of: FlightPriceHeader, FlightSegment, FlightSimpleView
 */
import { computed } from 'vue'
import type { FlightOffer } from '../api'
import { FlightPriceHeader, FlightSegment, FlightSimpleView } from './flight'

const props = defineProps<{
  offer: FlightOffer
  index?: number
}>()

const isFirst = computed(() => props.index === 1)
const hasSegments = computed(() => props.offer.segments && props.offer.segments.length > 0)
</script>

<template>
  <section class="card animate-fade-in">
    <h2 v-if="isFirst" class="text-center text-xl font-bold mb-4">🎉 {{ $t('results.title') }}</h2>
    <div v-else class="text-lg font-semibold text-white/60 mb-4">{{ $t('results.option') }} {{ index }}</div>

    <!-- Price Header -->
    <FlightPriceHeader
      :price="offer.price"
      :currency="offer.currency"
      :duration="offer.duration"
      :stops="offer.stops"
      :is-first="isFirst"
    />

    <!-- Flight Segments -->
    <div v-if="offer.stops > 0" class="space-y-3">
      <template v-if="hasSegments">
        <FlightSegment
          v-for="(segment, segmentIndex) in offer.segments"
          :key="segmentIndex"
          :segment="segment"
        />
      </template>

      <!-- Missing Details Fallback -->
      <div v-else class="p-4 bg-amber-500/10 backdrop-blur-md border border-amber-500/20 rounded-2xl text-center">
        <p class="text-amber-300 font-medium text-[15px]">{{ $t('results.details_unavailable') }}</p>
        <p class="text-[13px] text-amber-200/70 mt-1">{{ $t('results.details_unavailable_desc') }}</p>
      </div>
    </div>

    <!-- Direct Flight / Simple View -->
    <FlightSimpleView
      v-else
      :airline="offer.airline || null"
      :airline-code="offer.airline_code || null"
      :stops="offer.stops"
      :duration="offer.duration"
      :departure-at="offer.departure_at || null"
    />
  </section>
</template>
