// website/api/send-delete-email.js
export default async function handler(req, res) {
  // 仅允许 POST 请求
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { requester_email, request_type, selected_items, timestamp } = req.body;
  const apiKey = process.env.RESEND_API_KEY;

  if (!apiKey) {
    return res.status(500).json({ error: 'RESEND_API_KEY is not configured in Vercel environment variables.' });
  }

  try {
    const response = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        from: 'Smivo System <system@smivo.io>',
        to: ['support@smivo.io'],
        subject: `Data Deletion Request: ${requester_email}`,
        html: `
          <div style="font-family: sans-serif; line-height: 1.6; color: #333;">
            <h2 style="color: #1a3a6b;">New Data Deletion Request</h2>
            <p><strong>User Email:</strong> ${requester_email}</p>
            <p><strong>Request Type:</strong> ${request_type}</p>
            <p><strong>Specific Items:</strong> ${selected_items}</p>
            <p><strong>Submitted At:</strong> ${timestamp}</p>
            <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;" />
            <p style="font-size: 12px; color: #999;">This request was generated automatically from smivo.io</p>
          </div>
        `,
      }),
    });

    const data = await response.json();

    if (response.ok) {
      return res.status(200).json({ success: true, id: data.id });
    } else {
      return res.status(response.status).json({ error: data.message });
    }
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
}
