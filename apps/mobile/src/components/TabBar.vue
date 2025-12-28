<script setup lang="ts">
import { useI18n } from 'vue-i18n'

const { t } = useI18n()

export type Tab = 'search' | 'saved'

defineProps<{
  activeTab: Tab
}>()

const emit = defineEmits<{
  'update:activeTab': [value: Tab]
}>()

const tabs: { id: Tab; icon: string; labelKey: string }[] = [
  { id: 'search', icon: '🔍', labelKey: 'tabs.search' },
  { id: 'saved', icon: '💾', labelKey: 'tabs.saved' }
]
</script>

<template>
  <nav class="tab-bar">
    <button
      v-for="tab in tabs"
      :key="tab.id"
      @click="emit('update:activeTab', tab.id)"
      :class="['tab-button', { 'tab-button--active': activeTab === tab.id }]"
    >
      <span class="tab-icon">{{ tab.icon }}</span>
      <span>{{ t(tab.labelKey) }}</span>
    </button>
  </nav>
</template>

<style scoped>
.tab-bar {
  display: flex;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  margin-bottom: 16px;
}

.tab-button {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  min-height: 48px;
  padding: 12px 8px;
  background: transparent;
  border: none;
  border-bottom: 2px solid transparent;
  color: rgba(255, 255, 255, 0.6);
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
}

.tab-button:hover {
  color: rgba(255, 255, 255, 0.8);
}

.tab-button:active {
  background: rgba(255, 255, 255, 0.05);
}

.tab-button--active {
  color: white;
  border-bottom-color: #a855f7;
}

.tab-icon {
  font-size: 14px;
}
</style>
