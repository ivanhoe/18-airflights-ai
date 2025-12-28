<script setup lang="ts">
import { useI18n } from 'vue-i18n'

const { t } = useI18n()

defineProps<{
  isOnline: boolean
}>()
</script>

<template>
  <Transition name="slide">
    <div v-if="!isOnline" class="offline-banner">
      <span class="offline-icon">📡</span>
      {{ t('offline_banner') }}
    </div>
  </Transition>
</template>

<style scoped>
.offline-banner {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 12px 16px;
  background: rgba(245, 158, 11, 0.2);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border-bottom: 1px solid rgba(245, 158, 11, 0.3);
  color: #fcd34d;
  font-size: 15px;
  text-align: center;
}

.offline-icon {
  font-size: 16px;
}

/* Slide animation */
.slide-enter-active,
.slide-leave-active {
  transition: all 0.3s ease;
}

.slide-enter-from,
.slide-leave-to {
  transform: translateY(-100%);
  opacity: 0;
}
</style>
