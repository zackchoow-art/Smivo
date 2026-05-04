import puppeteer from 'puppeteer';

(async () => {
  const browser = await puppeteer.launch({ headless: "new" });
  const page = await browser.newPage();
  
  page.on('response', async (response) => {
    if (response.url().includes('supabase.co')) {
      const status = response.status();
      if (status >= 400) {
        console.log(`[${status}] ${response.url()}`);
        try {
          const text = await response.text();
          console.log('RESPONSE TEXT:', text);
        } catch (e) {}
      }
    }
  });

  await page.goto('http://localhost:5173/moderation/listings', { waitUntil: 'networkidle2' });
  
  await new Promise(r => setTimeout(r, 2000));
  await browser.close();
})();
