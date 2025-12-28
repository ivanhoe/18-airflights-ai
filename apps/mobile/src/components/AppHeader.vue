<script setup lang="ts">
/**
 * AppHeader - App header with title, subtitle, and language toggle
 * Uses useLocale composable for language switching.
 */
import { useLocale } from '../composables/useLocale'

defineProps<{
  title: string
  subtitle: string
}>()

const { flagEmoji, toggleTooltip, toggleLanguage } = useLocale()
</script>

<template>
  <header class="text-center mb-6 relative px-2">
    <button
      @click="toggleLanguage"
      class="absolute top-0 right-0 min-w-[48px] min-h-[48px] flex items-center justify-center text-2xl hover:scale-110 active:scale-95 transition-transform cursor-pointer bg-white/[0.06] backdrop-blur-md rounded-full border border-white/[0.1]"
      :title="toggleTooltip"
    >
      {{ flagEmoji }}
    </button>
    <h1 class="text-3xl font-bold mb-2 pr-14" style="letter-spacing: -0.02em;">{{ title }}</h1>
    <p class="text-white/60 text-[15px]">{{ subtitle }}</p>
  </header>
</template>
