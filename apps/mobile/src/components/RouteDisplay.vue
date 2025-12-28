<script setup lang="ts">
defineProps<{
  origin: string
  originCity: string
  destination: string
  destinationCity: string
}>()
</script>

<template>
  <div class="flex items-center justify-center gap-4 sm:gap-6 mb-4 sm:mb-6">
    <div class="text-center">
      <div class="text-2xl sm:text-3xl font-bold">{{ origin }}</div>
      <div class="text-xs sm:text-sm text-violet-300">{{ originCity }}</div>
    </div>
    <div class="text-xl sm:text-2xl text-violet-300">→</div>
    <div class="text-center">
      <div class="text-2xl sm:text-3xl font-bold">{{ destination }}</div>
      <div class="text-xs sm:text-sm text-violet-300">{{ destinationCity }}</div>
    </div>
  </div>
</template>
