<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { searchCheapestFlight, type FlightOffer } from './api'
import { initDatabase, saveFlightResult, toggleFavorite } from './db'

// Components
import AppHeader from './components/AppHeader.vue'
import RouteDisplay from './components/RouteDisplay.vue'
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
const selectedDate = ref(getDefaultDate())
const offer = ref<FlightOffer | null>(null)
const loading = ref(false)
const error = ref<string | null>(null)
const lastSavedId = ref<number | null>(null)
const isFavorite = ref(false)

// Network state
const isOnline = ref(navigator.onLine)

function getDefaultDate(): string {
  const date = new Date()
  date.setDate(date.getDate() + 30)
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
    if (activeTab.value === 'search' && !offer.value) {
      activeTab.value = 'saved'
    }
  })
})

async function handleSearch() {
  loading.value = true
  error.value = null
  offer.value = null
  lastSavedId.value = null
  isFavorite.value = false

  const result = await searchCheapestFlight(
    origin.value,
    destination.value,
    selectedDate.value
  )

  loading.value = false

  if (result.success && result.data) {
    offer.value = result.data
    
    // Auto-save to database
    try {
      lastSavedId.value = await saveFlightResult(
        origin.value,
        destination.value,
        selectedDate.value,
        result.data
      )
    } catch (e) {
      console.error('Failed to save flight:', e)
    }
  } else {
    error.value = result.error || 'No flights found'
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
          'flex-1 py-3 text-center font-medium transition-colors',
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
          'flex-1 py-3 text-center font-medium transition-colors',
          activeTab === 'saved' 
            ? 'text-white border-b-2 border-violet-400' 
            : 'text-violet-400 hover:text-violet-300'
        ]"
      >
        💾 {{ $t('tabs.saved') }}
      </button>
    </nav>

    <div class="flex-1">
      <!-- Search Tab -->
      <div v-if="activeTab === 'search'">
        <AppHeader 
          :title="$t('search.header.title')"
          :subtitle="$t('search.header.subtitle')"
        />

        <main class="card">
          <RouteDisplay
            :origin="origin"
            origin-city="Mexico City"
            :destination="destination"
            destination-city="Vienna"
          />

          <SearchForm
            v-model="selectedDate"
            :loading="loading"
            @search="handleSearch"
          />

          <ErrorMessage v-if="error" :message="error" />
        </main>

        <FlightResult 
          v-if="offer" 
          :offer="offer" 
          :saved-id="lastSavedId"
          :is-favorite="isFavorite"
          @toggle-favorite="handleToggleFavorite"
        />
        
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