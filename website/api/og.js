import { ImageResponse } from '@vercel/og';

export const config = { runtime: 'edge' };

const SUPABASE_URL = 'https://sztrbkfdcldwaifjkkol.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_uF2gSam0yvMjVEswqwYWcA_i67ROBxj';

// NOTE: Helper to avoid JSX — Vercel static projects don't transpile .jsx
// in the api/ directory. React.createElement objects work directly with Satori.
function h(type, props, ...children) {
  const flatChildren = children.flat().filter(Boolean);
  return {
    type,
    props: {
      ...props,
      children:
        flatChildren.length === 0
          ? undefined
          : flatChildren.length === 1
            ? flatChildren[0]
            : flatChildren,
    },
  };
}

export default async function handler(request) {
  const { searchParams } = new URL(request.url);
  const id = searchParams.get('id') || '';

  let title = 'Smivo';
  let priceText = '';
  let badge = '';
  let productImageUrl = null;

  if (id) {
    try {
      const res = await fetch(
        `${SUPABASE_URL}/rest/v1/listings?id=eq.${encodeURIComponent(id)}` +
          `&select=title,price,transaction_type,listing_images(image_url,sort_order)&limit=1`,
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
        const isRent = listing.transaction_type === 'rental';
        badge = isRent ? 'Rent' : 'Sale';
        priceText = isRent
          ? 'For Rent'
          : listing.price
            ? `$${parseFloat(listing.price).toFixed(0)}`
            : '';
        const images = (listing.listing_images || []).sort(
          (a, b) => (a.sort_order || 0) - (b.sort_order || 0),
        );
        if (images[0]?.image_url) productImageUrl = images[0].image_url;
      }
    } catch (_) {
      // fall through to default branding
    }
  }

  // NOTE: 600×315 is deliberately small — WeChat's crawler rejects images
  // over ~300 KB. This size keeps the generated PNG well under that limit
  // while still looking crisp in share card previews.

  return new ImageResponse(
    h(
      'div',
      {
        style: {
          width: '600px',
          height: '315px',
          display: 'flex',
          position: 'relative',
          overflow: 'hidden',
          backgroundColor: '#0f172a',
          fontFamily: 'sans-serif',
        },
      },
      // ── Full-bleed product photo or brand gradient fallback
      productImageUrl
        ? h('img', {
            src: productImageUrl,
            width: 600,
            height: 315,
            style: {
              position: 'absolute',
              top: 0,
              left: 0,
              width: '600px',
              height: '315px',
              objectFit: 'cover',
            },
          })
        : h(
            'div',
            {
              style: {
                position: 'absolute',
                top: 0,
                left: 0,
                width: '600px',
                height: '315px',
                background:
                  'linear-gradient(135deg,#1a3a6b 0%,#2a5298 55%,#3b82f6 100%)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              },
            },
            h(
              'span',
              { style: { fontSize: '64px', color: 'white', fontWeight: '800' } },
              'Smivo',
            ),
          ),
      // ── Bottom gradient scrim
      h('div', {
        style: {
          position: 'absolute',
          bottom: 0,
          left: 0,
          width: '600px',
          height: '160px',
          background:
            'linear-gradient(to top, rgba(0,0,0,0.85) 0%, rgba(0,0,0,0.4) 60%, transparent 100%)',
          display: 'flex',
        },
      }),
      // ── Top-left: Smivo logo pill
      h(
        'div',
        {
          style: {
            position: 'absolute',
            top: '12px',
            left: '14px',
            backgroundColor: 'rgba(255,255,255,0.18)',
            borderRadius: '100px',
            padding: '4px 12px',
            display: 'flex',
            alignItems: 'center',
          },
        },
        h(
          'span',
          { style: { fontSize: '14px', color: 'white', fontWeight: '800' } },
          'Smivo',
        ),
      ),
      // ── Top-right: Sale / Rent badge
      badge
        ? h(
            'div',
            {
              style: {
                position: 'absolute',
                top: '12px',
                right: '14px',
                backgroundColor:
                  badge === 'Sale' ? '#2563eb' : '#0d9488',
                borderRadius: '6px',
                padding: '4px 12px',
                display: 'flex',
              },
            },
            h(
              'span',
              { style: { fontSize: '14px', color: 'white', fontWeight: '700' } },
              badge,
            ),
          )
        : null,
      // ── Bottom content: title + price
      h(
        'div',
        {
          style: {
            position: 'absolute',
            bottom: 0,
            left: 0,
            width: '600px',
            padding: '0 20px 16px',
            display: 'flex',
            flexDirection: 'column',
            gap: '2px',
          },
        },
        // Title
        h(
          'span',
          {
            style: {
              fontSize: '22px',
              fontWeight: '700',
              color: '#ffffff',
              maxWidth: '440px',
              overflow: 'hidden',
              textOverflow: 'ellipsis',
              whiteSpace: 'nowrap',
              lineHeight: 1.2,
              textShadow: '0 1px 4px rgba(0,0,0,0.5)',
            },
          },
          title,
        ),
        // Price row
        priceText
          ? h(
              'div',
              {
                style: {
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                },
              },
              h(
                'span',
                {
                  style: {
                    fontSize: '28px',
                    fontWeight: '800',
                    color: '#ffffff',
                    letterSpacing: '-1px',
                    textShadow: '0 1px 4px rgba(0,0,0,0.5)',
                  },
                },
                priceText,
              ),
              h(
                'span',
                {
                  style: {
                    fontSize: '12px',
                    color: 'rgba(255,255,255,0.6)',
                    fontWeight: '500',
                  },
                },
                'smivo.io',
              ),
            )
          : h(
              'span',
              {
                style: {
                  fontSize: '12px',
                  color: 'rgba(255,255,255,0.6)',
                  fontWeight: '500',
                  alignSelf: 'flex-end',
                },
              },
              'smivo.io',
            ),
      ),
    ),
    { width: 600, height: 315 },
  );
}
