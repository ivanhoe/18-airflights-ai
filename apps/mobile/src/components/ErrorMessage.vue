<script setup lang="ts">
defineProps<{
  message: string
}>()
</script>

<template>
  <div class="mt-4 p-3 bg-red-500/20 border border-red-500/50 rounded-xl text-red-300">
    ⚠️ {{ message }}
  </div>
</template>
