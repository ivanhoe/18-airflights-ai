<script setup lang="ts">
/**
 * SearchView - Main search interface for finding flights
 * 
 * This view component renders the flight search form and displays
 * search results. It uses the useFlightSearch composable for all
 * state management and business logic.
 */
import { useFlightSearch } from '../composables'

// Components
import AppHeader from '../components/AppHeader.vue'
import SearchForm from '../components/SearchForm.vue'
import FlightResult from '../components/FlightResult.vue'
import ErrorMessage from '../components/ErrorMessage.vue'

const {
  origin,
  destination,
  departureDate,
  returnDate,
  roundTrip,
  offers,
  loading,
  error,
  savedOfferIds,
  lastSavedId,
  search,
  saveFlight,
  toggleFavoriteStatus
} = useFlightSearch()
</script>

<template>
  <div>
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
        @search="search"
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
        @toggle-favorite="toggleFavoriteStatus"
        @save-flight="(o) => saveFlight(o, index)"
      />
    </div>

    <!-- Save confirmation -->
    <div
      v-if="lastSavedId"
      class="mt-4 p-3 text-center text-[15px] text-green-400 bg-green-500/10 backdrop-blur-md border border-green-500/30 rounded-xl animate-fade-in"
    >
      ✓ {{ $t('search.saved_confirmation') }}
    </div>
  </div>
</template>
