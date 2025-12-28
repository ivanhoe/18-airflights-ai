import { ref, watch, type Ref } from 'vue'

export type Tab = 'search' | 'saved'

/**
 * Composable for tab navigation with offline-aware behavior
 */
export function useNavigation(isOnline: Ref<boolean>) {
    const activeTab = ref<Tab>('search')

    // Auto-switch to saved flights when going offline
    watch(isOnline, (online) => {
        if (!online && activeTab.value === 'search') {
            activeTab.value = 'saved'
        }
    })

    function goToSearch() {
        activeTab.value = 'search'
    }

    function goToSaved() {
        activeTab.value = 'saved'
    }

    return {
        activeTab,
        goToSearch,
        goToSaved
    }
}
