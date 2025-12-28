<script setup lang="ts">
/**
 * WatcherActions - Action buttons for a watcher (history, toggle, delete)
 */
defineProps<{
  isActive: boolean
}>()

const emit = defineEmits<{
  viewHistory: []
  toggle: []
  delete: []
}>()
</script>

<template>
  <div class="flex gap-2">
    <button
      @click="emit('viewHistory')"
      class="flex-1 py-2.5 rounded-xl text-sm font-medium
             bg-white/10 text-white/80 hover:bg-white/20
             transition-all duration-200 active:scale-[0.98]"
    >
<<<<<<< HEAD
      📊 Historial
=======
      📊 History
>>>>>>> 6df403d (feat(mobile): add watcher sub-components for single responsibility)
    </button>
    <button
      @click="emit('toggle')"
      class="flex-1 py-2.5 rounded-xl text-sm font-medium transition-all duration-200 active:scale-[0.98]"
      :class="isActive 
        ? 'bg-yellow-500/20 text-yellow-400 hover:bg-yellow-500/30' 
        : 'bg-green-500/20 text-green-400 hover:bg-green-500/30'"
    >
<<<<<<< HEAD
      {{ isActive ? '⏸️ Pausar' : '▶️ Reanudar' }}
=======
      {{ isActive ? '⏸️ Pause' : '▶️ Resume' }}
>>>>>>> 6df403d (feat(mobile): add watcher sub-components for single responsibility)
    </button>
    <button
      @click="emit('delete')"
      class="py-2.5 px-4 rounded-xl text-sm font-medium
             bg-red-500/20 text-red-400 hover:bg-red-500/30
             transition-all duration-200 active:scale-[0.98]"
    >
      🗑️
    </button>
  </div>
</template>
