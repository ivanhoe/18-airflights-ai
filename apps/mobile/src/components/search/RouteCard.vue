<script setup lang="ts">
/**
 * RouteCard - Origin and destination airport selects in a grouped card
 * Uses global .input-card, .input-row, .input-divider classes from index.css
 */
import { airports } from '../../constants'

defineProps<{
  origin: string
  destination: string
}>()

const emit = defineEmits<{
  'update:origin': [value: string]
  'update:destination': [value: string]
}>()
</script>

<template>
  <div class="input-card">
    <!-- Origin -->
    <div class="input-row">
      <svg xmlns="http://www.w3.org/2000/svg" class="input-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <circle cx="12" cy="12" r="3" stroke-width="2"/>
      </svg>
      <select
        :value="origin"
        @change="emit('update:origin', ($event.target as HTMLSelectElement).value)"
        class="input-select"
      >
        <option v-for="airport in airports" :key="airport.code" :value="airport.code" class="bg-slate-900">
          {{ airport.name }}
        </option>
      </select>
      <svg xmlns="http://www.w3.org/2000/svg" class="caret-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
      </svg>
    </div>

    <div class="input-divider"></div>

    <!-- Destination -->
    <div class="input-row">
      <svg xmlns="http://www.w3.org/2000/svg" class="input-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
      </svg>
      <select
        :value="destination"
        @change="emit('update:destination', ($event.target as HTMLSelectElement).value)"
        class="input-select"
      >
        <option v-for="airport in airports" :key="airport.code" :value="airport.code" class="bg-slate-900">
          {{ airport.name }}
        </option>
      </select>
      <svg xmlns="http://www.w3.org/2000/svg" class="caret-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
      </svg>
    </div>
  </div>
</template>
