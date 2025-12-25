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

function formatDuration(duration: string | null): string {
  if (!duration) return 'N/A'
  return duration.replace('PT', '').replace('H', 'h ').replace('M', 'm')
}

function formatDateTime(dateStr: string | null): string {
  if (!dateStr) return 'N/A'
  const date = new Date(dateStr)
  return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }) + 
    ', ' + date.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })
}
</script>

<template>
  <section class="card mt-6 animate-fade-in">
    <h2 class="text-center text-xl font-bold mb-6">🎉 Cheapest Flight Found!</h2>

    <div class="bg-gradient-to-br from-green-500/20 to-emerald-500/20 rounded-2xl p-6 border border-green-500/30">
      <!-- Price -->
      <div class="text-center mb-6">
        <div class="text-4xl font-bold text-green-500">{{ formattedPrice }}</div>
        <div class="text-sm text-green-300">{{ offer.currency }}</div>
      </div>

      <!-- Flight Details -->
      <div class="grid grid-cols-2 gap-3">
        <div class="bg-white/5 p-3 rounded-xl">
          <span class="block text-sm text-violet-300">Airline</span>
          <span class="text-lg font-semibold">{{ offer.airline_code || 'N/A' }}</span>
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
          <span class="text-lg font-semibold">{{ formatDateTime(offer.departure_at) }}</span>
        </div>
      </div>
    </div>
  </section>
</template>
