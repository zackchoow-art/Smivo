import { ImageResponse } from '@vercel/og';

export const config = { runtime: 'edge' };

// NOTE: Public anon key — safe to include here since it's already
// embedded in the Flutter app and Supabase RLS still applies.
const SUPABASE_URL = 'https://cpavunhkwsrmomhktklb.supabase.co';
const SUPABASE_ANON_KEY =
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNwYXZ1bmhrd3NybW9taGt0a2xiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM2MjI0OTIsImV4cCI6MjA1OTE5ODQ5Mn0.A0d4-qzWsIJtggZdGfT7b7YCn5VJyiIuAqY_vN7OmT8';

export default async function handler(request) {
  const { searchParams } = new URL(request.url);
  const id = searchParams.get('id') || '';

  let title = 'Check out this item on Smivo';
  let priceText = '';
  let badge = '';
  let productImageUrl = null;

  if (id) {
    try {
      const res = await fetch(
        `${SUPABASE_URL}/rest/v1/listings?id=eq.${encodeURIComponent(id)}` +
          `&select=title,price,rental_type,listing_images(image_url,display_order)&limit=1`,
        {
          headers: {
            apikey: SUPABASE_ANON_KEY,
            Authorization: `Bearer ${SUPABASE_ANON_KEY}`,
          },
        },
      );
      const data = await res.json();
      if (data && data[0]) {
        const listing = data[0];
        title = listing.title || title;
        const isRent = listing.rental_type === 'rent';
        badge = isRent ? 'Rent' : 'Sale';
        priceText = isRent
          ? 'For Rent'
          : listing.price
            ? `$${parseFloat(listing.price).toFixed(0)}`
            : '';
        const images = (listing.listing_images || []).sort(
          (a, b) => (a.display_order || 0) - (b.display_order || 0),
        );
        if (images[0]?.image_url) productImageUrl = images[0].image_url;
      }
    } catch (_) {
      // fall through to default branding
    }
  }

  // NOTE: OG image is 1200×630 (standard). Design mirrors the Flat-theme
  // listing card: full-width photo top, white content strip bottom,
  // Sale/Rent badge overlaid on the photo top-right corner.
  return new ImageResponse(
    (
      <div
        style={{
          width: '1200px',
          height: '630px',
          display: 'flex',
          flexDirection: 'column',
          backgroundColor: '#ffffff',
          overflow: 'hidden',
          fontFamily:
            '-apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif',
        }}
      >
        {/* ── Photo area (top 67 %) ─────────────────────────────────── */}
        <div
          style={{
            width: '1200px',
            height: '420px',
            position: 'relative',
            display: 'flex',
            backgroundColor: '#f1f5f9',
            overflow: 'hidden',
          }}
        >
          {productImageUrl ? (
            <img
              src={productImageUrl}
              width={1200}
              height={420}
              style={{ objectFit: 'cover', width: '1200px', height: '420px' }}
            />
          ) : (
            // Fallback gradient when no product image
            <div
              style={{
                width: '1200px',
                height: '420px',
                background: 'linear-gradient(135deg,#1a3a6b 0%,#2a5298 60%,#3b82f6 100%)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <span style={{ fontSize: '96px', color: 'white', fontWeight: '800' }}>
                Smivo
              </span>
            </div>
          )}

          {/* Sale / Rent badge — top-right, matching Flat card */}
          {badge ? (
            <div
              style={{
                position: 'absolute',
                top: '20px',
                right: '20px',
                backgroundColor: '#1a3a6b',
                color: '#ffffff',
                padding: '8px 22px',
                borderRadius: '10px',
                fontSize: '30px',
                fontWeight: '700',
                display: 'flex',
                letterSpacing: '-0.3px',
              }}
            >
              {badge}
            </div>
          ) : null}
        </div>

        {/* ── Content strip (bottom 33 %) ───────────────────────────── */}
        <div
          style={{
            flex: 1,
            padding: '0 40px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            borderTop: '1px solid #e2e8f0',
          }}
        >
          <div style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
            {/* Title */}
            <span
              style={{
                fontSize: '38px',
                fontWeight: '600',
                color: '#1e293b',
                maxWidth: '900px',
                overflow: 'hidden',
                textOverflow: 'ellipsis',
                whiteSpace: 'nowrap',
              }}
            >
              {title}
            </span>
            {/* Price */}
            {priceText ? (
              <span
                style={{
                  fontSize: '46px',
                  fontWeight: '800',
                  color: '#1e293b',
                  letterSpacing: '-1px',
                }}
              >
                {priceText}
              </span>
            ) : null}
          </div>

          {/* Arrow + branding column */}
          <div
            style={{
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'flex-end',
              gap: '8px',
            }}
          >
            <span style={{ fontSize: '52px', color: '#94a3b8' }}>→</span>
            <span
              style={{ fontSize: '22px', color: '#94a3b8', fontWeight: '600' }}
            >
              smivo.io
            </span>
          </div>
        </div>
      </div>
    ),
    { width: 1200, height: 630 },
  );
}
