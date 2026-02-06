import type { SiteConfig } from '@/config/site';

export type LandingEventName =
  | 'landing_view'
  | 'hero_cta_click'
  | 'waitlist_submit_start'
  | 'waitlist_submit_success'
  | 'waitlist_submit_error'
  | 'language_switch';

export type AnalyticsPayload = Record<string, string | number | boolean | null>;

export function trackEvent(
  config: SiteConfig,
  eventName: LandingEventName,
  payload: AnalyticsPayload = {}
): void {
  if (!config.analyticsEnabled || typeof window === 'undefined') {
    return;
  }

  const dataLayer = ((window as unknown as { dataLayer?: unknown[] }).dataLayer ??= []);
  const event = {
    event: eventName,
    timestamp: Date.now(),
    ...payload,
  };

  dataLayer.push(event);
  window.dispatchEvent(new CustomEvent('luno:analytics', { detail: event }));
}
