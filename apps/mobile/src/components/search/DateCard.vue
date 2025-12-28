<script setup lang="ts">
/**
 * DateCard - Departure and return date inputs in a grouped card
 * Uses global .input-card, .input-row, .input-divider classes from index.css
 */
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()

defineProps<{
  departureDate: string
  returnDate: string
  roundTrip: boolean
}>()

const emit = defineEmits<{
  'update:departureDate': [value: string]
  'update:returnDate': [value: string]
  'update:roundTrip': [value: boolean]
}>()

const minDate = computed(() => new Date().toISOString().split('T')[0])
</script>

<template>
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
</template>
