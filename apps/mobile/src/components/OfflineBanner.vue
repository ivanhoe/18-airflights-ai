<script setup lang="ts">
/**
 * OfflineBanner - Displays a warning banner when the device is offline
 * Uses global .offline-banner and .slide-* classes from index.css
 */
import { useI18n } from 'vue-i18n'

const { t } = useI18n()

defineProps<{
  isOnline: boolean
}>()
</script>

<template>
  <Transition name="slide">
    <div v-if="!isOnline" class="offline-banner">
      <span class="text-base">📡</span>
      {{ t('offline_banner') }}
    </div>
  </Transition>
</template>
