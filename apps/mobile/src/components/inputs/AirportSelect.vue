<script setup lang="ts">
/**
 * AirportSelect - Reusable airport dropdown component
 * Uses global .select-wrapper classes from index.css
 */
import { airports } from '../../constants'

defineProps<{
  modelValue: string
  label?: string
  icon?: string
}>()

const emit = defineEmits<{
  'update:modelValue': [value: string]
}>()
</script>

<template>
  <div class="select-wrapper">
    <!-- Icon -->
    <svg 
      v-if="icon === 'departure'" 
      xmlns="http://www.w3.org/2000/svg" 
      class="select-icon" 
      fill="none" 
      viewBox="0 0 24 24" 
      stroke="currentColor"
    >
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
        d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" />
    </svg>
    <svg 
      v-else-if="icon === 'arrival'" 
      xmlns="http://www.w3.org/2000/svg" 
      class="select-icon" 
      fill="none" 
      viewBox="0 0 24 24" 
      stroke="currentColor"
    >
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
        d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
        d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
    </svg>
    
    <!-- Select -->
    <select
      :value="modelValue"
      @change="emit('update:modelValue', ($event.target as HTMLSelectElement).value)"
      class="select-input"
    >
      <option 
        v-for="airport in airports" 
        :key="airport.code" 
        :value="airport.code"
      >
        {{ airport.code }} - {{ airport.name }}
      </option>
    </select>
    
    <!-- Caret -->
    <svg xmlns="http://www.w3.org/2000/svg" class="caret-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
    </svg>
  </div>
</template>
