<script setup lang="ts">
defineProps<{
  title: string
  subtitle: string
}>()
</script>

<template>
  <header class="text-center mb-8">
    <h1 class="text-3xl font-bold mb-2">{{ title }}</h1>
    <p class="text-violet-300">{{ subtitle }}</p>
  </header>
</template>
