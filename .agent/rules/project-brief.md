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
- PostgreSQL: all structured data (users, listings, orders, messages, etc.)
- Row Level Security (RLS): enforced on all tables, no client-side trust
- Supabase Storage: product images, user avatars, order evidence photos
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
- Migrations are stored in supabase/migrations/ (00001–00032)

## Implemented Features (as of v4.0)

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
- Create listing: title, description, photos (with crop), category, price,
  condition, sale or rent, pickup location
- Categories: furniture, electronics, instruments, books, clothing, sports, other
- View own listings with stats: views, saves, inquiries
- Manage Transactions button on own listing detail

### Transaction Management Dashboard
- Accessed from listing detail (own listings only)
- Three tabs: Views, Saves, Offers
- Offers tab: buyer avatar, name, email, order amount, status chips
- Accept button for pending orders (atomically rejects competing offers)
- Chat button to message buyers directly
- Listing preview section at top showing item name and price

### Discovery (Buyer)
- Home feed with category filter chips
- Search by keyword
- Listing detail page: photo carousel with condition badge, description,
  seller profile card, save/bookmark button

### Listing Detail (Buyer-Specific Logic)
- Floating fixed back button (does not scroll away)
- Bookmark/save toggle (hidden for own listings)
- "Application Submitted" card replaces action button for pending orders
- Rental options section with date picker and rate selection
- Condition label displayed below title (not on image)
- Seller card shows avatar, name, email, and message button
- Seller's own view: read-only rental rate cards, read-only pickup location

### Transactions
- Submit purchase request ("Request to Buy") or rental application
- Seller accepts via Transaction Management dashboard
  (Accept atomically sets competing offers to 'missed')
- Sale order flow: pending → confirmed → buyer confirms pickup → completed
- Rental order flow: pending → confirmed → dual delivery confirmation →
  active → buyer requests return → seller confirms return →
  seller refunds deposit → completed
- Cancel allowed before delivery confirmation
- Missed status for competing offers that lost

### Buyer Center
- Accessed from Orders hub
- Four sections: Requested (pending), Awaiting Delivery, Active Transactions, History
- Status chips per order (Pending/Pickup/Active/Returning/Returned/Refunded/Done/Missed)
- Red dot indicators for unread order updates
- Badge count on hub entry card
- Tap to navigate to order detail

### Seller Center
- Accessed from Orders hub
- Active Listings section (icon-only stats: views, saves, offers)
- Awaiting Delivery section
- Active Transactions section
- History section (dual timestamp, partitioned tap navigation)
- Red dot indicators for unread order updates
- Badge count on hub entry card

### Orders Hub
- Replaced legacy "My Orders" tab
- Two gradient cards: Buyer Center / Seller Center
- Badge counts showing pending orders per role
- Bottom navigation bar shows unread order update count
- Clean entry point to role-specific order management

### Order Detail
- Separate screens for Sale vs Rental orders
- Three-column timeline: date (left) → dot/line (center) → status/subtitle (right)
  - Dynamic steps based on order lifecycle
  - Cancelled/missed steps shown in red
  - Subtitles show buyer name, pickup location, etc.
- Financial summary card (type, rates, deposit; total only for sale)
- Order info section (listed date, type, status, pickup, price, deposit, grand total)
- Rental period section (duration, start/end dates, return date)
- Delivery confirmation status (dual-party for rentals)
- Evidence photos: delivery + return evidence (up to 5 each)
- Chat history (collapsible, full conversation transcript)
- Rental extension card (inline quantity selector for buyer, detail view for seller)
- Rental reminder settings (buyer only, active rentals)
- Rental lifecycle actions (Request Return → Confirm Return → Refund Deposit)
- Action buttons (Confirm Pickup, Cancel; Accept removed from this page)

### Evidence Photos
- Upload up to 5 photos per order before confirming delivery
- Separate sections for delivery evidence and return evidence (rentals)
- Stored in `order-files` Supabase Storage bucket
- Referenced via `order_evidence` table with RLS
- Both buyer and seller can upload

### Saved Items
- Save / unsave listings via bookmark button on detail page
- View saved listings list (from profile/settings)

### Chat
- 1-on-1 messaging between buyer and seller, tied to a specific listing
- Real-time via Supabase Realtime
- Message history persisted in PostgreSQL
- Chat room: partner avatar + name + email in AppBar
- Message bubbles without avatars, with yyyy-MM-dd HH:mm timestamps
- Image messages: inline preview with tap-to-view lightbox
- Chat history viewable from order detail (collapsible section)
- Unread message count badge on bottom nav bar

### Settings
- Personal info: name, avatar, .edu email (read-only after verify)
- App settings: notifications on/off
- Help center
- System settings
- Logout / delete account

### Notifications
- In-app notification center
- Real-time order status updates
- Unread count badges: bottom nav bar (orders), hub cards, order list red dots
- Notification types: order_placed, order_accepted, order_cancelled,
  order_completed, rental_extension, rental_reminder

### Rental Period Adjustments
- Buyer can request extension or shortening of active rentals
- Quantity-based adjustment (preserves rental rate type: daily/weekly/monthly)
- Inline UI with real-time price calculation
- Seller approves or rejects with optional rejection note
- On approval: order dates and total price update automatically via DB trigger
- SnackBar feedback for all actions
- Tracked in `rental_extensions` table with full audit trail

### Theme System
- SmivoThemeExtension with semantic design tokens
- Two theme variants: Teal (default) and IKEA
- All UI components use theme tokens (colors, typography, radius, shadows)
- Runtime theme switching via Riverpod provider

## Future Features (Phase 2+)

- AI listing assistant: photo → auto-generate title, description, price suggestion
- AI-powered search: natural language + proximity-based (pgvector on Supabase)
- Home feed advertisements (monetization)
- Escrow / guaranteed transaction service (monetization)
- Rental insurance integration (monetization)
- Third-party service provider integrations
- Multi-school expansion (school selector at onboarding)
- View tracking: individual viewer details in transaction management
- In-app payment processing (Venmo/Zelle integration)

## Item Categories

furniture | electronics | instruments | books | clothing | sports | other

## Item Conditions

new | like_new | good | fair | poor

## Transaction Types

- Sale: one-time purchase, ownership transfers
- Rental: time-limited, item returned after agreed period
  - Rental rate types: daily, weekly, monthly
  - Deposit required (configurable by seller)

## Design Principles

- Follow Stitch designs exactly — pixel accuracy matters
- Clean, minimal UI suitable for a young student audience
- Responsive layouts that work on mobile (iOS/Android) and web (desktop/tablet)
- Thumb-friendly touch targets on mobile (min 44x44pt)
- Fast perceived performance — use optimistic UI updates where appropriate
- Trust signals visible throughout: verified badge, school name tag

## Out of Scope (Current Phase)

- In-app payment processing (users arrange payment offline or via Venmo/Zelle)
- Shipping / delivery logistics
- Push notification deep links (basic notifications only)
- Admin dashboard
- Multi-language UI (English only for now)
- View tracking per user (Views tab shows anonymous counts only)
- AI listing assistant and AI-powered search (Phase 2+)