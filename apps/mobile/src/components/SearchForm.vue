<script setup lang="ts">
/**
 * SearchForm - Flight search form with trip options, route, and dates
 * Composed of smaller sub-components for maintainability
 */
import { useI18n } from 'vue-i18n'
import { TripOptionsChips, RouteCard, DateCard } from './search'

const { t } = useI18n()

defineProps<{
  origin: string
  destination: string
  departureDate: string
  returnDate: string
  roundTrip: boolean
  loading: boolean
}>()

const emit = defineEmits<{
  'update:origin': [value: string]
  'update:destination': [value: string]
  'update:departureDate': [value: string]
  'update:returnDate': [value: string]
  'update:roundTrip': [value: boolean]
  search: []
}>()

function handleSubmit() {
  emit('search')
}
</script>

<template>
  <form @submit.prevent="handleSubmit" class="flex flex-col gap-3">
    <!-- Trip Options: Type, Passengers, Class -->
    <TripOptionsChips 
      :round-trip="roundTrip"
      @update:round-trip="emit('update:roundTrip', $event)"
    />

    <!-- Route: Origin + Destination -->
    <RouteCard
      :origin="origin"
      :destination="destination"
      @update:origin="emit('update:origin', $event)"
      @update:destination="emit('update:destination', $event)"
    />

    <!-- Dates: Departure + Return -->
    <DateCard
      :departure-date="departureDate"
      :return-date="returnDate"
      :round-trip="roundTrip"
      @update:departure-date="emit('update:departureDate', $event)"
      @update:return-date="emit('update:returnDate', $event)"
      @update:round-trip="emit('update:roundTrip', $event)"
    />

    <!-- Search Button -->
    <button
      type="submit"
      :disabled="loading"
      class="btn-primary flex items-center justify-center gap-2"
    >
      <template v-if="loading">
        <svg class="animate-spin h-5 w-5" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" fill="none"/>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"/>
        </svg>
        {{ t('search.searching') }}
      </template>
      <template v-else>
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
        </svg>
        {{ t('search.explore') }}
      </template>
    </button>
  </form>
</template>
