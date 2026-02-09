import type { Locale } from '@/config/site';

export interface LandingCopy {
  locale: Locale;
  seo: {
    title: string;
    description: string;
  };
  nav: {
    cta: string;
  };
  chapters: {
    hookTagline: string;
    revealTagline: string;
    proofTagline: string;
    finaleTagline: string;
  };
  hook: {
    eyebrow: string;
    title: string;
    subtitle: string;
    ctaPrimary: string;
    ctaSecondary: string;
    painChips: string[];
  };
  reveal: {
    title: string;
    body: string;
    truths: string[];
  };
  paraMap: {
    title: string;
    subtitle: string;
    whyTitle: string;
    whyBody: string;
    centerLabel: string;
    nodes: Array<{
      key: 'projects' | 'areas' | 'resources' | 'archive';
      title: string;
      body: string;
    }>;
    cta: string;
  };
  proofFlow: {
    title: string;
    subtitle: string;
    flowTitle: string;
    steps: Array<{ title: string; body: string }>;
    proofBullets: string[];
  };
  credibility: {
    title: string;
    subtitle: string;
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
  themeToggle: {
    dark: string;
    light: string;
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
