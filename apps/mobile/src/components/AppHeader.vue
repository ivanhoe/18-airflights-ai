<script setup lang="ts">
import { useI18n } from 'vue-i18n'

defineProps<{
  title: string
  subtitle: string
}>()

const { locale } = useI18n()

function toggleLanguage() {
  locale.value = locale.value === 'es' ? 'en' : 'es'
}
</script>

<template>
  <header class="text-center mb-6 relative px-2">
    <button
      @click="toggleLanguage"
      class="absolute top-0 right-0 min-w-[48px] min-h-[48px] flex items-center justify-center text-2xl hover:scale-110 active:scale-95 transition-transform cursor-pointer bg-white/[0.06] backdrop-blur-md rounded-full border border-white/[0.1]"
      :title="locale === 'es' ? 'Switch to English' : 'Cambiar a Español'"
    >
      {{ locale === 'es' ? '🇲🇽' : '🇺🇸' }}
    </button>
    <h1 class="text-3xl font-bold mb-2 pr-14" style="letter-spacing: -0.02em;">{{ title }}</h1>
    <p class="text-white/60 text-[15px]">{{ subtitle }}</p>
  </header>
</template>
