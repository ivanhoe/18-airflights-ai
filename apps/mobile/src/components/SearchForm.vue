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
  <form @submit.prevent="handleSubmit" class="form">
    <div class="field">
      <label>Departure Date</label>
      <input
        type="date"
        :value="modelValue"
        @input="emit('update:modelValue', ($event.target as HTMLInputElement).value)"
        :min="minDate"
      />
    </div>

    <button type="submit" :disabled="loading" class="search-btn">
      <span v-if="loading">⏳ Searching...</span>
      <span v-else>🔍 Find Cheapest Flight</span>
    </button>
  </form>
</template>

<style scoped>
.form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.field label {
  display: block;
  font-size: 0.9rem;
  color: var(--text-secondary);
  margin-bottom: 0.5rem;
}

.field input {
  width: 100%;
  padding: 0.875rem 1rem;
  background: rgba(255, 255, 255, 0.15);
  border: 1px solid rgba(255, 255, 255, 0.4);
  border-radius: 0.75rem;
  color: var(--text-primary);
  font-size: 1rem;
  -webkit-appearance: none;
  appearance: none;
}

.field input:focus {
  outline: none;
  border-color: #a78bfa;
  background: rgba(255, 255, 255, 0.2);
}

/* iOS date input fix */
.field input[type="date"]::-webkit-date-and-time-value {
  text-align: left;
}

.search-btn {
  padding: 1rem;
  background: var(--accent);
  border: none;
  border-radius: 0.75rem;
  color: white;
  font-size: 1.1rem;
  font-weight: bold;
  cursor: pointer;
  transition: transform 0.2s, opacity 0.2s;
}

.search-btn:hover:not(:disabled) {
  transform: scale(1.02);
}

.search-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>
