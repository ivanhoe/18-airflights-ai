import { ref, computed, onMounted } from 'vue'

/**
 * Price Watcher data types
 */
export interface PriceWatcher {
    id: string
    origin: string
    destination: string
    travelDate: string
    targetPrice: number
    currency: string
    isActive: boolean
    createdAt: string
    lastCheckedAt: string | null
    lastPrice: number | null
}

export interface PriceAlert {
    id: string
    watcherId: string
    route: string
    oldPrice: number
    newPrice: number
    isRead: boolean
    triggeredAt: string
}

export interface PriceHistoryEntry {
    id: number
    price: number
    checkedAt: string
}

// API base URL
const API_BASE = 'http://localhost:4000/api'

// Device identifier (in production, use a proper device ID)
const getDeviceId = (): string => {
    let deviceId = localStorage.getItem('device_id')
    if (!deviceId) {
        deviceId = `device_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
        localStorage.setItem('device_id', deviceId)
    }
    return deviceId
}

/**
 * Composable for managing price watchers
 * Connects to the Elixir backend API
 */
export function usePriceWatcher() {
    const watchers = ref<PriceWatcher[]>([])
    const alerts = ref<PriceAlert[]>([])
    const unreadCount = ref(0)
    const loading = ref(false)
    const error = ref<string | null>(null)

    const activeWatchers = computed(() =>
        watchers.value.filter(w => w.isActive)
    )

    const pausedWatchers = computed(() =>
        watchers.value.filter(w => !w.isActive)
    )

    /**
     * Fetch watchers from API
     */
    async function fetchWatchers(): Promise<void> {
        loading.value = true
        error.value = null

        try {
            const deviceId = getDeviceId()
            const response = await fetch(`${API_BASE}/watchers?user_identifier=${deviceId}`)
            const data = await response.json()

            if (data.success) {
                watchers.value = data.data.map(mapWatcherFromApi)
            } else {
                throw new Error(data.error || 'Failed to fetch watchers')
            }
        } catch (e) {
            error.value = e instanceof Error ? e.message : 'Failed to fetch watchers'
            console.error('[usePriceWatcher] fetchWatchers error:', e)
        } finally {
            loading.value = false
        }
    }

    /**
     * Fetch alerts from API
     */
    async function fetchAlerts(unreadOnly = false): Promise<void> {
        try {
            const deviceId = getDeviceId()
            const params = new URLSearchParams({
                user_identifier: deviceId,
                unread_only: unreadOnly.toString()
            })

            const response = await fetch(`${API_BASE}/alerts?${params}`)
            const data = await response.json()

            if (data.success) {
                alerts.value = data.data.map(mapAlertFromApi)
                unreadCount.value = data.unread_count
            }
        } catch (e) {
            console.error('[usePriceWatcher] fetchAlerts error:', e)
        }
    }

    /**
     * Create a new price watcher
     */
    async function createWatcher(
        origin: string,
        destination: string,
        travelDate: string,
        targetPrice: number
    ): Promise<string> {
        loading.value = true
        error.value = null

        try {
            const deviceId = getDeviceId()

            const response = await fetch(`${API_BASE}/watchers`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    user_identifier: deviceId,
                    origin: origin.toUpperCase(),
                    destination: destination.toUpperCase(),
                    travel_date: travelDate,
                    target_price: targetPrice,
                    currency: 'MXN'
                })
            })

            const data = await response.json()

            if (data.success) {
                const newWatcher = mapWatcherFromApi(data.data)
                watchers.value.unshift(newWatcher)
                console.log('[usePriceWatcher] Created watcher:', newWatcher.id)
                return newWatcher.id
            } else {
                throw new Error(data.error || 'Failed to create watcher')
            }
        } catch (e) {
            error.value = e instanceof Error ? e.message : 'Failed to create watcher'
            throw e
        } finally {
            loading.value = false
        }
    }

    /**
     * Pause a watcher
     */
    async function pauseWatcher(id: string): Promise<void> {
        try {
            const response = await fetch(`${API_BASE}/watchers/${id}/pause`, {
                method: 'POST'
            })
            const data = await response.json()

            if (data.success) {
                const index = watchers.value.findIndex(w => w.id === id)
                if (index !== -1) {
                    watchers.value[index].isActive = false
                }
            }
        } catch (e) {
            console.error('[usePriceWatcher] pauseWatcher error:', e)
        }
    }

    /**
     * Resume a watcher
     */
    async function resumeWatcher(id: string): Promise<void> {
        try {
            const response = await fetch(`${API_BASE}/watchers/${id}/resume`, {
                method: 'POST'
            })
            const data = await response.json()

            if (data.success) {
                const index = watchers.value.findIndex(w => w.id === id)
                if (index !== -1) {
                    watchers.value[index].isActive = true
                }
            }
        } catch (e) {
            console.error('[usePriceWatcher] resumeWatcher error:', e)
        }
    }

    /**
     * Toggle watcher active state
     */
    async function toggleWatcher(id: string): Promise<void> {
        const watcher = watchers.value.find(w => w.id === id)
        if (watcher) {
            if (watcher.isActive) {
                await pauseWatcher(id)
            } else {
                await resumeWatcher(id)
            }
        }
    }

    /**
     * Delete a watcher
     */
    async function deleteWatcher(id: string): Promise<void> {
        try {
            const response = await fetch(`${API_BASE}/watchers/${id}`, {
                method: 'DELETE'
            })
            const data = await response.json()

            if (data.success) {
                const index = watchers.value.findIndex(w => w.id === id)
                if (index !== -1) {
                    watchers.value.splice(index, 1)
                }
                console.log('[usePriceWatcher] Deleted watcher:', id)
            }
        } catch (e) {
            console.error('[usePriceWatcher] deleteWatcher error:', e)
        }
    }

    /**
     * Get price history for a watcher
     */
    async function getPriceHistory(watcherId: string): Promise<PriceHistoryEntry[]> {
        try {
            const response = await fetch(`${API_BASE}/watchers/${watcherId}/history`)
            const data = await response.json()

            if (data.success) {
                return data.data.map((entry: any) => ({
                    id: entry.id,
                    price: entry.price,
                    checkedAt: entry.checked_at
                }))
            }
            return []
        } catch (e) {
            console.error('[usePriceWatcher] getPriceHistory error:', e)
            return []
        }
    }

    /**
     * Mark an alert as read
     */
    async function markAlertRead(alertId: string): Promise<void> {
        try {
            await fetch(`${API_BASE}/alerts/${alertId}/read`, { method: 'POST' })

            const index = alerts.value.findIndex(a => a.id === alertId)
            if (index !== -1) {
                alerts.value[index].isRead = true
                unreadCount.value = Math.max(0, unreadCount.value - 1)
            }
        } catch (e) {
            console.error('[usePriceWatcher] markAlertRead error:', e)
        }
    }

    /**
     * Check if price is below target
     */
    function isPriceBelowTarget(watcher: PriceWatcher): boolean {
        return watcher.lastPrice !== null && watcher.lastPrice < watcher.targetPrice
    }

    /**
     * Calculate price trend (mock for now, would need history)
     */
    function getPriceTrend(watcher: PriceWatcher): { direction: 'up' | 'down' | 'stable', percent: number } {
        // TODO: Calculate from price history
        if (watcher.lastPrice === null) {
            return { direction: 'stable', percent: 0 }
        }

        const diff = watcher.lastPrice - watcher.targetPrice
        const percent = Math.abs(diff / watcher.targetPrice * 100)

        return {
            direction: diff < 0 ? 'down' : diff > 0 ? 'up' : 'stable',
            percent
        }
    }

    /**
     * Format relative time
     */
    function formatTimeAgo(dateString: string | null): string {
        if (!dateString) return 'Nunca'

        const date = new Date(dateString)
        const now = new Date()
        const diffMs = now.getTime() - date.getTime()
        const diffMins = Math.floor(diffMs / 60000)
        const diffHours = Math.floor(diffMins / 60)
        const diffDays = Math.floor(diffHours / 24)

        if (diffMins < 60) return `hace ${diffMins}m`
        if (diffHours < 24) return `hace ${diffHours}h`
        return `hace ${diffDays}d`
    }

    // Map API response to our interface
    function mapWatcherFromApi(data: any): PriceWatcher {
        return {
            id: data.id,
            origin: data.origin,
            destination: data.destination,
            travelDate: data.travel_date,
            targetPrice: data.target_price,
            currency: data.currency,
            isActive: data.is_active,
            createdAt: data.created_at,
            lastCheckedAt: data.last_checked_at,
            lastPrice: data.last_price
        }
    }

    function mapAlertFromApi(data: any): PriceAlert {
        return {
            id: data.id,
            watcherId: data.watcher_id,
            route: data.route,
            oldPrice: data.old_price,
            newPrice: data.new_price,
            isRead: data.is_read,
            triggeredAt: data.triggered_at
        }
    }

    // Fetch data on mount
    onMounted(() => {
        fetchWatchers()
        fetchAlerts()
    })

    return {
        watchers,
        alerts,
        unreadCount,
        activeWatchers,
        pausedWatchers,
        loading,
        error,
        fetchWatchers,
        fetchAlerts,
        createWatcher,
        toggleWatcher,
        pauseWatcher,
        resumeWatcher,
        deleteWatcher,
        getPriceHistory,
        markAlertRead,
        isPriceBelowTarget,
        getPriceTrend,
        formatTimeAgo
    }
}
