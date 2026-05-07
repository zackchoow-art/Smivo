export const config = { runtime: 'edge' };

const SUPABASE_URL = 'https://sztrbkfdcldwaifjkkol.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_uF2gSam0yvMjVEswqwYWcA_i67ROBxj';

function esc(str) {
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/"/g, '&quot;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;');
}

export default async function handler(request) {
  const { searchParams } = new URL(request.url);
  const id = searchParams.get('id') || '';

  let title = 'Smivo';
  let description = '';
  let priceText = '';
  let badge = '';
  let productImageUrl = 'https://smivo.io/og-image.png';

  if (id) {
    try {
      // NOTE: Fetch title, description, price, type and first image
      const res = await fetch(
        `${SUPABASE_URL}/rest/v1/listings?id=eq.${encodeURIComponent(id)}` +
        `&select=title,description,price,transaction_type,listing_images(image_url,sort_order)&limit=1`,
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
        description = listing.description || '';
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
      // fall through to defaults
    }
  }

  // NOTE: Use the Supabase storage URL directly as og:image.
  // Previous attempts to proxy through /api/img failed for WeChat because
  // the Edge Function adds latency (DB lookup + image fetch). Direct CDN
  // URLs load in <200ms which is within WeChat's crawl timeout.
  const ogImage = productImageUrl;
  const ogDesc = priceText ? `${priceText} · Smivo` : 'Smivo Campus Marketplace';
  const canonical = `https://smivo.io/listing/${encodeURIComponent(id)}`;

  const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${esc(title)} — Smivo</title>
  <link rel="canonical" href="${canonical}">
  <link rel="icon" type="image/png" href="/favicon.png">

  <!-- Open Graph -->
  <meta property="og:type" content="website">
  <meta property="og:site_name" content="Smivo">
  <meta property="og:url" content="${canonical}">
  <meta property="og:title" content="${esc(title)}">
  <meta property="og:description" content="${esc(ogDesc)}">
  <meta property="og:image" content="${ogImage}">

  <!-- WeChat / Schema.org -->
  <meta itemprop="name" content="${esc(title)}">
  <meta itemprop="description" content="${esc(ogDesc)}">
  <meta itemprop="image" content="${ogImage}">
  <meta name="description" content="${esc(ogDesc)}">

  <!-- Twitter / X -->
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="${esc(title)}">
  <meta name="twitter:description" content="${esc(ogDesc)}">
  <meta name="twitter:image" content="${ogImage}">

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <style>
    *{margin:0;padding:0;box-sizing:border-box;}
    body{font-family:'Inter',-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;background:#0f172a;min-height:100vh;display:flex;align-items:center;justify-content:center;padding:20px;-webkit-font-smoothing:antialiased;}
    .card{width:100%;max-width:420px;border-radius:20px;overflow:hidden;box-shadow:0 24px 60px rgba(0,0,0,.5);background:#0f172a;}

    /* ── Image section ── */
    .img-wrap{position:relative;width:100%;aspect-ratio:4/3;background:#1e293b;overflow:hidden;}
    .img-wrap img{width:100%;height:100%;object-fit:cover;display:block;}
    .scrim{position:absolute;bottom:0;left:0;right:0;height:40%;background:linear-gradient(to top,rgba(0,0,0,.5) 0%,transparent 100%);}
    .badge{position:absolute;top:14px;right:14px;padding:5px 14px;border-radius:8px;font-size:.8rem;font-weight:700;color:#fff;}
    .badge-sale{background:#2563eb;}
    .badge-rent{background:#0d9488;}
    .logo-pill{position:absolute;top:14px;left:14px;background:rgba(255,255,255,.15);border:1px solid rgba(255,255,255,.25);border-radius:100px;padding:5px 14px;font-size:.8rem;font-weight:800;color:#fff;backdrop-filter:blur(6px);}

    /* ── Info section below image ── */
    .info{padding:16px 18px 12px;border-bottom:1px solid rgba(255,255,255,.08);}
    .info-row{display:flex;align-items:baseline;justify-content:space-between;gap:12px;}
    .info-title{font-size:1.1rem;font-weight:700;color:#fff;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;flex:1;min-width:0;}
    .info-price{font-size:1.2rem;font-weight:800;color:#60a5fa;white-space:nowrap;letter-spacing:-.5px;}
    .info-desc{font-size:.85rem;color:rgba(255,255,255,.5);margin-top:6px;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;line-height:1.4;}

    /* ── Action buttons ── */
    .actions{padding:16px 18px 14px;display:flex;flex-direction:column;gap:10px;}
    .btn{display:flex;align-items:center;justify-content:center;gap:8px;padding:13px 20px;border-radius:12px;font-size:.95rem;font-weight:600;text-decoration:none;transition:transform .15s,box-shadow .15s;}
    .btn:hover{transform:translateY(-2px);box-shadow:0 6px 20px rgba(0,0,0,.3);}
    .btn-primary{background:linear-gradient(135deg,#1a3a6b,#2a5298);color:#fff;}
    .btn-secondary{background:rgba(255,255,255,.08);color:rgba(255,255,255,.85);border:1px solid rgba(255,255,255,.15);}
    .footer{text-align:center;font-size:.75rem;color:rgba(255,255,255,.3);padding-bottom:16px;}
  </style>
</head>
<body>
<div class="card">
  <!-- Product image with badges -->
  <div class="img-wrap">
    <img id="product-img" src="${esc(productImageUrl)}" alt="${esc(title)}">
    <div class="scrim"></div>
    <div class="logo-pill">Smivo</div>
    ${badge ? `<div class="badge badge-${badge.toLowerCase()}">${esc(badge)}</div>` : ''}
  </div>

  <!-- Info section: Title + Price + Description -->
  <div class="info">
    <div class="info-row">
      <div class="info-title">${esc(title)}</div>
      ${priceText ? `<div class="info-price">${esc(priceText)}</div>` : ''}
    </div>
    ${description ? `<div class="info-desc">${esc(description)}</div>` : ''}
  </div>

  <!-- Action buttons -->
  <div class="actions">
    <a href="https://apps.apple.com/us/app/smivo/id6764173442"
       class="btn btn-primary" target="_blank" rel="noopener noreferrer">
      📱 Download on App Store
    </a>
    <a id="btn-webapp"
       href="https://smivo.app/listing/${esc(id)}"
       class="btn btn-secondary">
      🌐 Open Web App
    </a>
  </div>
  <div class="footer">smivo.io · Campus Marketplace</div>
</div>
</body>
</html>`;

  return new Response(html, {
    headers: {
      'Content-Type': 'text/html; charset=utf-8',
      // NOTE: Cache for 60s at edge, serve stale for up to 1h while revalidating.
      'Cache-Control': 'public, s-maxage=60, stale-while-revalidate=3600',
    },
  });
}
