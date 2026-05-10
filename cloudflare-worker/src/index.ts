// ─────────────────────────────────────────────────────────────────────────────
// attendance-zee · Cloudflare Worker · File Storage API
// ─────────────────────────────────────────────────────────────────────────────
// Routes
//   POST   /presign-upload  → returns { upload_url, object_key }
//   GET    /file-url?key=…  → returns { url }
//   DELETE /delete-file     → body { object_key } → 204
// ─────────────────────────────────────────────────────────────────────────────

export interface Env {
  SUPABASE_URL: string;
  SUPABASE_SERVICE_ROLE_KEY: string;
  R2_ACCOUNT_ID: string;
  R2_ACCESS_KEY_ID: string;
  R2_SECRET_ACCESS_KEY: string;
  R2_BUCKET_NAME: string;
}

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

const REGION = 'auto';
const SERVICE = 's3';

/** Signed upload URL validity (seconds) */
const UPLOAD_URL_TTL = 900; // 15 min

/** Signed download URL validity (seconds) */
const DOWNLOAD_URL_TTL = 600; // 10 min

/** Per-MIME size limits in bytes */
const SIZE_LIMITS: Record<string, number> = {
  'image/': 10 * 1024 * 1024,       // 10 MB
  'video/': 200 * 1024 * 1024,      // 200 MB
  'application/pdf': 20 * 1024 * 1024, // 20 MB
};

const ALLOWED_MIME_PREFIXES = ['image/', 'video/', 'application/pdf'];

// ─────────────────────────────────────────────────────────────────────────────
// Helpers — CORS
// ─────────────────────────────────────────────────────────────────────────────

function corsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Authorization, Content-Type',
  };
}

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json', ...corsHeaders() },
  });
}

