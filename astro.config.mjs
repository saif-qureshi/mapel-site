import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';
import sitemap from '@astrojs/sitemap';

// https://astro.build/config
export default defineConfig({
  site: 'https://mapleleafcorporation.com',
  integrations: [tailwind(), sitemap()],
  // Clean URLs (/, /contact, /pricing, /fbr-integration) — Astro default `directory` format.
  // The old .html paths are 301-redirected to the clean URLs at the nginx layer
  // (see deploy/nginx-redirects.conf) so we get true permanent redirects and a clean sitemap.
});
