import { describe, expect, it } from 'vitest';

import { siteConfig } from '../src/config/site';
import { inferLocale } from '../src/lib/i18n';
import { readUtmParams } from '../src/lib/utm';

describe('locale inference', () => {
  it('returns pt-BR for Portuguese navigator language', () => {
    expect(inferLocale('pt-PT', 'en-US')).toBe('pt-BR');
  });

  it('falls back when locale is unsupported', () => {
    expect(inferLocale('es-ES', 'pt-BR')).toBe('pt-BR');
  });
});

describe('utm parser', () => {
  it('extracts known campaign params', () => {
    const params = new URLSearchParams('utm_source=x&utm_campaign=y&fbclid=123');
    expect(readUtmParams(params)).toEqual({
      utm_source: 'x',
      utm_campaign: 'y',
      fbclid: '123',
    });
  });
});

describe('site config contract', () => {
  it('contains required waitlist and analytics fields', () => {
    expect(siteConfig.siteName.length).toBeGreaterThan(0);
    expect(siteConfig.defaultLocale).toBe('pt-BR');
    expect(siteConfig.waitlistProvider).toBe('convertkit');
    expect(siteConfig.waitlistActionUrl.length).toBeGreaterThan(0);
    expect(typeof siteConfig.analyticsEnabled).toBe('boolean');
  });
});
