import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { 
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      }
    })
  }

  try {
    const { requester_email, request_type, selected_items, timestamp } = await req.json()

    // Create email content
    const htmlContent = `
      <h2>New Data Deletion Request</h2>
      <p><strong>User Email:</strong> ${requester_email}</p>
      <p><strong>Request Type:</strong> ${request_type}</p>
      <p><strong>Specific Items:</strong> ${selected_items}</p>
      <p><strong>Submitted At:</strong> ${timestamp}</p>
      <hr />
      <p>This request was generated from the Smivo Data Deletion Page.</p>
    `

    // Send email via Resend
    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${RESEND_API_KEY}`,
      },
      body: JSON.stringify({
        from: 'Smivo System <system@smivo.io>',
        to: ['support@smivo.io'],
        subject: `Data Deletion Request: ${requester_email}`,
        html: htmlContent,
      }),
    })

    const data = await res.json()

    return new Response(
      JSON.stringify(data),
      { 
        status: res.status,
        headers: { 
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        } 
      }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        status: 400,
        headers: { 
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        } 
      }
    )
  }
})
