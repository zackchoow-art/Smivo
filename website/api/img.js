export const config = { runtime: 'edge' };

// NOTE: Simple image proxy so crawlers that can't reach Supabase Storage
// directly (e.g. WeChat's crawler in China) can still fetch product images
// via smivo.io which is served by Vercel's global CDN.
export default async function handler(request) {
  const { searchParams } = new URL(request.url);
  const url = searchParams.get('url');

  if (!url) {
    return new Response('Missing url parameter', { status: 400 });
  }

  // Only allow proxying images from our own Supabase storage
  if (!url.includes('supabase.co/storage/')) {
    return new Response('Forbidden', { status: 403 });
  }

  try {
    const imageRes = await fetch(url);

    if (!imageRes.ok) {
      return new Response('Image not found', { status: 404 });
    }

    const contentType = imageRes.headers.get('content-type') || 'image/jpeg';
    const body = await imageRes.arrayBuffer();

    return new Response(body, {
      headers: {
        'Content-Type': contentType,
        // Cache aggressively — product images rarely change
        'Cache-Control': 'public, max-age=86400, s-maxage=604800',
        'Access-Control-Allow-Origin': '*',
      },
    });
  } catch (e) {
    return new Response('Failed to fetch image', { status: 502 });
  }
}
