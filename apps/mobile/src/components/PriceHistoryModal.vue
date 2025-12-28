<script setup lang="ts">
/**
 * PriceHistoryModal - Bottom sheet modal for displaying price history
 * Uses global .modal-backdrop, .modal-sheet, .modal-handle classes from index.css
 */
import type { PriceWatcher, PriceHistoryEntry } from '../composables/usePriceWatcher'
import { PriceDisplay } from './display'
import { formatDateTime } from '../composables'

defineProps<{
  show: boolean
  watcher: PriceWatcher | null
  history: PriceHistoryEntry[]
  loading: boolean
}>()

const emit = defineEmits<{
  close: []
}>()
</script>

<template>
  <Teleport to="body">
    <div
      v-if="show && watcher"
      class="fixed inset-0 z-50 flex items-end justify-center"
      @click.self="emit('close')"
    >
      <!-- Backdrop -->
      <div class="modal-backdrop" @click="emit('close')" />

      <!-- Modal Content -->
      <div class="modal-sheet">
        <!-- Handle -->
        <div class="modal-handle" />

        <!-- Header -->
        <div class="flex items-center justify-between mb-6 mt-2">
          <h3 class="text-lg font-semibold text-white flex items-center gap-2">
            📊 Historial: {{ watcher.origin }} → {{ watcher.destination }}
          </h3>
          <button
            @click="emit('close')"
            class="p-2 rounded-full hover:bg-white/10 transition-colors"
          >
            ✕
          </button>
        </div>

        <!-- Target Price Line -->
        <div class="flex items-center gap-2 text-sm text-white/60 mb-4 px-2">
          <span>🎯</span>
          <span>Meta: <PriceDisplay :price="watcher.targetPrice" :currency="watcher.currency" size="sm" /></span>
        </div>

        <!-- Loading -->
        <div v-if="loading" class="text-center py-8 text-white/40">
          ⏳ Cargando historial...
        </div>

        <!-- Price History List -->
        <div v-else class="space-y-2 max-h-80 overflow-y-auto">
          <div
            v-for="point in history"
            :key="point.id"
            class="flex items-center justify-between p-3 rounded-xl"
            :class="point.price < watcher.targetPrice ? 'bg-green-500/10' : 'bg-white/5'"
          >
            <div class="text-sm text-white/60">
              {{ formatDateTime(point.checkedAt) }}
            </div>
            <div class="flex items-center gap-2">
              <PriceDisplay 
                :price="point.price" 
                :currency="watcher.currency" 
                size="md"
                :highlight="point.price < watcher.targetPrice"
              />
              <span v-if="point.price < watcher.targetPrice">✅</span>
            </div>
          </div>

          <!-- Empty history -->
          <div v-if="history.length === 0" class="text-center py-8 text-white/40">
            Sin historial de precios aún
          </div>
        </div>
      </div>
    </div>
  </Teleport>
</template>
