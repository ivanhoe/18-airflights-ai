import { ref, watch, type Ref } from 'vue'

export type Tab = 'search' | 'watchers'

/**
 * Composable for tab navigation with offline-aware behavior
 */
export function useNavigation(isOnline: Ref<boolean>) {
    const activeTab = ref<Tab>('search')

    // Auto-switch to watchers when going offline (can view cached alerts)
    watch(isOnline, (online) => {
        if (!online && activeTab.value === 'search') {
            activeTab.value = 'watchers'
        }
    })

    function goToSearch() {
        activeTab.value = 'search'
    }

    function goToWatchers() {
        activeTab.value = 'watchers'
    }

    return {
        activeTab,
        goToSearch,
        goToWatchers
    }
}
