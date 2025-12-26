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
  <form @submit.prevent="handleSubmit" class="flex flex-col gap-4">
    <!-- Trip Type Row -->
    <div class="flex items-center gap-2">
      <div class="flex items-center gap-2 px-3 py-2 bg-slate-800/80 border border-slate-600/50 rounded-lg">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-slate-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" />
        </svg>
        <select 
          :value="roundTrip ? 'true' : 'false'"
          @change="emit('update:roundTrip', ($event.target as HTMLSelectElement).value === 'true')"
          class="bg-transparent text-slate-200 text-sm focus:outline-none"
        >
          <option value="true" class="bg-slate-800">{{ t('search.round_trip') }}</option>
          <option value="false" class="bg-slate-800">{{ t('search.one_way') }}</option>
        </select>
      </div>
      
      <div class="flex items-center gap-2 px-3 py-2 bg-slate-800/80 border border-slate-600/50 rounded-lg">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-slate-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
        </svg>
        <span class="text-slate-200 text-sm">1</span>
      </div>
      
      <div class="px-3 py-2 bg-slate-800/80 border border-slate-600/50 rounded-lg">
        <span class="text-slate-200 text-sm">{{ t('search.economy') }}</span>
      </div>
    </div>

    <!-- Origin / Destination -->
    <div class="flex flex-col gap-2">
      <div class="flex items-center gap-2 px-3 py-3 bg-slate-800/80 border border-slate-600/50 rounded-lg">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-slate-400 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <circle cx="12" cy="12" r="3" stroke-width="2"/>
        </svg>
        <select 
          :value="origin"
          @change="emit('update:origin', ($event.target as HTMLSelectElement).value)"
          class="bg-transparent text-white text-sm focus:outline-none flex-1"
        >
          <option v-for="airport in airports" :key="airport.code" :value="airport.code" class="bg-slate-800">
            {{ airport.name }}
          </option>
        </select>
      </div>

      <div class="flex items-center gap-2 px-3 py-3 bg-slate-800/80 border border-slate-600/50 rounded-lg">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-slate-400 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
        </svg>
        <select 
          :value="destination"
          @change="emit('update:destination', ($event.target as HTMLSelectElement).value)"
          class="bg-transparent text-white text-sm focus:outline-none flex-1"
        >
          <option v-for="airport in airports" :key="airport.code" :value="airport.code" class="bg-slate-800">
            {{ airport.name }}
          </option>
        </select>
      </div>
    </div>

    <!-- Dates -->
    <div class="grid grid-cols-2 gap-2">
      <div class="flex items-center gap-2 px-3 py-3 bg-slate-800/80 border border-slate-600/50 rounded-lg">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-slate-400 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
        </svg>
        <input
          type="date"
          :value="departureDate"
          @input="emit('update:departureDate', ($event.target as HTMLInputElement).value)"
          :min="minDate"
          class="bg-transparent text-white text-sm focus:outline-none flex-1"
        />
      </div>
      
      <!-- Return Date - Show input when round trip, placeholder when one-way -->
      <div 
        class="flex items-center gap-2 px-3 py-3 bg-slate-800/80 border border-slate-600/50 rounded-lg cursor-pointer"
        @click="!roundTrip && emit('update:roundTrip', true)"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-slate-400 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
        </svg>
        <template v-if="roundTrip">
          <input
            type="date"
            :value="returnDate"
            @input="emit('update:returnDate', ($event.target as HTMLInputElement).value)"
            :min="departureDate"
            class="bg-transparent text-white text-sm focus:outline-none flex-1"
          />
        </template>
        <template v-else>
          <span class="text-slate-500 text-sm">{{ t('search.add_return') }}</span>
        </template>
      </div>
    </div>

    <button 
      type="submit" 
      :disabled="loading" 
      class="btn-primary flex items-center justify-center gap-2"
    >
      <template v-if="loading">
        <svg class="animate-spin h-4 w-4" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" fill="none"/>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"/>
        </svg>
        {{ t('search.searching') }}
      </template>
      <template v-else>
        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
        </svg>
        {{ t('search.explore') }}
      </template>
    </button>
  </form>
</template>

<style scoped>
input[type="date"]::-webkit-date-and-time-value {
  text-align: left;
}
</style>
