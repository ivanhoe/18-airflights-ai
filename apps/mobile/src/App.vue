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
  <div class="app">
    <div class="content">
      <AppHeader 
        title="✈️ Flight Tracker"
        subtitle="Find the cheapest flights from Mexico City to Vienna"
      />

      <main class="search-card">
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

    <footer class="footer">
      Powered by Amadeus API • Built with Tauri + Vue
    </footer>
  </div>
</template>

<style>
* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

:root {
  --bg-primary: #0f172a;
  --bg-secondary: rgba(255, 255, 255, 0.1);
  --text-primary: #ffffff;
  --text-secondary: #a78bfa;
  --accent: linear-gradient(135deg, #9333ea, #ec4899);
  --success: #22c55e;
  --error: #ef4444;
  
  /* iOS Safe Areas */
  --safe-area-top: env(safe-area-inset-top, 20px);
  --safe-area-bottom: env(safe-area-inset-bottom, 20px);
  --safe-area-left: env(safe-area-inset-left, 0px);
  --safe-area-right: env(safe-area-inset-right, 0px);
}

html, body {
  height: 100%;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  background: linear-gradient(135deg, #0f172a, #581c87, #0f172a);
  min-height: 100vh;
  min-height: -webkit-fill-available;
  color: var(--text-primary);
}

#app {
  min-height: 100vh;
  min-height: -webkit-fill-available;
}

.app {
  max-width: 500px;
  margin: 0 auto;
  min-height: 100vh;
  min-height: -webkit-fill-available;
  display: flex;
  flex-direction: column;
  padding: calc(var(--safe-area-top) + 1rem) calc(var(--safe-area-right) + 1rem) calc(var(--safe-area-bottom) + 1rem) calc(var(--safe-area-left) + 1rem);
}

.content {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.search-card {
  background: var(--bg-secondary);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border-radius: 1.5rem;
  padding: 1.5rem;
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.footer {
  text-align: center;
  padding: 1rem 0;
  font-size: 0.8rem;
  color: var(--text-secondary);
}
</style>