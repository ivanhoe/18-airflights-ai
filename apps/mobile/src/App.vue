<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { searchFlights, type FlightOffer } from './api'
import { initDatabase, saveFlightResult, toggleFavorite } from './db'
import { notifyFlightSaved } from './notifications'

// Components
import AppHeader from './components/AppHeader.vue'
import SearchForm from './components/SearchForm.vue'
import FlightResult from './components/FlightResult.vue'
import ErrorMessage from './components/ErrorMessage.vue'
import SavedFlights from './components/SavedFlights.vue'

// Navigation
type Tab = 'search' | 'saved'
const activeTab = ref<Tab>('search')

// Search State
const origin = ref('MEX')
const destination = ref('VIE')
const departureDate = ref(getDefaultDate())
const returnDate = ref(getDefaultReturnDate())
const roundTrip = ref(false)
const offers = ref<FlightOffer[]>([])
const loading = ref(false)
const error = ref<string | null>(null)
const lastSavedId = ref<number | null>(null)
const isFavorite = ref(false)

// Track which offers have been saved (by index)
const savedOfferIds = ref<Map<number, number>>(new Map())

// Network state
const isOnline = ref(navigator.onLine)

function getDefaultDate(): string {
  const date = new Date()
  date.setDate(date.getDate() + 30)
  return date.toISOString().split('T')[0]
}

function getDefaultReturnDate(): string {
  const date = new Date()
  date.setDate(date.getDate() + 37) // 7 days after departure
  return date.toISOString().split('T')[0]
}

onMounted(async () => {
  // Initialize database
  try {
    await initDatabase()
  } catch (e) {
    console.error('Failed to initialize database:', e)
  }
  
  // Listen for network changes
  window.addEventListener('online', () => isOnline.value = true)
  window.addEventListener('offline', () => {
    isOnline.value = false
    // Auto-switch to saved flights when going offline
    if (activeTab.value === 'search' && offers.value.length === 0) {
      activeTab.value = 'saved'
    }
  })
})

async function handleSearch() {
  loading.value = true
  error.value = null
  offers.value = []
  lastSavedId.value = null
  isFavorite.value = false

  const result = await searchFlights(
    origin.value,
    destination.value,
    departureDate.value
  )

  loading.value = false

  if (result.success && result.data && result.data.length > 0) {
    // Take top 5 cheapest
    offers.value = result.data.slice(0, 5)
    savedOfferIds.value.clear()
  } else {
    error.value = result.error || 'No flights found'
  }
}

async function handleSaveFlight(offer: FlightOffer, index: number) {
  try {
    const savedId = await saveFlightResult(
      origin.value,
      destination.value,
      departureDate.value,
      offer
    )
    
    // Track this offer as saved
    savedOfferIds.value.set(index, savedId)
    
    // Send native notification
    await notifyFlightSaved(
      origin.value,
      destination.value,
      offer.price,
      offer.currency
    )
    
    console.log('[App] Flight saved and notification sent')
  } catch (e) {
    console.error('Failed to save flight:', e)
  }
}


async function handleToggleFavorite(id: number) {
  try {
    isFavorite.value = await toggleFavorite(id)
  } catch (e) {
    console.error('Failed to toggle favorite:', e)
  }
}
</script>

<template>
  <div class="max-w-lg mx-auto min-h-dvh flex flex-col safe-area-inset">
    <!-- Offline Banner -->
    <div 
      v-if="!isOnline" 
      class="bg-amber-500/20 border-b border-amber-500/30 px-4 py-2 text-center text-amber-300 text-sm"
    >
      {{ $t('offline_banner') }}
    </div>

    <!-- Navigation Tabs -->
    <nav class="flex border-b border-white/10 mb-4">
      <button
        @click="activeTab = 'search'"
        :class="[
          'flex-1 py-3 text-center text-sm sm:text-base font-medium transition-colors',
          activeTab === 'search' 
            ? 'text-white border-b-2 border-violet-400' 
            : 'text-violet-400 hover:text-violet-300'
        ]"
      >
        🔍 {{ $t('tabs.search') }}
      </button>
      <button
        @click="activeTab = 'saved'"
        :class="[
          'flex-1 py-3 text-center text-sm sm:text-base font-medium transition-colors',
          activeTab === 'saved' 
            ? 'text-white border-b-2 border-violet-400' 
            : 'text-violet-400 hover:text-violet-300'
        ]"
      >
        💾 {{ $t('tabs.saved') }}
      </button>
    </nav>

    <div class="flex-1 px-4">
      <!-- Search Tab -->
      <div v-if="activeTab === 'search'">
        <AppHeader 
          :title="$t('search.header.title')"
          :subtitle="$t('search.header.subtitle')"
        />

        <main class="card">
          <SearchForm
            v-model:origin="origin"
            v-model:destination="destination"
            v-model:departure-date="departureDate"
            v-model:return-date="returnDate"
            v-model:round-trip="roundTrip"
            :loading="loading"
            @search="handleSearch"
          />

          <ErrorMessage v-if="error" :message="error" />
        </main>

        <!-- Results -->
        <div v-if="offers.length > 0" class="space-y-4 mt-4">
          <FlightResult 
            v-for="(offer, index) in offers"
            :key="index"
            :offer="offer" 
            :index="index + 1"
            :saved-id="savedOfferIds.get(index) ?? null"
            :is-favorite="false"
            @toggle-favorite="handleToggleFavorite"
            @save-flight="(o) => handleSaveFlight(o, index)"
          />
        </div>
        
        <!-- Save confirmation -->
        <div 
          v-if="lastSavedId" 
          class="mt-4 text-center text-sm text-green-400 animate-fade-in"
        >
          ✓ {{ $t('search.saved_confirmation') }}
        </div>
      </div>

      <!-- Saved Flights Tab -->
      <div v-else>
        <AppHeader 
          :title="'💾 ' + $t('tabs.saved')"
          :subtitle="$t('search.saved_flights')"
        />
        <SavedFlights />
      </div>
    </div>

    <footer class="text-center py-6 text-sm text-violet-300 mt-auto">
      {{ $t('footer') }}
    </footer>
  </div>
</template>