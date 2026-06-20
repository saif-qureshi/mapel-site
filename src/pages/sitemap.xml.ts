import type { APIRoute } from 'astro';
import { getCollection } from 'astro:content';

const SITE = 'https://mapleleafcorporation.com';

export const GET: APIRoute = async () => {
  // Discover static pages from src/pages (skip dynamic [..] routes and 404)
  const staticPaths = Object.keys(import.meta.glob('./**/*.astro'))
    .map((f) => f.replace(/^\.\//, '').replace(/\.astro$/, ''))
    .filter((f) => !f.includes('[') && f !== '404')
    .map((f) => (f === 'index' ? '/' : f.endsWith('/index') ? `/${f.slice(0, -6)}/` : `/${f}/`));

  // Blog posts from the content collection
  const blogPaths = (await getCollection('blog')).map((p) => `/blog/${p.slug}/`);

  const urls = Array.from(new Set([...staticPaths, ...blogPaths])).sort();

  const xml = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${urls.map((u) => `  <url><loc>${SITE}${u}</loc></url>`).join('\n')}
</urlset>
`;

  return new Response(xml, {
    headers: { 'Content-Type': 'application/xml; charset=utf-8' },
  });
};
