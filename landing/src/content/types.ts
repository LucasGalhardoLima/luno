import type { Locale } from '@/config/site';

export interface LandingCopy {
  locale: Locale;
  seo: {
    title: string;
    description: string;
  };
  nav: {
    languageLabel: string;
    cta: string;
  };
  hero: {
    eyebrow: string;
    title: string;
    subtitle: string;
    ctaPrimary: string;
    ctaSecondary: string;
  };
  problem: {
    title: string;
    body: string;
  };
  solution: {
    title: string;
    bullets: string[];
  };
  steps: {
    title: string;
    items: Array<{ title: string; body: string }>;
  };
  credibility: {
    title: string;
    badges: string[];
  };
  waitlist: {
    title: string;
    subtitle: string;
    emailLabel: string;
    emailPlaceholder: string;
    submit: string;
    pending: string;
    success: string;
    error: string;
    privacyHint: string;
  };
  footer: {
    privacy: string;
    contact: string;
    rights: string;
  };
  privacyPage: {
    title: string;
    updatedAt: string;
    intro: string;
    items: Array<{ title: string; body: string }>;
    back: string;
  };
}
