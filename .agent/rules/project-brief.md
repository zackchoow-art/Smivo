---
trigger: always_on
---

# Project Brief: Smivo

## Overview

Smivo is a mobile and web marketplace for college students to buy, sell, and
rent used items within their campus community. Identity is verified via
university .edu email to ensure a trusted, campus-only environment.

The name Smivo originates from Smith College, where the app launches first.
The brand is designed to scale — Smivo works as a standalone identity
independent of any single school.

Initial launch: Smith College.
Expansion model: one school = one isolated community zone.

## Target Users

- College students (sellers and buyers/renters)
- Must register with a valid .edu email address
- Guest browsing allowed; account required for transactions, chat, and orders

## Platform

- iOS + Android + Web (Flutter single codebase, all three targets)
- Minimum OS: iOS 16 / Android 8.0 (API 26)
- Web: responsive, supports desktop and mobile browser
- App ID / Bundle ID: com.smivo

## Design

- All UI screens are designed in Google Stitch
- Always convert Stitch designs to Flutter code using the /stitch command
- Do not invent layouts or UI components — follow the Stitch designs exactly
- Stitch design files are located in stitch_* folders at the project root

## Backend: Supabase

- Supabase Auth: email/password login + .edu domain enforcement at signup
- PostgreSQL: all structured data (users, listings, orders, messages)
- Row Level Security (RLS): enforced on all tables, no client-side trust
- Supabase Storage: product images and user avatars
- Supabase Realtime: live chat messages and order status updates
- Supabase Edge Functions: server-side logic (email verification, order flow)
- Push Notifications: OneSignal (Supabase has no built-in FCM)

## Database Design Principles

- Use relational modeling — normalize data, avoid duplication
- Every table must have: id (uuid), created_at, updated_at
- Use foreign keys and enforce referential integrity
- Never embed nested objects as JSON unless truly unstructured data
- All queries go through Supabase client — no raw SQL from Flutter except
in Edge Functions

## Core Features (Phase 1 — MVP)

### Guest Access

- Home feed browsable without login
- Listing detail page viewable without login
- Login prompt appears only when user attempts to: message, buy, rent, or save

### Authentication

- Register with .edu email (sends verification link)
- Enforce .edu domain at signup — reject all other email domains
- Login / logout
- Basic profile setup (name, school, avatar)

### Listings (Seller)

- Create listing: title, description, photos, category, price, sale or rent
- Categories: furniture, electronics, instruments, books, clothing, sports, other
- View own listings with stats: views, saves, inquiries, orders
- Edit / deactivate / delete listing

### Discovery (Buyer)

- Home feed with category filters
- Search by keyword
- Listing detail page: photos, description, seller info, contact button

### Transactions

- Submit purchase request or rental application
- Seller accepts or declines
- Order status tracking: pending → confirmed → completed / cancelled
- Rental orders include: start date, end date, return confirmation

### Saved Items

- Save / unsave listings
- View saved listings list

### Chat

- 1-on-1 messaging between buyer and seller, tied to a specific listing
- Real-time via Supabase Realtime
- Message history persisted in PostgreSQL

### Orders

- View active orders
- View order history
- Basic order detail page

### Settings

- Personal info: name, avatar, .edu email (read-only after verify)
- App settings: notifications on/off, language (en placeholder)
- Logout / delete account

## Future Features (Phase 2+)

- AI listing assistant: photo → auto-generate title, description, price suggestion
- AI-powered search: natural language + proximity-based (pgvector on Supabase)
- Home feed advertisements (monetization)
- Escrow / guaranteed transaction service (monetization)
- Rental insurance integration (monetization)
- Third-party service provider integrations
- Multi-school expansion (school selector at onboarding)

## Item Categories

furniture | electronics | instruments | books | clothing | sports | other

## Transaction Types

- Sale: one-time purchase, ownership transfers
- Rental: time-limited, item returned after agreed period

## Design Principles

- Follow Stitch designs exactly — pixel accuracy matters
- Clean, minimal UI suitable for a young student audience
- Responsive layouts that work on mobile (iOS/Android) and web (desktop/tablet)
- Thumb-friendly touch targets on mobile (min 44x44pt)
- Fast perceived performance — use optimistic UI updates where appropriate
- Trust signals visible throughout: verified badge, school name tag

## Out of Scope (Phase 1)

- In-app payment processing (users arrange payment offline or via Venmo/Zelle)
- Shipping / delivery logistics
- Push notification deep links (basic notifications only)
- Admin dashboard
- Multi-language UI (English only for now)