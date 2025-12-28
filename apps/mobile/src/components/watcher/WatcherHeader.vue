<script setup lang="ts">
/**
 * WatcherHeader - Displays route and status badge for a watcher
 */
defineProps<{
  origin: string
  destination: string
  isActive: boolean
  isPriceBelowTarget: boolean
}>()
</script>

<template>
  <div class="flex items-center justify-between mb-3">
    <div class="flex items-center gap-2">
      <span class="text-xl">✈️</span>
      <span class="text-lg font-semibold text-white">
        {{ origin }} → {{ destination }}
      </span>
    </div>
    <div 
      v-if="isPriceBelowTarget"
      class="px-2 py-1 rounded-full bg-green-500/20 text-green-400 text-xs font-medium"
    >
<<<<<<< HEAD
      ✅ Bajo meta
=======
      ✅ Below target
>>>>>>> 6df403d (feat(mobile): add watcher sub-components for single responsibility)
    </div>
    <div 
      v-else-if="!isActive"
      class="px-2 py-1 rounded-full bg-yellow-500/20 text-yellow-400 text-xs font-medium"
    >
<<<<<<< HEAD
      ⏸️ Pausado
=======
      ⏸️ Paused
>>>>>>> 6df403d (feat(mobile): add watcher sub-components for single responsibility)
    </div>
  </div>
</template>
