<script setup lang="ts">
/**
 * SavedView - Displays saved flights for offline access
 * 
 * This view component shows all flights that have been saved locally
 * in the SQLite database. It allows users to access their saved searches
 * even when offline.
 */
import AppHeader from '../components/AppHeader.vue'
import SavedFlights from '../components/SavedFlights.vue'
</script>

<template>
  <div>
    <AppHeader
      :title="'💾 ' + $t('tabs.saved')"
      :subtitle="$t('search.saved_flights')"
    />
    <SavedFlights />
  </div>
</template>
