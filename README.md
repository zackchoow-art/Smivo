# Smivo — Campus Marketplace

A trusted campus marketplace for college students to buy, sell, and rent used items.

## Repository Structure

```
smivo/
├── app/           Flutter mobile + web app (iOS, Android, Web)
├── admin/         React admin dashboard (Vite + TypeScript)
├── website/       Static landing page & policies (smivo.io)
├── supabase/      Database migrations, Edge Functions, scripts
└── docs/          Internal documentation & assets
```

## Getting Started

### Mobile / Web App (Flutter)

```bash
cd app
flutter pub get
flutter run          # iOS/Android/Chrome
```

### Admin Dashboard (React)

```bash
cd admin
npm install
npm run dev          # http://localhost:5173
```

## Deployment

| Target           | Source      | Platform       |
|------------------|-------------|----------------|
| smivo.io         | `website/`  | Vercel         |
| admin.smivo.io   | `admin/`    | Vercel         |
| App Store        | `app/`      | Xcode → Apple  |
| Google Play      | `app/`      | Gradle → Google|

## Tech Stack

- **App**: Flutter 3.x + Riverpod + Supabase
- **Admin**: React + TypeScript + Vite + Supabase JS
- **Backend**: Supabase (PostgreSQL, Auth, Storage, Realtime, Edge Functions)
- **Hosting**: Vercel (website + admin)
