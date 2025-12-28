<script setup lang="ts">
/**
 * DateInput - Reusable date input component
 * Uses global .select-wrapper classes from index.css
 */
import { computed } from 'vue'

const props = defineProps<{
  modelValue: string
  minDate?: string
  placeholder?: string
  disabled?: boolean
}>()

const emit = defineEmits<{
  'update:modelValue': [value: string]
}>()

const defaultMinDate = computed(() => {
  return props.minDate || new Date().toISOString().split('T')[0]
})
</script>

<template>
  <div 
    class="select-wrapper"
    :class="{ 'opacity-50 pointer-events-none': disabled }"
  >
    <!-- Calendar Icon -->
    <svg xmlns="http://www.w3.org/2000/svg" class="select-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
        d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
    </svg>
    
    <!-- Date Input -->
    <input
      type="date"
      :value="modelValue"
      :min="defaultMinDate"
      :disabled="disabled"
      @input="emit('update:modelValue', ($event.target as HTMLInputElement).value)"
      class="input-date"
    />
  </div>
</template>
