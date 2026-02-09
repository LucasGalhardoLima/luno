# Luno Landing (Astro)

Landing page V1 para validação de demanda e captação de waitlist da Luno.

## Stack

- Astro (estático)
- Tailwind CSS
- TypeScript
- Vitest (tests utilitários)

## Rodando local

```bash
cd landing
npm install
npm run dev
```

## Build

```bash
npm run check
npm run test
npm run build
```

## Variáveis de ambiente

- `PUBLIC_WAITLIST_ACTION_URL`: endpoint do formulário Formspree
- `PUBLIC_ANALYTICS_ENABLED`: `true` ou `false`
- `SITE_URL`: domínio canônico para meta tags/sitemap

Exemplo `.env`:

```bash
PUBLIC_WAITLIST_ACTION_URL="https://formspree.io/f/SEU_FORM_ID"
PUBLIC_ANALYTICS_ENABLED="true"
SITE_URL="https://luno.app"
```

## Observação sobre assets

Os screenshots usados no hero e nas seções são snapshots reais do app iOS extraídos de `LunoTests/Snapshots`.
Neste ambiente, os encoders de WebP/AVIF não estão disponíveis; os assets estão em PNG com dimensões explícitas para evitar layout shift.
