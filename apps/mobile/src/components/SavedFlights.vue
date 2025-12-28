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
          'min-h-[48px] px-5 py-3 rounded-xl text-[15px] font-semibold transition-all flex-1 sm:flex-none',
          !showFavoritesOnly
            ? 'bg-purple-600 text-white shadow-lg shadow-purple-600/30'
            : 'bg-white/[0.06] backdrop-blur-md text-white/70 hover:bg-white/[0.08] active:bg-white/[0.1] border border-white/[0.1]'
        ]"
      >
        {{ $t('saved.filters.all', { count: savedFlights.length }) }}
      </button>
      <button
        @click="showFavoritesOnly = true; loadFlights()"
        :class="[
          'min-h-[48px] px-5 py-3 rounded-xl text-[15px] font-semibold transition-all flex-1 sm:flex-none',
          showFavoritesOnly
            ? 'bg-purple-600 text-white shadow-lg shadow-purple-600/30'
            : 'bg-white/[0.06] backdrop-blur-md text-white/70 hover:bg-white/[0.08] active:bg-white/[0.1] border border-white/[0.1]'
        ]"
      >
        ⭐ {{ $t('saved.filters.favorites') }}
      </button>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="text-center py-12 text-white/60 text-[15px]">
      {{ $t('saved.loading') }}
    </div>

    <!-- Error -->
    <div v-else-if="error" class="bg-red-500/20 backdrop-blur-md border border-red-500/50 rounded-2xl p-4 text-red-300 text-[15px]">
      {{ error }}
    </div>

    <!-- Empty State -->
    <div v-else-if="displayedFlights.length === 0" class="text-center py-12">
      <div class="text-5xl mb-3">✈️</div>
      <div class="text-white text-[17px] font-medium">
        {{ showFavoritesOnly ? $t('saved.empty.favorites') : $t('saved.empty.saved') }}
      </div>
      <div class="text-[15px] text-white/50 mt-2">
        {{ $t('saved.empty.prompt') }}
      </div>
    </div>

    <!-- Flight List -->
    <div v-else class="space-y-3">
      <div
        v-for="flight in displayedFlights"
        :key="flight.id"
        class="bg-white/[0.06] backdrop-blur-xl rounded-2xl p-4 border border-white/[0.1]"
      >
        <div class="flex justify-between items-start mb-3 gap-3">
          <!-- Route -->
          <div class="flex-1 min-w-0">
            <div class="text-lg font-bold">
              {{ flight.origin }} → {{ flight.destination }}
            </div>
            <div class="text-[13px] text-white/50 mt-1">
              {{ formatDate(flight.travel_date) }}
            </div>
          </div>

          <!-- Price & Actions -->
          <div class="text-right flex-shrink-0">
            <div class="text-xl font-bold text-emerald-400">
              {{ formatPrice(flight.price, flight.currency) }}
            </div>
            <div class="flex gap-1 mt-2 justify-end">
              <button
                @click="handleToggleFavorite(flight.id)"
                class="text-2xl hover:scale-110 active:scale-95 transition-transform min-w-[48px] min-h-[48px] flex items-center justify-center"
                :title="flight.is_favorite ? 'Remove from favorites' : 'Add to favorites'"
              >
                {{ flight.is_favorite ? '⭐' : '☆' }}
              </button>
              <button
                @click="handleDelete(flight.id)"
                class="text-xl text-red-400 hover:text-red-300 hover:scale-110 active:scale-95 transition-transform min-w-[48px] min-h-[48px] flex items-center justify-center"
                title="Delete"
              >
                🗑️
              </button>
            </div>
          </div>
        </div>

        <!-- Details -->
        <div class="flex flex-wrap gap-4 text-[13px] text-white/50">
          <span v-if="flight.airline">{{ flight.airline }}</span>
          <span v-if="flight.duration">{{ flight.duration.replace('PT', '').replace('H', 'h ').replace('M', 'm') }}</span>
          <span>{{ flight.stops === 0 ? $t('results.direct') : $t('results.stop_count', { count: flight.stops }, flight.stops) }}</span>
        </div>

        <!-- Searched timestamp -->
        <div class="text-[13px] text-white/40 mt-2">
          {{ $t('saved.saved_at', { date: new Date(flight.searched_at).toLocaleDateString() }) }}
        </div>
      </div>
    </div>
  </div>
</template>
