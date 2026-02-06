const UTM_KEYS = [
  'utm_source',
  'utm_medium',
  'utm_campaign',
  'utm_term',
  'utm_content',
  'gclid',
  'fbclid',
] as const;

export type UtmMap = Partial<Record<(typeof UTM_KEYS)[number], string>>;

export function readUtmParams(search: URLSearchParams): UtmMap {
  return UTM_KEYS.reduce<UtmMap>((acc, key) => {
    const value = search.get(key);
    if (value) {
      acc[key] = value;
    }
    return acc;
  }, {});
}

export function appendUtmToUrl(href: string, utm: UtmMap): string {
  try {
    const url = new URL(href, 'https://placeholder.local');
    Object.entries(utm).forEach(([key, value]) => {
      if (value && !url.searchParams.has(key)) {
        url.searchParams.set(key, value);
      }
    });
    if (href.startsWith('http')) {
      return url.toString();
    }
    return `${url.pathname}${url.search}${url.hash}`;
  } catch {
    return href;
  }
}
