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
      ✅ Bajo meta
    </div>
    <div 
      v-else-if="!isActive"
      class="px-2 py-1 rounded-full bg-yellow-500/20 text-yellow-400 text-xs font-medium"
    >
      ⏸️ Pausado
    </div>
  </div>
</template>
