#!/bin/bash
# ═══════════════════════════════════════════════════════
# Smivo: Clean ALL business data, keep user accounts
#
# Preserves: user_profiles, schools, pickup_locations
# Deletes:   orders, listings, chats, notifications, etc.
#
# Usage: ./clean_test_data.sh
# ═══════════════════════════════════════════════════════

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "⚠️  This will DELETE all business data (orders, listings, chats, notifications)."
echo "   User accounts (test1, test2, Test.buyer) will be preserved."
echo ""
echo "Press Enter to continue, or Ctrl+C to cancel..."
read -r

echo "🧹 Cleaning test data..."

"$SCRIPT_DIR/db.sh" <<'SQL'
-- Disable triggers temporarily to avoid cascade issues
SET session_replication_role = 'replica';

-- 1. Rental extensions (FK → orders)
TRUNCATE TABLE public.rental_extensions CASCADE;

-- 2. Order evidence (FK → orders)
TRUNCATE TABLE public.order_evidence CASCADE;

-- 3. Messages (FK → chat_rooms)
TRUNCATE TABLE public.messages CASCADE;

-- 4. Chat rooms (FK → listings, user_profiles)
TRUNCATE TABLE public.chat_rooms CASCADE;

-- 5. Saved listings (FK → listings, user_profiles)
TRUNCATE TABLE public.saved_listings CASCADE;

-- 6. Orders (FK → listings, user_profiles)
TRUNCATE TABLE public.orders CASCADE;

-- 7. Listing views (FK → listings)
TRUNCATE TABLE public.listing_views CASCADE;

-- 8. Listing images (FK → listings)
TRUNCATE TABLE public.listing_images CASCADE;

-- 9. Listings
TRUNCATE TABLE public.listings CASCADE;

-- 10. Notifications
TRUNCATE TABLE public.notifications CASCADE;

-- Re-enable triggers
SET session_replication_role = 'origin';
SQL

echo ""
echo "✅ Done! All business data has been cleared."
echo "   Preserved: 3 user accounts, schools, pickup locations."
echo ""
echo "   Tables cleared:"
echo "   - rental_extensions"
echo "   - order_evidence"
echo "   - messages"
echo "   - chat_rooms"
echo "   - saved_listings"
echo "   - orders"
echo "   - listing_views"
echo "   - listing_images"
echo "   - listings"
echo "   - notifications"
