<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  modelValue: string
  loading: boolean
}>()

const emit = defineEmits<{
  'update:modelValue': [value: string]
  search: []
}>()

const minDate = computed(() => new Date().toISOString().split('T')[0])

function handleSubmit() {
  emit('search')
}
</script>

<template>
  <form @submit.prevent="handleSubmit" class="flex flex-col gap-4">
    <div>
      <label class="block text-sm text-violet-300 mb-2">Departure Date</label>
      <input
        type="date"
        :value="modelValue"
        @input="emit('update:modelValue', ($event.target as HTMLInputElement).value)"
        :min="minDate"
        class="input-field"
      />
    </div>

    <button 
      type="submit" 
      :disabled="loading" 
      class="btn-primary"
    >
      <span v-if="loading">⏳ Searching...</span>
      <span v-else>🔍 Find Cheapest Flight</span>
    </button>
  </form>
</template>

<style scoped>
/* iOS date input fix */
input[type="date"]::-webkit-date-and-time-value {
  text-align: left;
}
</style>
