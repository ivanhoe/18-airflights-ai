<script setup lang="ts">
defineProps<{
  message: string
}>()
</script>

<template>
  <div class="mt-4 p-4 bg-red-500/20 backdrop-blur-md border border-red-500/50 rounded-2xl text-red-300 text-[15px]">
    <span class="text-lg mr-2">⚠️</span>{{ message }}
  </div>
</template>
