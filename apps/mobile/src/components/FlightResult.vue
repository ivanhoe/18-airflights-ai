<script setup lang="ts">
import { computed } from 'vue'
import type { FlightOffer } from '../api'

const props = defineProps<{
  offer: FlightOffer
}>()

const formattedPrice = computed(() => {
  if (!props.offer?.price) return null
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: props.offer.currency || 'USD'
  }).format(props.offer.price)
})

function formatDuration(duration: string | number | null): string {
  if (!duration) return 'N/A'
  if (typeof duration === 'number') {
    const hours = Math.floor(duration / 60)
    const mins = duration % 60
    return `${hours}h ${mins}m`
  }
  return duration.replace('PT', '').replace('H', 'h ').replace('M', 'm')
}

function formatTime(timeStr: string | null): string {
  if (!timeStr) return 'N/A'
  const date = new Date(timeStr.replace(' ', 'T'))
  return date.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', hour12: false })
}

function formatDate(timeStr: string | null): string {
  if (!timeStr) return ''
  const date = new Date(timeStr.replace(' ', 'T'))
  return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
}

const hasSegments = computed(() => props.offer.segments && props.offer.segments.length > 0)
</script>

<template>
  <section class="card mt-6 animate-fade-in">
    <h2 class="text-center text-xl font-bold mb-4">🎉 Cheapest Flight Found!</h2>

    <!-- Price Header -->
    <div class="bg-gradient-to-br from-green-500/20 to-emerald-500/20 rounded-2xl p-4 border border-green-500/30 mb-4">
      <div class="flex items-center justify-between">
        <div>
          <div class="text-3xl font-bold text-green-400">{{ formattedPrice }}</div>
          <div class="text-sm text-green-300/80">{{ offer.currency }} total</div>
        </div>
        <div class="text-right">
          <div class="text-lg font-semibold">{{ formatDuration(offer.duration) }}</div>
          <div class="text-sm text-violet-300">
            {{ offer.stops === 0 ? 'Direct' : `${offer.stops} stop${offer.stops > 1 ? 's' : ''}` }}
          </div>
        </div>
      </div>
    </div>

    <!-- Flight Segments -->
    <div v-if="hasSegments" class="space-y-3">
      <div 
        v-for="(segment, index) in offer.segments" 
        :key="index"
        class="bg-white/5 rounded-xl p-4 border border-white/10"
      >
        <!-- Airline Header -->
        <div class="flex items-center gap-3 mb-3">
          <img 
            v-if="segment.airline_logo" 
            :src="segment.airline_logo" 
            :alt="segment.airline"
            class="w-8 h-8 rounded"
          />
          <div v-else class="w-8 h-8 bg-violet-500/30 rounded flex items-center justify-center text-xs font-bold">
            {{ segment.flight_number?.split(' ')[0] }}
          </div>
          <div>
            <div class="font-semibold">{{ segment.airline }}</div>
            <div class="text-xs text-violet-300">{{ segment.flight_number }} · {{ segment.airplane }}</div>
          </div>
        </div>

        <!-- Route -->
        <div class="flex items-center justify-between">
          <div class="text-center">
            <div class="text-2xl font-bold">{{ segment.departure_airport?.id }}</div>
            <div class="text-sm text-violet-300">{{ formatTime(segment.departure_airport?.time) }}</div>
            <div class="text-xs text-violet-400">{{ formatDate(segment.departure_airport?.time) }}</div>
          </div>
          
          <div class="flex-1 px-4">
            <div class="relative">
              <div class="border-t border-dashed border-violet-400/50"></div>
              <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 bg-slate-900 px-2">
                <span class="text-xs text-violet-300">{{ formatDuration(segment.duration) }}</span>
              </div>
            </div>
          </div>
          
          <div class="text-center">
            <div class="text-2xl font-bold">{{ segment.arrival_airport?.id }}</div>
            <div class="text-sm text-violet-300">{{ formatTime(segment.arrival_airport?.time) }}</div>
            <div class="text-xs text-violet-400">{{ formatDate(segment.arrival_airport?.time) }}</div>
          </div>
        </div>

        <!-- Class & Legroom -->
        <div class="flex gap-2 mt-3">
          <span v-if="segment.travel_class" class="text-xs bg-violet-500/20 px-2 py-1 rounded">
            {{ segment.travel_class }}
          </span>
          <span v-if="segment.legroom" class="text-xs bg-white/10 px-2 py-1 rounded">
            Legroom: {{ segment.legroom }}
          </span>
        </div>
      </div>
    </div>

    <!-- Fallback: Simple View (no segments) -->
    <div v-else class="grid grid-cols-2 gap-3">
      <div class="bg-white/5 p-3 rounded-xl">
        <span class="block text-sm text-violet-300">Airline</span>
        <span class="text-lg font-semibold">{{ offer.airline || offer.airline_code || 'N/A' }}</span>
      </div>
      <div class="bg-white/5 p-3 rounded-xl">
        <span class="block text-sm text-violet-300">Stops</span>
        <span class="text-lg font-semibold">{{ offer.stops === 0 ? 'Direct' : `${offer.stops} stop(s)` }}</span>
      </div>
      <div class="bg-white/5 p-3 rounded-xl">
        <span class="block text-sm text-violet-300">Duration</span>
        <span class="text-lg font-semibold">{{ formatDuration(offer.duration) }}</span>
      </div>
      <div class="bg-white/5 p-3 rounded-xl">
        <span class="block text-sm text-violet-300">Departure</span>
        <span class="text-lg font-semibold">{{ formatTime(offer.departure_at) }}</span>
      </div>
    </div>
  </section>
</template>
