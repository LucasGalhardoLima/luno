export type Locale = 'pt-BR' | 'en-US';

export interface SiteConfig {
  siteName: string;
  defaultLocale: Locale;
  waitlistProvider: 'formspree' | 'custom';
  waitlistActionUrl: string;
  analyticsEnabled: boolean;
}

export const siteConfig: SiteConfig = {
  siteName: 'Luno',
  defaultLocale: 'pt-BR',
  waitlistProvider: 'formspree',
  waitlistActionUrl:
    import.meta.env.PUBLIC_WAITLIST_ACTION_URL ||
    'https://formspree.io/f/your_form_id',
  analyticsEnabled: (import.meta.env.PUBLIC_ANALYTICS_ENABLED || 'true') === 'true',
};

export const siteOrigin = import.meta.env.SITE || 'https://luno.app';
