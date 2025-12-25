import { createI18n } from "vue-i18n";
import en from "./locales/en.json";
import es from "./locales/es.json";

// Type-define 'en' as the master schema for the resource
type MessageSchema = typeof en;

const i18n = createI18n<[MessageSchema], "en" | "es">({
    legacy: false, // Use Composition API mode
    locale: "es", // Default to Spanish for demonstration
    fallbackLocale: "en",
    messages: {
        en,
        es,
    },
});

export default i18n;