function errorResponse(message: string, status: number): Response {
  return jsonResponse({ error: message }, status);
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers — JWT / Auth
// ─────────────────────────────────────────────────────────────────────────────

interface SupabaseUser {
  id: string;
  email: string;
}

async function verifyJwt(
  authHeader: string | null,
  env: Env,
): Promise<SupabaseUser> {
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    throw new Error('Missing or malformed Authorization header');
  }
  const token = authHeader.slice(7);

  const res = await fetch(`${env.SUPABASE_URL}/auth/v1/user`, {
    headers: {
      Authorization: `Bearer ${token}`,
      apikey: env.SUPABASE_SERVICE_ROLE_KEY,
    },
  });

  if (!res.ok) {
    throw new Error('Invalid or expired token');
  }

  const user = (await res.json()) as SupabaseUser;
  return user;
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers — Course membership / admin check (via Supabase REST)
// ─────────────────────────────────────────────────────────────────────────────

type MemberRole = 'admin' | 'student';

async function getCourseRole(
  userId: string,
  courseId: string,
  env: Env,
): Promise<MemberRole | null> {
  const url =
    `${env.SUPABASE_URL}/rest/v1/course_members` +
    `?user_id=eq.${userId}&course_id=eq.${courseId}&select=role&limit=1`;

  const res = await fetch(url, {
    headers: {
      apikey: env.SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${env.SUPABASE_SERVICE_ROLE_KEY}`,
    },
  });

  if (!res.ok) return null;

  const rows = (await res.json()) as Array<{ role: MemberRole }>;
  return rows.length > 0 ? rows[0].role : null;
}

/** Extract course_id from an object_key like courses/{id}/... */
function courseIdFromKey(objectKey: string): string | null {
  const m = objectKey.match(/^courses\/([0-9a-f-]{36})\//);
  return m ? m[1] : null;
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers — Validation
// ─────────────────────────────────────────────────────────────────────────────

function getMimePrefix(contentType: string): string | null {
  for (const prefix of ALLOWED_MIME_PREFIXES) {
    if (contentType.startsWith(prefix)) return prefix;
  }
  return null;
}

function validateFile(contentType: string, size: number): string | null {
  const prefix = getMimePrefix(contentType);
  if (!prefix) return 'File type not allowed';

  const limit = SIZE_LIMITS[prefix] ?? SIZE_LIMITS['image/'];
  if (size > limit) {
    const mb = Math.round(limit / 1024 / 1024);
    return `File exceeds ${mb} MB limit for ${prefix} files`;
  }
  return null;
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers — Object key builder
// ─────────────────────────────────────────────────────────────────────────────

function buildObjectKey(
  scope: 'course' | 'lecture',
  courseId: string,
  fileName: string,
  lectureId?: string,
): string {
  const ext = fileName.includes('.') ? fileName.split('.').pop()! : 'bin';
  const uuid = crypto.randomUUID();
  const safeName = `${uuid}.${ext}`;

  if (scope === 'lecture' && lectureId) {
    return `courses/${courseId}/lectures/${lectureId}/files/${safeName}`;
  }
  return `courses/${courseId}/files/${safeName}`;
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers — AWS4 Presigned URL (Web Crypto — no Node.js required)
// ─────────────────────────────────────────────────────────────────────────────

function toHex(buf: ArrayBuffer): string {
  return Array.from(new Uint8Array(buf))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}

async function hmacSha256(key: ArrayBuffer | CryptoKey, data: string): Promise<ArrayBuffer> {
  const cryptoKey =
    key instanceof CryptoKey
      ? key
      : await crypto.subtle.importKey(
          'raw',
          key,
          { name: 'HMAC', hash: 'SHA-256' },
          false,
          ['sign'],
        );
  return crypto.subtle.sign('HMAC', cryptoKey, new TextEncoder().encode(data));
}

async function sha256Hex(data: string): Promise<string> {
  const buf = await crypto.subtle.digest(
    'SHA-256',
    new TextEncoder().encode(data),
  );
  return toHex(buf);
}

async function deriveSigningKey(
  secretKey: string,
  dateStr: string,       // YYYYMMDD
  region: string,
  service: string,
): Promise<CryptoKey> {
  const kDate = await hmacSha256(
    new TextEncoder().encode(`AWS4${secretKey}`),
    dateStr,
  );
  const kRegion = await hmacSha256(kDate, region);
  const kService = await hmacSha256(kRegion, service);
  const kSigning = await hmacSha256(kService, 'aws4_request');

  return crypto.subtle.importKey(
    'raw',
    kSigning,
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign'],
  );
}

interface PresignOptions {
  method: 'PUT' | 'GET' | 'DELETE';
  objectKey: string;
  contentType?: string;    // only for PUT
  expiresIn: number;       // seconds
  env: Env;
}

async function createPresignedUrl(opts: PresignOptions): Promise<string> {
  const { method, objectKey, contentType, expiresIn, env } = opts;

  const endpoint = `https://${env.R2_ACCOUNT_ID}.r2.cloudflarestorage.com`;
  const host = `${env.R2_ACCOUNT_ID}.r2.cloudflarestorage.com`;
  const bucket = env.R2_BUCKET_NAME;

  const now = new Date();
  const amzDate = now.toISOString().replace(/[:-]|\.\d{3}/g, '').slice(0, 15) + 'Z';
  const dateStr = amzDate.slice(0, 8); // YYYYMMDD

  const credential = `${env.R2_ACCESS_KEY_ID}/${dateStr}/${REGION}/${SERVICE}/aws4_request`;

  // For presigned URLs the payload hash is always UNSIGNED-PAYLOAD
  const payloadHash = 'UNSIGNED-PAYLOAD';

  // Canonical query string — must be sorted alphabetically by key
  const queryParams: Record<string, string> = {
    'X-Amz-Algorithm': 'AWS4-HMAC-SHA256',
    'X-Amz-Credential': credential,
    'X-Amz-Date': amzDate,
    'X-Amz-Expires': String(expiresIn),
    'X-Amz-SignedHeaders': 'host',
  };

  const sortedQuery = Object.keys(queryParams)
    .sort()
    .map(
      (k) =>
        `${encodeURIComponent(k)}=${encodeURIComponent(queryParams[k])}`,
    )
    .join('&');

  const encodedKey = objectKey
    .split('/')
    .map((part) => encodeURIComponent(part))
    .join('/');

  const canonicalUri = `/${bucket}/${encodedKey}`;
  const canonicalHeaders = `host:${host}\n`;
  const signedHeaders = 'host';

  const canonicalRequest = [
    method,
    canonicalUri,
    sortedQuery,
    canonicalHeaders,
    signedHeaders,
    payloadHash,
  ].join('\n');

  const scope = `${dateStr}/${REGION}/${SERVICE}/aws4_request`;
  const stringToSign = [
    'AWS4-HMAC-SHA256',
    amzDate,
    scope,
    await sha256Hex(canonicalRequest),
  ].join('\n');

  const signingKey = await deriveSigningKey(
    env.R2_SECRET_ACCESS_KEY,
    dateStr,
    REGION,
    SERVICE,
  );
  const signature = toHex(await hmacSha256(signingKey, stringToSign));

  const presignedUrl =
    `${endpoint}/${bucket}/${encodedKey}` +
    `?${sortedQuery}&X-Amz-Signature=${signature}`;

  return presignedUrl;
}

// ─────────────────────────────────────────────────────────────────────────────
// Route: POST /presign-upload
// ─────────────────────────────────────────────────────────────────────────────

interface PresignUploadBody {
  scope: 'course' | 'lecture';
  course_id: string;
  lecture_id?: string;
  file_name: string;
  content_type: string;
  size: number; // bytes
}

async function handlePresignUpload(req: Request, env: Env): Promise<Response> {
  let user: SupabaseUser;
  try {
    user = await verifyJwt(req.headers.get('Authorization'), env);
  } catch {
    return errorResponse('Unauthorized', 401);
  }

  let body: PresignUploadBody;
  try {
    body = (await req.json()) as PresignUploadBody;
  } catch {
    return errorResponse('Invalid JSON body', 400);
  }

  const { scope, course_id, lecture_id, file_name, content_type, size } = body;

  // Validate required fields
  if (!scope || !course_id || !file_name || !content_type || !size) {
    return errorResponse('Missing required fields: scope, course_id, file_name, content_type, size', 400);
  }
  if (scope === 'lecture' && !lecture_id) {
    return errorResponse('lecture_id is required for lecture scope', 400);
  }

  // Validate MIME type and size
  const validationError = validateFile(content_type, size);
  if (validationError) return errorResponse(validationError, 422);

  // Check the user is an admin in this course
  const role = await getCourseRole(user.id, course_id, env);
  if (role !== 'admin') {
    return errorResponse('Only course admins can upload files', 403);
  }

  // Build deterministic object key
  const objectKey = buildObjectKey(scope, course_id, file_name, lecture_id);

  // Generate presigned PUT URL
  const uploadUrl = await createPresignedUrl({
    method: 'PUT',
    objectKey,
    contentType: content_type,
    expiresIn: UPLOAD_URL_TTL,
    env,
  });

  return jsonResponse({ upload_url: uploadUrl, object_key: objectKey });
}

// ─────────────────────────────────────────────────────────────────────────────
// Route: GET /file-url?key=<object_key>
// ─────────────────────────────────────────────────────────────────────────────

async function handleGetFileUrl(req: Request, env: Env): Promise<Response> {
  let user: SupabaseUser;
  try {
    user = await verifyJwt(req.headers.get('Authorization'), env);
  } catch {
    return errorResponse('Unauthorized', 401);
  }

  const url = new URL(req.url);
  const objectKey = url.searchParams.get('key');
  if (!objectKey) return errorResponse('Missing query param: key', 400);

  // Extract course_id from the key to verify membership
  const courseId = courseIdFromKey(objectKey);
  if (!courseId) return errorResponse('Invalid object_key format', 400);

  const role = await getCourseRole(user.id, courseId, env);
  if (!role) {
    return errorResponse('You are not a member of this course', 403);
  }

  const signedUrl = await createPresignedUrl({
    method: 'GET',
    objectKey,
    expiresIn: DOWNLOAD_URL_TTL,
    env,
  });

  return jsonResponse({ url: signedUrl, expires_in: DOWNLOAD_URL_TTL });
}

// ─────────────────────────────────────────────────────────────────────────────
// Route: DELETE /delete-file
// Body: { object_key: string }
// ─────────────────────────────────────────────────────────────────────────────

async function handleDeleteFile(req: Request, env: Env): Promise<Response> {
  let user: SupabaseUser;
  try {
    user = await verifyJwt(req.headers.get('Authorization'), env);
  } catch {
    return errorResponse('Unauthorized', 401);
  }

  let body: { object_key: string };
  try {
    body = (await req.json()) as { object_key: string };
  } catch {
    return errorResponse('Invalid JSON body', 400);
  }

  const { object_key: objectKey } = body;
  if (!objectKey) return errorResponse('Missing object_key', 400);

  const courseId = courseIdFromKey(objectKey);
  if (!courseId) return errorResponse('Invalid object_key format', 400);

  // Only admins can delete
  const role = await getCourseRole(user.id, courseId, env);
  if (role !== 'admin') {
    return errorResponse('Only course admins can delete files', 403);
  }

  // Use S3-compatible DELETE via fetch (Worker does not need the SDK)
  const deleteUrl = await createPresignedUrl({
    method: 'DELETE',
    objectKey,
    expiresIn: 60, // 1 min — immediately used
    env,
  });

  const deleteRes = await fetch(deleteUrl, { method: 'DELETE' });
  if (!deleteRes.ok && deleteRes.status !== 404) {
    return errorResponse('Failed to delete object from storage', 502);
  }

  return new Response(null, { status: 204, headers: corsHeaders() });
}

// ─────────────────────────────────────────────────────────────────────────────
// Main fetch handler
// ─────────────────────────────────────────────────────────────────────────────

export default {
  async fetch(req: Request, env: Env): Promise<Response> {
    // Pre-flight CORS
    if (req.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: corsHeaders() });
    }

    const url = new URL(req.url);
    const path = url.pathname.replace(/\/$/, ''); // strip trailing slash

    try {
      if (path === '/presign-upload' && req.method === 'POST') {
        return await handlePresignUpload(req, env);
      }
      if (path === '/file-url' && req.method === 'GET') {
        return await handleGetFileUrl(req, env);
      }
      if (path === '/delete-file' && req.method === 'DELETE') {
        return await handleDeleteFile(req, env);
      }
      if (path === '/health' && req.method === 'GET') {
        return jsonResponse({ status: 'ok', service: 'attendance-zee-files' });
      }

      return errorResponse('Not found', 404);
    } catch (err) {
      console.error('Unhandled error:', err);
      return errorResponse('Internal server error', 500);
    }
  },
} satisfies ExportedHandler<Env>;
