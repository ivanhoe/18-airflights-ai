<script setup lang="ts">
import { ref } from 'vue'
import { searchCheapestFlight, type FlightOffer } from './api'

// Components
import AppHeader from './components/AppHeader.vue'
import RouteDisplay from './components/RouteDisplay.vue'
import SearchForm from './components/SearchForm.vue'
import FlightResult from './components/FlightResult.vue'
import ErrorMessage from './components/ErrorMessage.vue'

// State
const origin = ref('MEX')
const destination = ref('VIE')
const selectedDate = ref(getDefaultDate())
const offer = ref<FlightOffer | null>(null)
const loading = ref(false)
const error = ref<string | null>(null)

function getDefaultDate(): string {
  const date = new Date()
  date.setDate(date.getDate() + 30)
  return date.toISOString().split('T')[0]
}

async function handleSearch() {
  loading.value = true
  error.value = null
  offer.value = null

  const result = await searchCheapestFlight(
    origin.value,
    destination.value,
    selectedDate.value
  )

  loading.value = false

  if (result.success && result.data) {
    offer.value = result.data
  } else {
    error.value = result.error || 'No flights found'
  }
}
</script>

<template>
  <div class="max-w-lg mx-auto min-h-dvh flex flex-col safe-area-inset">
    <div class="flex-1">
      <AppHeader 
        title="✈️ Flight Tracker"
        subtitle="Find the cheapest flights from Mexico City to Vienna"
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

      <FlightResult v-if="offer" :offer="offer" />
    </div>

    <footer class="text-center py-6 text-sm text-violet-300 mt-auto">
      Powered by SerpApi (Google Flights) • Built with Tauri + Vue
    </footer>
  </div>
</template>