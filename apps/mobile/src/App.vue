<script setup lang="ts">
import { useNetworkStatus, useDatabase, useNavigation } from './composables'

// Layout Components
import TabBar from './components/TabBar.vue'
import OfflineBanner from './components/OfflineBanner.vue'
import AppFooter from './components/AppFooter.vue'

// Views
import SearchView from './views/SearchView.vue'
import SavedView from './views/SavedView.vue'

// Initialize composables
const { isOnline } = useNetworkStatus()
const { activeTab } = useNavigation(isOnline)

// Initialize database (auto-runs on mount)
useDatabase()
</script>

<template>
  <div class="max-w-lg mx-auto min-h-dvh flex flex-col safe-area-inset">
    <!-- Offline Banner -->
    <OfflineBanner :is-online="isOnline" />

    <!-- Navigation Tabs -->
    <TabBar v-model:active-tab="activeTab" />

    <!-- Main Content -->
    <div class="flex-1 px-4">
      <SearchView v-if="activeTab === 'search'" />
      <SavedView v-else />
    </div>

    <!-- Footer -->
    <AppFooter />
  </div>
</template>