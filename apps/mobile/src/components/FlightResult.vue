<script setup lang="ts">
import { computed } from 'vue'
import type { FlightOffer } from '../api'

const props = defineProps<{
  offer: FlightOffer
  index?: number
  savedId?: number | null
  isFavorite?: boolean
}>()

const emit = defineEmits<{
  'toggle-favorite': [id: number]
  'save-flight': [offer: FlightOffer]
}>()

function handleFavoriteClick() {
  if (props.savedId) {
    emit('toggle-favorite', props.savedId)
  }
}

function handleSaveClick() {
  emit('save-flight', props.offer)
}

const isFirst = computed(() => props.index === 1)

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
  <section class="card animate-fade-in">
    <h2 v-if="isFirst" class="text-center text-xl font-bold mb-4">🎉 {{ $t('results.title') }}</h2>
    <div v-else class="text-lg font-semibold text-violet-300 mb-4">{{ $t('results.option') }} {{ index }}</div>

    <!-- Price Header -->
    <div :class="[
      'rounded-2xl p-4 border mb-4',
      isFirst 
        ? 'bg-gradient-to-br from-green-500/20 to-emerald-500/20 border-green-500/30' 
        : 'bg-white/5 border-white/10'
    ]">
      <div class="flex items-center justify-between">
        <div>
          <div class="text-3xl font-bold text-green-400">{{ formattedPrice }}</div>
          <div class="text-sm text-green-300/80">{{ offer.currency }} {{ $t('results.total') }}</div>
        </div>
        
        <!-- Action Buttons -->
        <div class="flex items-center gap-2">
          <!-- Save Button (when not saved) -->
          <button 
            v-if="!savedId"
            @click="handleSaveClick"
            class="px-4 py-2 flex items-center gap-2 bg-violet-600 hover:bg-violet-500 rounded-lg transition-all duration-200 hover:scale-105 active:scale-95 text-white font-medium"
          >
            <span>💾</span>
            <span>{{ $t('results.save') }}</span>
          </button>
          
          <!-- Favorite Button (when saved) -->
          <button 
            v-if="savedId"
            @click="handleFavoriteClick"
            class="w-12 h-12 flex items-center justify-center rounded-full transition-all duration-200 hover:scale-110 active:scale-95"
            :class="isFavorite ? 'bg-amber-500/30 text-amber-400' : 'bg-white/10 text-white/50 hover:text-amber-400'"
            :title="isFavorite ? 'Remove from favorites' : 'Add to favorites'"
          >
            <span class="text-2xl">{{ isFavorite ? '⭐' : '☆' }}</span>
          </button>
        </div>

        <div class="text-right">
          <div class="text-lg font-semibold">{{ formatDuration(offer.duration) }}</div>
          <div class="text-sm text-violet-300">
            {{ offer.stops === 0 ? $t('results.direct') : $t('results.stop_count', { count: offer.stops }, offer.stops) }}
          </div>
        </div>
      </div>
    </div>

    <!-- Flight Segments -->
    <div v-if="offer.stops > 0" class="space-y-3">
      <template v-if="hasSegments">
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
                <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 bg-violet-900/90 px-3 py-1 rounded-full border border-violet-500/30">
                  <span class="text-xs text-violet-200 font-medium">{{ formatDuration(segment.duration) }}</span>
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
              {{ $t('results.legroom', { value: segment.legroom }) }}
            </span>
          </div>
        </div>
      </template>
      
      <!-- Missing Details Fallback -->
      <div v-else class="p-4 bg-amber-500/10 border border-amber-500/20 rounded-xl text-center">
        <p class="text-amber-300 font-medium">{{ $t('results.details_unavailable') }}</p>
        <p class="text-xs text-amber-200/70 mt-1">{{ $t('results.details_unavailable_desc') }}</p>
      </div>
    </div>

    <!-- Direct Flight / Simple View -->
    <div v-else class="grid grid-cols-2 gap-3">
      <div class="bg-white/5 p-3 rounded-xl">
        <span class="block text-sm text-violet-300">{{ $t('results.airline') }}</span>
        <span class="text-lg font-semibold">{{ offer.airline || offer.airline_code || 'N/A' }}</span>
      </div>
      <div class="bg-white/5 p-3 rounded-xl">
        <span class="block text-sm text-violet-300">{{ $t('results.stops') }}</span>
        <span class="text-lg font-semibold">{{ offer.stops === 0 ? $t('results.direct') : $t('results.stop_count', { count: offer.stops }, offer.stops) }}</span>
      </div>
      <div class="bg-white/5 p-3 rounded-xl">
        <span class="block text-sm text-violet-300">{{ $t('results.duration') }}</span>
        <span class="text-lg font-semibold">{{ formatDuration(offer.duration) }}</span>
      </div>
      <div class="bg-white/5 p-3 rounded-xl">
        <span class="block text-sm text-violet-300">{{ $t('results.departure') }}</span>
        <span class="text-lg font-semibold">{{ formatTime(offer.departure_at) }}</span>
      </div>
    </div>
  </section>
</template>
