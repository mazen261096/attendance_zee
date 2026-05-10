# ─────────────────────────────────────────────────────────────────────────────
# Cloudflare Worker — Deployment Guide
# attendance-zee · File Storage API
# ─────────────────────────────────────────────────────────────────────────────

## Prerequisites

```bash
npm install -g wrangler
wrangler login
```

## 1. Install dependencies

```bash
cd cloudflare-worker
npm install
```

## 2. Set secrets

Run each command and paste the value when prompted:

```bash
wrangler secret put SUPABASE_URL
# → https://afezewzfxwtghrlsugfl.supabase.co

wrangler secret put SUPABASE_SERVICE_ROLE_KEY
# → your Supabase service role key (Settings → API)

wrangler secret put R2_ACCOUNT_ID
# → your Cloudflare account ID (right sidebar on dash.cloudflare.com)

wrangler secret put R2_ACCESS_KEY_ID
# → R2 → Manage API Tokens → Create API Token → Access Key ID

wrangler secret put R2_SECRET_ACCESS_KEY
# → R2 → Secret Access Key from the same token

wrangler secret put R2_BUCKET_NAME
# → coursebyzee
```

## 3. Create the R2 bucket (if not already created)

In the Cloudflare Dashboard → R2 → Create Bucket → name: `coursebyzee`

## 4. Deploy

```bash
wrangler deploy
```

The CLI will print your Worker URL, e.g.:
`https://attendance-zee-files.<YOUR_SUBDOMAIN>.workers.dev`

## 5. Update Flutter

Open `lib/core/config/app_config.dart` and update:

```dart
static const String cloudflareWorkerUrl =
    'https://attendance-zee-files.<YOUR_SUBDOMAIN>.workers.dev';
```

## 6. (Optional) Custom domain

In Cloudflare Dashboard → Workers & Pages → your worker → Settings → Domains
Add a custom route like `files.yourdomain.com/*`.

Then update `wrangler.toml`:
```toml
[[routes]]
pattern = "files.yourdomain.com/*"
zone_name = "yourdomain.com"
```

## Smoke test

```bash
# Health check (no auth needed)
curl https://attendance-zee-files.<SUB>.workers.dev/health

# Expected: {"status":"ok","service":"attendance-zee-files"}
```

## R2 folder structure (reference)

```
coursebyzee/
└── courses/
    └── {course_id}/
        ├── files/
        │   └── {uuid}.{ext}          ← course-level file
        └── lectures/
            └── {lecture_id}/
                └── files/
                    └── {uuid}.{ext}  ← lecture-level file
```

## Environment variables summary

| Secret | Source |
|---|---|
| `SUPABASE_URL` | Supabase Dashboard → Settings → API |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase Dashboard → Settings → API |
| `R2_ACCOUNT_ID` | Cloudflare Dashboard (right sidebar) |
| `R2_ACCESS_KEY_ID` | R2 → Manage R2 API Tokens |
| `R2_SECRET_ACCESS_KEY` | R2 → Manage R2 API Tokens |
| `R2_BUCKET_NAME` | `coursebyzee` |
