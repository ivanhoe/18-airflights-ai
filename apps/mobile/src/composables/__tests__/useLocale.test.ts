/**
 * Tests for useLocale composable
 */
import { describe, it, expect, vi, beforeEach } from 'vitest'

// Mock vue-i18n
const mockLocale = { value: 'es' }
vi.mock('vue-i18n', () => ({
    useI18n: () => ({
        locale: mockLocale
    })
}))

import { useLocale } from '../useLocale'

describe('useLocale', () => {
    beforeEach(() => {
        mockLocale.value = 'es'
    })

    it('returns current locale', () => {
        const { currentLocale } = useLocale()
        expect(currentLocale.value).toBe('es')
    })

    it('isSpanish computed returns true when locale is es', () => {
        const { isSpanish } = useLocale()
        expect(isSpanish.value).toBe(true)
    })

    it('isSpanish computed returns false when locale is en', () => {
        mockLocale.value = 'en'
        const { isSpanish } = useLocale()
        expect(isSpanish.value).toBe(false)
    })

    it('flagEmoji returns 🇲🇽 for Spanish', () => {
        const { flagEmoji } = useLocale()
        expect(flagEmoji.value).toBe('🇲🇽')
    })

    it('flagEmoji returns 🇺🇸 for English', () => {
        mockLocale.value = 'en'
        const { flagEmoji } = useLocale()
        expect(flagEmoji.value).toBe('🇺🇸')
    })

    it('toggleTooltip returns correct text for Spanish', () => {
        const { toggleTooltip } = useLocale()
        expect(toggleTooltip.value).toBe('Switch to English')
    })

    it('toggleTooltip returns correct text for English', () => {
        mockLocale.value = 'en'
        const { toggleTooltip } = useLocale()
        expect(toggleTooltip.value).toBe('Cambiar a Español')
    })

    it('toggleLanguage switches from es to en', () => {
        const { toggleLanguage } = useLocale()
        toggleLanguage()
        expect(mockLocale.value).toBe('en')
    })

    it('toggleLanguage switches from en to es', () => {
        mockLocale.value = 'en'
        const { toggleLanguage } = useLocale()
        toggleLanguage()
        expect(mockLocale.value).toBe('es')
    })

    it('setLocale sets specific locale', () => {
        const { setLocale } = useLocale()
        setLocale('en')
        expect(mockLocale.value).toBe('en')
    })
})
