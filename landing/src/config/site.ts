export type Locale = 'pt-BR' | 'en-US';

export interface SiteConfig {
  siteName: string;
  defaultLocale: Locale;
  waitlistProvider: 'convertkit';
  waitlistActionUrl: string;
  analyticsEnabled: boolean;
}

export const siteConfig: SiteConfig = {
  siteName: 'Luno',
  defaultLocale: 'pt-BR',
  waitlistProvider: 'convertkit',
  waitlistActionUrl:
    import.meta.env.PUBLIC_WAITLIST_ACTION_URL ||
    'https://app.convertkit.com/forms/0000000/subscriptions',
  analyticsEnabled: (import.meta.env.PUBLIC_ANALYTICS_ENABLED || 'true') === 'true',
};

export const siteOrigin = import.meta.env.SITE || 'https://luno.app';
