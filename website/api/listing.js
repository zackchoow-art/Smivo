export const config = { runtime: 'edge' };

const SUPABASE_URL = 'https://cpavunhkwsrmomhktklb.supabase.co';
const SUPABASE_ANON_KEY =
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNwYXZ1bmhrd3NybW9taGt0a2xiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM2MjI0OTIsImV4cCI6MjA1OTE5ODQ5Mn0.A0d4-qzWsIJtggZdGfT7b7YCn5VJyiIuAqY_vN7OmT8';

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

  let title = 'Check out this item on Smivo';
  let description = 'Buy, sell, and rent items within your campus community.';
  let priceText = '';
  let badge = '';
  let productImageUrl = 'https://smivo.io/og-image.png';

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
        description = `${title}${priceText ? ` — ${priceText}` : ''} · Available on Smivo`;
        const images = (listing.listing_images || []).sort(
          (a, b) => (a.display_order || 0) - (b.display_order || 0),
        );
        if (images[0]?.image_url) productImageUrl = images[0].image_url;
      }
    } catch (_) {
      // fall through to defaults
    }
  }

  // NOTE: og:image points to /api/og?id=<id> which returns the dynamic card.
  // All meta tags are server-rendered so iMessage, WhatsApp, and every other
  // crawler reads them without executing JavaScript.
  const ogImage = `https://smivo.io/api/og?id=${encodeURIComponent(id)}`;
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
  <meta property="og:description" content="${esc(description)}">
  <meta property="og:image" content="${ogImage}">
  <meta property="og:image:width" content="1200">
  <meta property="og:image:height" content="630">
  <meta property="og:image:type" content="image/png">

  <!-- Twitter / X -->
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="${esc(title)}">
  <meta name="twitter:description" content="${esc(description)}">
  <meta name="twitter:image" content="${ogImage}">

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <style>
    :root{--primary:#1a3a6b;--primary-light:#2a5298;--accent:#e8b630;--text:#1e293b;--text-light:#64748b;--bg:#fff;--surface:#f8fafc;--border:#e2e8f0;}
    *{margin:0;padding:0;box-sizing:border-box;}
    body{font-family:'Inter',-apple-system,BlinkMacSystemFont,sans-serif;color:var(--text);background:var(--bg);-webkit-font-smoothing:antialiased;min-height:100vh;display:flex;flex-direction:column;align-items:center;justify-content:center;padding:24px;}
    .card{background:#fff;border:1px solid var(--border);border-radius:24px;padding:40px 32px;max-width:480px;width:100%;text-align:center;box-shadow:0 8px 40px rgba(0,0,0,.08);}
    .logo{font-size:2rem;font-weight:800;color:var(--primary);margin-bottom:4px;}
    .logo-sub{font-size:.85rem;color:var(--text-light);margin-bottom:28px;}
    .product-img{width:100%;max-height:220px;object-fit:cover;border-radius:12px;margin-bottom:16px;display:none;}
    .listing-title{font-size:1.25rem;font-weight:700;margin-bottom:4px;}
    .listing-price{font-size:1.1rem;font-weight:600;color:var(--primary);margin-bottom:20px;}
    .divider{height:1px;background:var(--border);margin:20px 0;}
    .cta-label{font-size:.9rem;color:var(--text-light);margin-bottom:14px;}
    .btn{display:flex;align-items:center;justify-content:center;gap:8px;padding:13px 24px;border-radius:12px;font-size:1rem;font-weight:600;text-decoration:none;width:100%;margin-bottom:10px;transition:transform .15s,box-shadow .15s;border:none;cursor:pointer;}
    .btn:hover{transform:translateY(-2px);box-shadow:0 6px 20px rgba(0,0,0,.12);}
    .btn-primary{background:linear-gradient(135deg,var(--primary),var(--primary-light));color:#fff;}
    .btn-secondary{background:var(--surface);color:var(--primary);border:1px solid var(--border);}
    .spinner{width:36px;height:36px;border:3px solid var(--border);border-top-color:var(--primary);border-radius:50%;animation:spin .7s linear infinite;margin:0 auto 12px;}
    @keyframes spin{to{transform:rotate(360deg)}}
  </style>
</head>
<body>
<div class="card">
  <div class="logo">Smivo</div>
  <div class="logo-sub">Campus Marketplace</div>

  <img id="product-img" class="product-img" alt="">
  <div id="listing-title" class="listing-title">${esc(title)}</div>
  <div id="listing-price" class="listing-price">${esc(priceText)}</div>

  <div class="divider"></div>
  <p class="cta-label">Open in the Smivo app for the full experience</p>
  <a href="https://apps.apple.com/us/app/smivo/id6764173442"
     class="btn btn-primary" target="_blank" rel="noopener noreferrer">
    📱 Download on App Store
  </a>
  <a href="/" class="btn btn-secondary">Browse on Smivo.io</a>
</div>

<script>
  // NOTE: Show product image from Supabase if available.
  // The server already populated title/price above; this only adds the image.
  const SBURL = '${SUPABASE_URL}';
  const SBKEY = '${SUPABASE_ANON_KEY}';
  const id = '${esc(id)}';
  if (id) {
    fetch(SBURL+'/rest/v1/listings?id=eq.'+id+'&select=listing_images(image_url,display_order)&limit=1',
      {headers:{apikey:SBKEY}})
      .then(r=>r.json()).then(data=>{
        const imgs = ((data&&data[0]&&data[0].listing_images)||[])
          .sort((a,b)=>(a.display_order||0)-(b.display_order||0));
        if(imgs[0]?.image_url){
          const img=document.getElementById('product-img');
          img.src=imgs[0].image_url;
          img.style.display='block';
        }
      }).catch(()=>{});
  }
</script>
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
