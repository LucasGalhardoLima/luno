import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';
import sitemap from '@astrojs/sitemap';

const site = process.env.SITE_URL || 'https://luno.app';

export default defineConfig({
  site,
  integrations: [tailwind({ applyBaseStyles: false }), sitemap()],
  output: 'static',
});
