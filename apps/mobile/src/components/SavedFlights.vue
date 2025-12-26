<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { getSavedFlights, getFavorites, toggleFavorite, deleteSavedFlight, type SavedFlight } from '../db'

const savedFlights = ref<SavedFlight[]>([])
const loading = ref(true)
const error = ref<string | null>(null)
const showFavoritesOnly = ref(false)

const displayedFlights = computed(() => {
  if (showFavoritesOnly.value) {
    return savedFlights.value.filter(f => f.is_favorite)
  }
  return savedFlights.value
})

onMounted(async () => {
  await loadFlights()
})

async function loadFlights() {
  loading.value = true
  error.value = null
  
  try {
    savedFlights.value = showFavoritesOnly.value 
      ? await getFavorites()
      : await getSavedFlights()
  } catch (e) {
    error.value = 'Failed to load saved flights'
    console.error(e)
  } finally {
    loading.value = false
  }
}

async function handleToggleFavorite(id: number) {
  const newStatus = await toggleFavorite(id)
  const flight = savedFlights.value.find(f => f.id === id)
  if (flight) {
    flight.is_favorite = newStatus
  }
}

async function handleDelete(id: number) {
  await deleteSavedFlight(id)
  savedFlights.value = savedFlights.value.filter(f => f.id !== id)
}

function formatDate(dateStr: string): string {
  const date = new Date(dateStr)
  return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })
}

function formatPrice(price: number, currency: string): string {
  return new Intl.NumberFormat('en-US', { style: 'currency', currency }).format(price)
}
</script>

<template>
  <div class="space-y-4">
    <!-- Filter Tabs -->
    <div class="flex gap-2">
      <button
        @click="showFavoritesOnly = false; loadFlights()"
        :class="[
          'px-4 py-2 rounded-xl text-sm font-medium transition-all',
          !showFavoritesOnly 
            ? 'bg-violet-500 text-white' 
            : 'bg-white/10 text-violet-300 hover:bg-white/20'
        ]"
      >
        {{ $t('saved.filters.all', { count: savedFlights.length }) }}
      </button>
      <button
        @click="showFavoritesOnly = true; loadFlights()"
        :class="[
          'px-4 py-2 rounded-xl text-sm font-medium transition-all',
          showFavoritesOnly 
            ? 'bg-violet-500 text-white' 
            : 'bg-white/10 text-violet-300 hover:bg-white/20'
        ]"
      >
        ⭐ {{ $t('saved.filters.favorites') }}
      </button>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="text-center py-8 text-violet-300">
      {{ $t('saved.loading') }}
    </div>

    <!-- Error -->
    <div v-else-if="error" class="bg-red-500/20 border border-red-500/50 rounded-xl p-4 text-red-300">
      {{ error }}
    </div>

    <!-- Empty State -->
    <div v-else-if="displayedFlights.length === 0" class="text-center py-8">
      <div class="text-4xl mb-2">✈️</div>
      <div class="text-violet-300">
        {{ showFavoritesOnly ? $t('saved.empty.favorites') : $t('saved.empty.saved') }}
      </div>
      <div class="text-sm text-violet-400 mt-1">
        {{ $t('saved.empty.prompt') }}
      </div>
    </div>

    <!-- Flight List -->
    <div v-else class="space-y-3">
      <div
        v-for="flight in displayedFlights"
        :key="flight.id"
        class="bg-white/10 backdrop-blur-md rounded-xl p-4 border border-white/20"
      >
        <div class="flex justify-between items-start mb-2">
          <!-- Route -->
          <div>
            <div class="text-lg font-bold">
              {{ flight.origin }} → {{ flight.destination }}
            </div>
            <div class="text-sm text-violet-300">
              {{ formatDate(flight.travel_date) }}
            </div>
          </div>
          
          <!-- Price & Actions -->
          <div class="text-right">
            <div class="text-xl font-bold text-green-400">
              {{ formatPrice(flight.price, flight.currency) }}
            </div>
            <div class="flex gap-2 mt-1">
              <button
                @click="handleToggleFavorite(flight.id)"
                class="text-xl hover:scale-110 transition-transform"
                :title="flight.is_favorite ? 'Remove from favorites' : 'Add to favorites'"
              >
                {{ flight.is_favorite ? '⭐' : '☆' }}
              </button>
              <button
                @click="handleDelete(flight.id)"
                class="text-lg text-red-400 hover:text-red-300 hover:scale-110 transition-transform"
                title="Delete"
              >
                🗑️
              </button>
            </div>
          </div>
        </div>

        <!-- Details -->
        <div class="flex gap-4 text-sm text-violet-300">
          <span v-if="flight.airline">{{ flight.airline }}</span>
          <span v-if="flight.duration">{{ flight.duration.replace('PT', '').replace('H', 'h ').replace('M', 'm') }}</span>
          <span>{{ flight.stops === 0 ? $t('results.direct') : $t('results.stop_count', { count: flight.stops }, flight.stops) }}</span>
        </div>

        <!-- Searched timestamp -->
        <div class="text-xs text-violet-400 mt-2">
          {{ $t('saved.saved_at', { date: new Date(flight.searched_at).toLocaleDateString() }) }}
        </div>
      </div>
    </div>
  </div>
</template>
