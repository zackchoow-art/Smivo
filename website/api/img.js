export const config = { runtime: 'edge' };

const SUPABASE_URL = 'https://sztrbkfdcldwaifjkkol.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_uF2gSam0yvMjVEswqwYWcA_i67ROBxj';

// NOTE: Image proxy for OG / social share previews.
// Accepts either:
//   ?id=<listing_id>  — fetches the listing's first image from Supabase
//   ?url=<image_url>  — proxies a specific Supabase storage URL
//
// This exists because WeChat's crawler (servers in China) cannot reach
// Supabase storage directly. Vercel's global CDN acts as a relay.

export default async function handler(request) {
  const { searchParams } = new URL(request.url);
  const id = searchParams.get('id');
  const rawUrl = searchParams.get('url');

  let imageUrl = null;

  if (id) {
    // Fetch the listing's first image from Supabase
    try {
      const res = await fetch(
        `${SUPABASE_URL}/rest/v1/listings?id=eq.${encodeURIComponent(id)}` +
          `&select=listing_images(image_url,sort_order)&limit=1`,
        {
          headers: {
            apikey: SUPABASE_ANON_KEY,
            Authorization: `Bearer ${SUPABASE_ANON_KEY}`,
          },
        },
      );
      const data = await res.json();
      if (data && data[0]) {
        const images = (data[0].listing_images || []).sort(
          (a, b) => (a.sort_order || 0) - (b.sort_order || 0),
        );
        if (images[0]?.image_url) {
          imageUrl = images[0].image_url;
        }
      }
    } catch (_) {
      // fall through to 404
    }
  } else if (rawUrl && rawUrl.includes('supabase.co/storage/')) {
    // Only allow proxying from our own Supabase storage
    imageUrl = rawUrl;
  }

  if (!imageUrl) {
    return new Response('Image not found', { status: 404 });
  }

  try {
    const imageRes = await fetch(imageUrl);

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
