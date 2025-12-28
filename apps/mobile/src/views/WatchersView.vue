<script setup lang="ts">
/**
 * WatchersView - Main view for managing price watchers
 * 
 * This view allows users to create and manage price alerts for flight routes.
 * It displays active watchers with their current status and price trends.
 */
import { ref } from 'vue'
import { usePriceWatcher, type PriceWatcher, type PriceHistoryEntry } from '../composables/usePriceWatcher'

import AppHeader from '../components/AppHeader.vue'
import WatcherForm from '../components/WatcherForm.vue'
import WatcherCard from '../components/WatcherCard.vue'
import PriceHistoryModal from '../components/PriceHistoryModal.vue'

const {
  watchers,
  loading,
  createWatcher,
  toggleWatcher,
  deleteWatcher,
  getPriceHistory,
  isPriceBelowTarget,
  getPriceTrend,
  formatTimeAgo
} = usePriceWatcher()

const selectedWatcher = ref<PriceWatcher | null>(null)
const selectedHistory = ref<PriceHistoryEntry[]>([])
const showHistoryModal = ref(false)
const loadingHistory = ref(false)

async function handleCreateWatcher(data: {
  origin: string
  destination: string
  travelDate: string
  targetPrice: number
}) {
  await createWatcher(
    data.origin,
    data.destination,
    data.travelDate,
    data.targetPrice
  )
}

async function handleViewHistory(watcher: PriceWatcher) {
  selectedWatcher.value = watcher
  showHistoryModal.value = true
  loadingHistory.value = true
  
  try {
    selectedHistory.value = await getPriceHistory(watcher.id)
  } finally {
    loadingHistory.value = false
  }
}

function closeHistoryModal() {
  showHistoryModal.value = false
  selectedWatcher.value = null
  selectedHistory.value = []
}
</script>

<template>
  <div>
    <AppHeader
      :title="'🔔 ' + ($t('tabs.watchers') || 'Price Watchers')"
      :subtitle="$t('watchers.subtitle') || 'Recibe alertas cuando bajen los precios'"
    />

    <!-- Create Form -->
    <WatcherForm
      :loading="loading"
      @create="handleCreateWatcher"
    />

    <!-- Active Watchers Section -->
    <div v-if="watchers.length > 0" class="mt-6">
      <h3 class="text-sm font-semibold text-white/60 uppercase tracking-wider mb-3 px-1">
        📡 {{ $t('watchers.active_monitors') || 'Monitores Activos' }} ({{ watchers.length }})
      </h3>

      <div class="space-y-4">
        <WatcherCard
          v-for="watcher in watchers"
          :key="watcher.id"
          :watcher="watcher"
          :is-price-below-target="isPriceBelowTarget(watcher)"
          :trend="getPriceTrend(watcher)"
          :last-checked-ago="formatTimeAgo(watcher.lastCheckedAt)"
          @toggle="toggleWatcher"
          @delete="deleteWatcher"
          @view-history="handleViewHistory"
        />
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="mt-8 text-center">
      <div class="text-4xl mb-4">🔕</div>
      <p class="text-white/60">
        {{ $t('watchers.empty_state') || 'No tienes alertas configuradas' }}
      </p>
      <p class="text-white/40 text-sm mt-1">
        {{ $t('watchers.empty_hint') || 'Crea una alerta arriba para recibir notificaciones' }}
      </p>
    </div>

    <!-- Price History Modal -->
    <PriceHistoryModal
      :show="showHistoryModal"
      :watcher="selectedWatcher"
      :history="selectedHistory"
      :loading="loadingHistory"
      @close="closeHistoryModal"
    />
  </div>
</template>
