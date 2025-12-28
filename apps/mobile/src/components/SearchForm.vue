<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()

const airports = [
  { code: 'MEX', name: 'Ciudad de México' },
  { code: 'MTY', name: 'Monterrey' },
  { code: 'GDL', name: 'Guadalajara' },
  { code: 'CUN', name: 'Cancún' },
  { code: 'TIJ', name: 'Tijuana' },
  { code: 'VIE', name: 'Viena' },
  { code: 'MAD', name: 'Madrid' },
  { code: 'LHR', name: 'Londres' },
  { code: 'JFK', name: 'New York' },
  { code: 'MIA', name: 'Miami' },
  { code: 'AMS', name: 'Amsterdam' },
  { code: 'DFW', name: 'Dallas' }
]

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

const minDate = computed(() => new Date().toISOString().split('T')[0])

function handleSubmit() {
  emit('search')
}
</script>

<template>
  <form @submit.prevent="handleSubmit" class="flex flex-col gap-3">
    <!-- Trip Options Row -->
    <div class="flex items-center gap-2 flex-wrap">
      <!-- Trip Type Chip -->
      <div class="chip">
        <svg xmlns="http://www.w3.org/2000/svg" class="chip-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" />
        </svg>
        <select
          :value="roundTrip ? 'true' : 'false'"
          @change="emit('update:roundTrip', ($event.target as HTMLSelectElement).value === 'true')"
          class="chip-select"
        >
          <option value="false" class="bg-slate-900">{{ t('search.one_way') }}</option>
          <option value="true" class="bg-slate-900">{{ t('search.round_trip') }}</option>
        </select>
      </div>

      <!-- Passengers Chip -->
      <div class="chip">
        <svg xmlns="http://www.w3.org/2000/svg" class="chip-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
        </svg>
        <span class="text-white text-[15px]">1</span>
      </div>

      <!-- Class Chip -->
      <div class="chip">
        <span class="text-white text-[15px]">{{ t('search.economy') }}</span>
      </div>
    </div>

    <!-- Route Card: Origin + Destination -->
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

      <!-- Divider -->
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

    <!-- Dates -->
    <div class="input-card">
      <!-- Departure Date -->
      <div class="input-row">
        <svg xmlns="http://www.w3.org/2000/svg" class="input-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
        </svg>
        <input
          type="date"
          :value="departureDate"
          @input="emit('update:departureDate', ($event.target as HTMLInputElement).value)"
          :min="minDate"
          class="input-date"
        />
      </div>

      <!-- Divider -->
      <div class="input-divider"></div>

      <!-- Return Date -->
      <div
        class="input-row"
        :class="{ 'opacity-50': !roundTrip }"
        @click="!roundTrip && emit('update:roundTrip', true)"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="input-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
        </svg>
        <template v-if="roundTrip">
          <input
            type="date"
            :value="returnDate"
            @input="emit('update:returnDate', ($event.target as HTMLInputElement).value)"
            :min="departureDate"
            class="input-date"
          />
        </template>
        <template v-else>
          <span class="text-white/50 text-[15px] flex-1">{{ t('search.add_return') }}</span>
        </template>
      </div>
    </div>

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

<style scoped>
/* Chip Components - iOS style pills */
.chip {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 10px 14px;
  min-height: 44px;
  background: rgba(255, 255, 255, 0.08);
  border: 1px solid rgba(255, 255, 255, 0.15);
  border-radius: 12px;
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
}

.chip-icon {
  width: 16px;
  height: 16px;
  color: rgba(255, 255, 255, 0.6);
  flex-shrink: 0;
}

.chip-select {
  background: transparent;
  border: none;
  color: white;
  font-size: 15px;
  outline: none;
  cursor: pointer;
  -webkit-appearance: none;
  appearance: none;
}

/* Input Card - Grouped inputs */
.input-card {
  background: rgba(255, 255, 255, 0.08);
  border: 1px solid rgba(255, 255, 255, 0.15);
  border-radius: 16px;
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  overflow: hidden;
}

.input-row {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 14px 16px;
  min-height: 52px;
}

.input-divider {
  height: 1px;
  background: rgba(255, 255, 255, 0.1);
  margin: 0 16px;
}

.input-icon {
  width: 20px;
  height: 20px;
  color: rgba(255, 255, 255, 0.5);
  flex-shrink: 0;
}

.input-select {
  flex: 1;
  background: transparent;
  border: none;
  color: white;
  font-size: 16px;
  outline: none;
  cursor: pointer;
  -webkit-appearance: none;
  appearance: none;
}

.caret-icon {
  width: 16px;
  height: 16px;
  color: rgba(255, 255, 255, 0.4);
  flex-shrink: 0;
}

.input-date {
  flex: 1;
  background: transparent;
  border: none;
  color: white;
  font-size: 16px;
  outline: none;
  -webkit-appearance: none;
  appearance: none;
}

/* iOS date input styling */
input[type="date"]::-webkit-date-and-time-value {
  text-align: left;
}

input[type="date"]::-webkit-calendar-picker-indicator {
  filter: invert(1);
  opacity: 0.6;
  cursor: pointer;
}

/* Touch feedback */
.chip:active,
.input-row:active {
  background: rgba(255, 255, 255, 0.12);
}

/* Ensure text doesn't wrap */
.chip-select,
.input-select,
.input-date {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
</style>
