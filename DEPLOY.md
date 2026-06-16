# Deployment

The marketing site is an **Astro** static build. `npm run build` outputs plain
HTML/CSS/JS to `dist/`, which nginx serves directly.

Server: `forge@159.65.13.183`
Project path: `/home/forge/mapleleafcorporation.com/`
Branch: `main`

## Routine deploy

```bash
./deploy.sh
```

This SSHes in, `git pull`s, `npm ci`, and `npm run build` on the server. nginx
serves the freshly built `dist/`.

## One-time server setup (before the first Astro deploy)

The site used to be raw HTML served from the repo root. Astro outputs to `dist/`,
so two nginx changes are needed once (requires sudo on the box):

1. **Point the web root at the build output:**

   ```
   root /home/forge/mapleleafcorporation.com/dist;
   ```

2. **Add 301 redirects** from the old `.html` URLs to the new clean URLs, and
   serve clean URLs via `try_files`:

   ```nginx
   # legacy .html -> clean URL
   location = /index.html            { return 301 /; }
   location = /contact.html          { return 301 /contact; }
   location = /pricing.html          { return 301 /pricing; }
   location = /fbr-integration.html  { return 301 /fbr-integration; }

   location / {
       try_files $uri $uri/ =404;
   }
   ```

   Then `sudo nginx -t && sudo systemctl reload nginx`.

Node/npm must be available to the `forge` user (already the case — the ERP build
uses them).

## Notes
- `dist/`, `node_modules/`, and `.astro/` are git-ignored; the server builds them.
- The sitemap (`/sitemap-index.xml`) and `robots.txt` are produced by the build.
- A pre-Astro backup of the old static files is on the server at
  `~/mapleleafcorporation.com.backup-2026-06-17.tar.gz`.
