<script setup lang="ts">
/**
 * TripOptionsChips - Row of trip option chips (type, passengers, class)
 * Uses global .chip classes from index.css
 */
import { useI18n } from 'vue-i18n'

const { t } = useI18n()

defineProps<{
  roundTrip: boolean
}>()

const emit = defineEmits<{
  'update:roundTrip': [value: boolean]
}>()
</script>

<template>
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
</template>
