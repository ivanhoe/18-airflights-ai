<script setup lang="ts">
/**
 * WatcherForm - Form to create a new price watcher
 * Uses global .price-input-wrapper classes from index.css
 */
import { ref } from 'vue'
import { AirportSelect, DateInput } from './inputs'

const emit = defineEmits<{
  (e: 'create', data: {
    origin: string
    destination: string
    travelDate: string
    targetPrice: number
  }): void
}>()

defineProps<{
  loading?: boolean
}>()

const origin = ref('MEX')
const destination = ref('VIE')
const travelDate = ref(getDefaultDate())
const targetPrice = ref(9000)

function getDefaultDate(): string {
  const date = new Date()
  date.setDate(date.getDate() + 30)
  return date.toISOString().split('T')[0]
}

function handleSubmit() {
  emit('create', {
    origin: origin.value,
    destination: destination.value,
    travelDate: travelDate.value,
    targetPrice: targetPrice.value
  })
}
</script>

<template>
  <div class="card">
    <h3 class="text-lg font-semibold text-white mb-4 flex items-center gap-2">
      <span class="text-xl">➕</span>
      {{ $t('watchers.new_watcher') || 'Nuevo Price Watcher' }}
    </h3>

    <form @submit.prevent="handleSubmit" class="space-y-4">
      <!-- Origin & Destination -->
      <div class="grid grid-cols-2 gap-3">
        <div>
          <label class="block text-sm text-white/60 mb-1.5">
            {{ $t('search.origin_label') || 'Origen' }}
          </label>
          <AirportSelect v-model="origin" icon="departure" />
        </div>
        <div>
          <label class="block text-sm text-white/60 mb-1.5">
            {{ $t('search.destination_label') || 'Destino' }}
          </label>
          <AirportSelect v-model="destination" icon="arrival" />
        </div>
      </div>

      <!-- Travel Date -->
      <div>
        <label class="block text-sm text-white/60 mb-1.5">
          {{ $t('search.date_label') || 'Fecha de viaje' }}
        </label>
        <DateInput v-model="travelDate" />
      </div>

      <!-- Target Price -->
      <div>
        <label class="block text-sm text-white/60 mb-1.5">
          🎯 {{ $t('watchers.target_price') || 'Precio objetivo' }}
        </label>
        <div class="price-input-wrapper">
          <span class="currency-label">$</span>
          <input
            v-model.number="targetPrice"
            type="number"
            min="0"
            step="100"
            class="price-input"
            placeholder="9000"
          />
          <span class="currency-label">MXN</span>
        </div>
      </div>

      <!-- Submit Button -->
      <button
        type="submit"
        :disabled="loading"
        class="w-full py-3.5 rounded-xl font-semibold text-white transition-all duration-200
               bg-gradient-to-r from-amber-500 to-orange-500 
               hover:from-amber-400 hover:to-orange-400
               active:scale-[0.98]
               disabled:opacity-50 disabled:cursor-not-allowed
               flex items-center justify-center gap-2"
      >
        <span v-if="loading" class="animate-spin">⏳</span>
        <span v-else>🔔</span>
        {{ $t('watchers.start_watching') || 'Activar Alertas de Precio' }}
      </button>
    </form>
  </div>
</template>
