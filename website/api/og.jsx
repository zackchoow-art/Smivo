import { ImageResponse } from '@vercel/og';

export const config = { runtime: 'edge' };

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

  // NOTE: YouTube-style OG card: 1200×630, product image fills the entire
  // card (full bleed), dark gradient overlay rises from the bottom covering
  // ~45% of the height. Title, price, and branding sit on top of the
  // gradient so they remain legible against any photo colour.
  return new ImageResponse(
    (
      <div
        style={{
          width: '1200px',
          height: '630px',
          display: 'flex',
          position: 'relative',
          overflow: 'hidden',
          backgroundColor: '#0f172a',
          fontFamily:
            '-apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif',
        }}
      >
        {/* ── Full-bleed product photo ───────────────────────────────── */}
        {productImageUrl ? (
          <img
            src={productImageUrl}
            width={1200}
            height={630}
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              width: '1200px',
              height: '630px',
              objectFit: 'cover',
            }}
          />
        ) : (
          // Fallback: brand gradient when listing has no photo
          <div
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              width: '1200px',
              height: '630px',
              background:
                'linear-gradient(135deg,#1a3a6b 0%,#2a5298 55%,#3b82f6 100%)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <span
              style={{ fontSize: '110px', color: 'white', fontWeight: '800' }}
            >
              Smivo
            </span>
          </div>
        )}

        {/* ── Bottom gradient scrim (dark → transparent, YouTube style) ─ */}
        <div
          style={{
            position: 'absolute',
            bottom: 0,
            left: 0,
            width: '1200px',
            height: '320px',
            background:
              'linear-gradient(to top, rgba(0,0,0,0.88) 0%, rgba(0,0,0,0.55) 55%, transparent 100%)',
            display: 'flex',
          }}
        />

        {/* ── Top-left: Smivo logo pill ──────────────────────────────── */}
        <div
          style={{
            position: 'absolute',
            top: '24px',
            left: '28px',
            backgroundColor: 'rgba(255,255,255,0.15)',
            backdropFilter: 'blur(8px)',
            border: '1px solid rgba(255,255,255,0.25)',
            borderRadius: '100px',
            padding: '8px 20px',
            display: 'flex',
            alignItems: 'center',
            gap: '8px',
          }}
        >
          <span
            style={{ fontSize: '26px', color: 'white', fontWeight: '800' }}
          >
            Smivo
          </span>
        </div>

        {/* ── Top-right: Sale / Rent badge ──────────────────────────── */}
        {badge ? (
          <div
            style={{
              position: 'absolute',
              top: '24px',
              right: '28px',
              // NOTE: Blue for Sale, teal/green tint for Rent to match
              // the Flat theme's colour convention.
              backgroundColor: badge === 'Sale' ? '#2563eb' : '#0d9488',
              borderRadius: '10px',
              padding: '8px 24px',
              display: 'flex',
            }}
          >
            <span
              style={{ fontSize: '28px', color: 'white', fontWeight: '700' }}
            >
              {badge}
            </span>
          </div>
        ) : null}

        {/* ── Bottom content area (on top of scrim) ─────────────────── */}
        <div
          style={{
            position: 'absolute',
            bottom: 0,
            left: 0,
            width: '1200px',
            padding: '0 40px 36px',
            display: 'flex',
            flexDirection: 'column',
            gap: '8px',
          }}
        >
          {/* Title — single line, clipped if too long */}
          <span
            style={{
              fontSize: '44px',
              fontWeight: '700',
              color: '#ffffff',
              maxWidth: '1000px',
              overflow: 'hidden',
              textOverflow: 'ellipsis',
              whiteSpace: 'nowrap',
              lineHeight: 1.2,
              textShadow: '0 2px 8px rgba(0,0,0,0.4)',
            }}
          >
            {title}
          </span>

          {/* Price row */}
          {priceText ? (
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
              }}
            >
              <span
                style={{
                  fontSize: '52px',
                  fontWeight: '800',
                  color: '#ffffff',
                  letterSpacing: '-1.5px',
                  textShadow: '0 2px 8px rgba(0,0,0,0.4)',
                }}
              >
                {priceText}
              </span>
              {/* smivo.io watermark bottom-right */}
              <span
                style={{
                  fontSize: '22px',
                  color: 'rgba(255,255,255,0.6)',
                  fontWeight: '500',
                }}
              >
                smivo.io
              </span>
            </div>
          ) : (
            <span
              style={{
                fontSize: '22px',
                color: 'rgba(255,255,255,0.6)',
                fontWeight: '500',
                alignSelf: 'flex-end',
              }}
            >
              smivo.io
            </span>
          )}
        </div>
      </div>
    ),
    { width: 1200, height: 630 },
  );
}
