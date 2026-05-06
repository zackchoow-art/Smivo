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
    *{margin:0;padding:0;box-sizing:border-box;}
    body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;background:#0f172a;min-height:100vh;display:flex;align-items:center;justify-content:center;padding:20px;-webkit-font-smoothing:antialiased;}
    .card{width:100%;max-width:420px;border-radius:20px;overflow:hidden;box-shadow:0 24px 60px rgba(0,0,0,.5);position:relative;background:#0f172a;}
    .img-wrap{position:relative;width:100%;aspect-ratio:4/3;background:#1e293b;overflow:hidden;}
    .img-wrap img{width:100%;height:100%;object-fit:cover;display:block;}
    .scrim{position:absolute;bottom:0;left:0;right:0;height:55%;background:linear-gradient(to top,rgba(0,0,0,.85) 0%,rgba(0,0,0,.4) 60%,transparent 100%);}
    .badge{position:absolute;top:14px;right:14px;padding:5px 14px;border-radius:8px;font-size:.8rem;font-weight:700;color:#fff;}
    .badge-sale{background:#2563eb;}
    .badge-rent{background:#0d9488;}
    .logo-pill{position:absolute;top:14px;left:14px;background:rgba(255,255,255,.15);border:1px solid rgba(255,255,255,.25);border-radius:100px;padding:5px 14px;font-size:.8rem;font-weight:800;color:#fff;}
    .overlay-text{position:absolute;bottom:0;left:0;right:0;padding:14px 18px;}
    .ot-title{font-size:1.05rem;font-weight:700;color:#fff;margin-bottom:2px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;text-shadow:0 1px 4px rgba(0,0,0,.5);}
    .ot-price{font-size:1.4rem;font-weight:800;color:#fff;letter-spacing:-.5px;text-shadow:0 1px 4px rgba(0,0,0,.5);}
    .actions{padding:20px 18px 18px;display:flex;flex-direction:column;gap:10px;}
    .btn{display:flex;align-items:center;justify-content:center;gap:8px;padding:13px 20px;border-radius:12px;font-size:.95rem;font-weight:600;text-decoration:none;transition:transform .15s,box-shadow .15s;}
    .btn:hover{transform:translateY(-2px);box-shadow:0 6px 20px rgba(0,0,0,.3);}
    .btn-primary{background:linear-gradient(135deg,#1a3a6b,#2a5298);color:#fff;}
    .btn-secondary{background:rgba(255,255,255,.08);color:rgba(255,255,255,.85);border:1px solid rgba(255,255,255,.15);}
    .footer{text-align:center;font-size:.75rem;color:rgba(255,255,255,.3);padding-bottom:18px;}
  </style>
</head>
<body>
<div class="card">
  <!-- Product image with scrim + overlay text -->
  <div class="img-wrap">
    <img id="product-img" src="https://smivo.io/og-image.png" alt="${esc(title)}">
    <div class="scrim"></div>
    <div class="logo-pill">Smivo</div>
    ${badge ? `<div class="badge badge-${badge.toLowerCase()}">${esc(badge)}</div>` : ''}
    <div class="overlay-text">
      <div class="ot-title">${esc(title)}</div>
      ${priceText ? `<div class="ot-price">${esc(priceText)}</div>` : ''}
    </div>
  </div>

  <!-- Action buttons -->
  <div class="actions">
    <a href="https://apps.apple.com/us/app/smivo/id6764173442"
       class="btn btn-primary" target="_blank" rel="noopener noreferrer">
      📱 Download on App Store
    </a>
    <!-- NOTE: Link to smivo.app (Flutter web app on GitHub Pages) with
         the listing path so users can view the item without installing. -->
    <a id="btn-webapp"
       href="https://smivo.app/listing/${esc(id)}"
       class="btn btn-secondary">
      🌐 Open Web App
    </a>
  </div>
  <div class="footer">smivo.io · Campus Marketplace</div>
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
