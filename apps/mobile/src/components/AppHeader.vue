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
  <header class="text-center mb-8 relative">
    <button 
      @click="toggleLanguage"
      class="absolute top-0 right-0 p-2 text-2xl hover:scale-110 transition-transform cursor-pointer bg-white/5 rounded-full backdrop-blur-sm"
      :title="locale === 'es' ? 'Switch to English' : 'Cambiar a Español'"
    >
      {{ locale === 'es' ? '🇲🇽' : '🇺🇸' }}
    </button>
    <h1 class="text-3xl font-bold mb-2">{{ title }}</h1>
    <p class="text-violet-300">{{ subtitle }}</p>
  </header>
</template>
