import type { Locale } from '@/config/site';

export function inferLocale(language: string | undefined, fallback: Locale): Locale {
  if (!language) {
    return fallback;
  }

  const normalized = language.toLowerCase();
  if (normalized.startsWith('pt')) {
    return 'pt-BR';
  }
  if (normalized.startsWith('en')) {
    return 'en-US';
  }

  return fallback;
}
