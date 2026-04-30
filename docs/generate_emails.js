const fs = require('fs');
const path = require('path');

const templates = [
  {
    name: 'invite_user',
    title: 'You have been invited',
    subject: 'You have been invited to join Smivo',
    text: 'You have been invited to join Smivo, the exclusive campus marketplace. Click the button below to accept your invitation and set up your account.',
    buttonText: 'Accept Invitation',
    link: '{{ .ConfirmationURL }}'
  },
  {
    name: 'magic_link',
    title: 'Your Magic Link',
    subject: 'Your Magic Link to sign in to Smivo',
    text: 'Click the button below to sign in to your Smivo account. This link will expire soon.',
    buttonText: 'Sign In',
    link: '{{ .ConfirmationURL }}'
  },
  {
    name: 'reauthentication',
    title: 'Reauthentication Code',
    subject: 'Confirm your action on Smivo',
    text: 'Please use the following code to confirm your recent action on Smivo. Do not share this code with anyone.',
    code: '{{ .Token }}',
    footerAction: 'If you didn\'t request this, please secure your account immediately.'
  },
  {
    name: 'password_changed',
    title: 'Password Changed',
    subject: 'Your Smivo password has been changed',
    text: 'This is a confirmation that the password for your Smivo account has been changed successfully.',
    footerAction: 'If you didn\'t make this change, please contact support and secure your account immediately.'
  },
  {
    name: 'email_changed_notice',
    title: 'Email Address Changed',
    subject: 'Your Smivo email address has been changed',
    text: 'This is a confirmation that the email address associated with your Smivo account has been changed.',
    footerAction: 'If you didn\'t make this change, please contact support immediately.'
  },
  {
    name: 'phone_changed',
    title: 'Phone Number Changed',
    subject: 'Your Smivo phone number has been changed',
    text: 'This is a confirmation that the phone number associated with your Smivo account has been changed.',
    footerAction: 'If you didn\'t make this change, please contact support immediately.'
  },
  {
    name: 'identity_linked',
    title: 'New Identity Linked',
    subject: 'A new identity was linked to your Smivo account',
    text: 'This is a confirmation that a new third-party identity (e.g., Google or Apple) has been linked to your Smivo account.',
    footerAction: 'If you didn\'t make this change, please secure your account immediately.'
  },
  {
    name: 'identity_unlinked',
    title: 'Identity Unlinked',
    subject: 'An identity was unlinked from your Smivo account',
    text: 'This is a confirmation that a third-party identity has been unlinked from your Smivo account.',
    footerAction: 'If you didn\'t make this change, please secure your account immediately.'
  },
  {
    name: 'mfa_added',
    title: 'Two-Factor Auth Enabled',
    subject: 'Two-factor authentication enabled on Smivo',
    text: 'You have successfully enabled two-factor authentication (2FA) for your Smivo account. Your account is now more secure.',
    footerAction: 'If you didn\'t make this change, please secure your account immediately.'
  },
  {
    name: 'mfa_removed',
    title: 'Two-Factor Auth Disabled',
    subject: 'Two-factor authentication disabled on Smivo',
    text: 'You have disabled two-factor authentication (2FA) for your Smivo account. Your account is now less secure.',
    footerAction: 'If you didn\'t make this change, please secure your account immediately.'
  }
];

const generateHTML = (t) => {
  let content = `
      <h1 class="logo">smivo</h1>
      <h2 class="title">${t.title}</h2>
      <p class="text">${t.text}</p>`;

  if (t.buttonText && t.link) {
    content += `
      <a href="${t.link}" class="button">${t.buttonText}</a>
      <p class="text" style="font-size: 14px;">If the button doesn't work, copy and paste this link into your browser:<br>
        <a href="${t.link}" class="link">${t.link}</a>
      </p>`;
  } else if (t.code) {
    content += `
      <div style="background-color: #F8F9FE; padding: 24px; border-radius: 8px; margin-bottom: 32px; letter-spacing: 4px; font-size: 32px; font-weight: bold; color: #2D5BFF;">
        ${t.code}
      </div>`;
  } else {
    // Just info, maybe a generic button to go to app
    content += `
      <a href="{{ .SiteURL }}" class="button" style="background-color: #F8F9FE; color: #2B2A51 !important; border: 1px solid #E5EBFF;">Go to Smivo</a>
    `;
  }

  content += `
      <div class="footer">
        <p style="margin: 0;">${t.footerAction || 'If you have any questions, feel free to reply to this email.'}</p>
        <p style="margin: 10px 0 0 0;">&copy; 2026 Smivo Marketplace. All rights reserved.</p>
      </div>`;

  return `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${t.title}</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #F8F9FE; margin: 0; padding: 0; -webkit-font-smoothing: antialiased; }
    .container { max-width: 600px; margin: 0 auto; padding: 40px 20px; }
    .card { background-color: #FFFFFF; border-radius: 16px; padding: 40px; box-shadow: 0 4px 24px rgba(43, 42, 81, 0.04); text-align: center; }
    .logo { font-size: 28px; font-weight: 800; color: #2D5BFF; letter-spacing: -0.5px; margin: 0; margin-bottom: 24px; }
    .title { font-size: 24px; font-weight: 700; color: #2B2A51; margin-top: 0; margin-bottom: 16px; }
    .text { font-size: 16px; line-height: 1.6; color: #646681; margin-bottom: 32px; }
    .button { display: inline-block; background-color: #2D5BFF; color: #FFFFFF !important; font-weight: 600; font-size: 16px; text-decoration: none; padding: 14px 32px; border-radius: 8px; margin-bottom: 32px; }
    .footer { font-size: 13px; color: #9A9CAE; margin-top: 32px; border-top: 1px solid #E5EBFF; padding-top: 24px; }
    .link { color: #2D5BFF; word-break: break-all; font-size: 14px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="card">
${content}
    </div>
  </div>
</body>
</html>`;
};

const dir = path.join(__dirname, 'docs', 'email_templates');
if (!fs.existsSync(dir)){
    fs.mkdirSync(dir, { recursive: true });
}

templates.forEach(t => {
  fs.writeFileSync(path.join(dir, t.name + '.html'), generateHTML(t));
});
console.log('Done generating all templates');
