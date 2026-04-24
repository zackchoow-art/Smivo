# Task 010b: UI & Flow Optimization — Batch 2 (P1/P2)

## Pre-requisites
- Read `.agent/docs/theme-architecture.md` for styling rules
- Complete task-010a first
- Read each target file fully before modifying

---

## 1. "Missed" 通知文案优化

### Problem
When a seller accepts one buyer, all other pending orders for that listing
are automatically cancelled. The current DB trigger sends a generic
"Order cancelled" notification to those other buyers, which is misleading
(they didn't cancel — they were outbid).

### Solution: New SQL migration

Create file: `supabase/migrations/00024_missed_order_notification.sql`

```sql
-- ════════════════════════════════════════════════════════════
-- 00024: Differentiate "missed" vs "cancelled" notifications
--
-- When an order is cancelled because the seller chose another buyer,
-- send a friendlier "offer missed" notification instead of
-- "order cancelled".
-- ════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.notify_order_status_change()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_listing_title text;
  v_title_snippet text;
  v_has_confirmed_order boolean;
BEGIN
  IF old.status IS NOT DISTINCT FROM new.status THEN
    RETURN NEW;
  END IF;

  SELECT title INTO v_listing_title
  FROM public.listings
  WHERE id = NEW.listing_id;
  v_title_snippet := coalesce(v_listing_title, 'your order');

  -- pending → confirmed (seller accepted this buyer)
  IF old.status = 'pending' AND new.status = 'confirmed' THEN
    INSERT INTO public.notifications
      (user_id, type, title, body, related_order_id, action_type)
    VALUES (
      NEW.buyer_id, 'order_accepted', 'Order accepted',
      'The seller accepted your order for "' || v_title_snippet || '"',
      NEW.id, 'order'
    );
  END IF;

  -- → cancelled
  IF new.status = 'cancelled' THEN
    -- Check if another order for the same listing was just confirmed
    -- (meaning this cancellation is due to seller choosing another buyer)
    SELECT EXISTS(
      SELECT 1 FROM public.orders
      WHERE listing_id = NEW.listing_id
        AND id != NEW.id
        AND status = 'confirmed'
    ) INTO v_has_confirmed_order;

    IF v_has_confirmed_order THEN
      -- This buyer was "outbid" — send a friendlier missed notification
      INSERT INTO public.notifications
        (user_id, type, title, body, related_order_id, action_type)
      VALUES (
        NEW.buyer_id, 'order_cancelled', 'Offer Missed',
        'Another buyer was selected for "' || v_title_snippet || '". Keep browsing for more great deals!',
        NEW.id, 'order'
      );
      -- Seller does NOT need a notification for auto-cancelled orders
    ELSE
      -- Normal cancellation (buyer or seller manually cancelled)
      INSERT INTO public.notifications
        (user_id, type, title, body, related_order_id, action_type)
      VALUES
        (NEW.buyer_id, 'order_cancelled', 'Order cancelled',
         'Your order for "' || v_title_snippet || '" was cancelled',
         NEW.id, 'order'),
        (NEW.seller_id, 'order_cancelled', 'Order cancelled',
         'The order for "' || v_title_snippet || '" was cancelled',
         NEW.id, 'order');
    END IF;
  END IF;

  -- → completed
  IF new.status = 'completed' THEN
    INSERT INTO public.notifications
      (user_id, type, title, body, related_order_id, action_type)
    VALUES
      (NEW.buyer_id, 'order_completed', 'Order completed',
       'Your order for "' || v_title_snippet || '" is complete',
       NEW.id, 'order'),
      (NEW.seller_id, 'order_completed', 'Order completed',
       'The order for "' || v_title_snippet || '" is complete',
       NEW.id, 'order');
  END IF;

  RETURN NEW;
END;
$$;
```

**NOTE**: This is a SQL migration file. Create it, but do NOT execute it.
The user will execute it manually in Supabase Dashboard.

---

## 2. Chat Popup 金额校验

### File: `lib/features/chat/widgets/chat_popup.dart` (or similar)

Find where the order amount is displayed in the chat popup header.
Verify:
- For sale orders: displays `order.totalPrice` (NOT `listing.price`)
- For rental orders: displays `order.totalPrice` with rental info

If `listing.price` is being used instead of `order.totalPrice`, fix it.
If no order context is available in the popup, check if it can be passed in.

Search for how the chat popup is invoked from listing detail:
```
grep -rn 'showChatPopup\|ChatPopup\|chatPopup' lib/
```

Trace the price parameter back to ensure it uses the correct source.

---

## 3. 全局用户头像

### Scope
Audit all pages that display user avatars and ensure they pull the real
`avatarUrl` from the user profile, not just show a placeholder icon.

### Files to check (search for `CircleAvatar`):
```bash
grep -rn 'CircleAvatar' lib/ --include='*.dart' -l
```

For each occurrence, ensure the pattern is:
```dart
CircleAvatar(
  backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
      ? NetworkImage(avatarUrl!)
      : null,
  child: avatarUrl == null || avatarUrl!.isEmpty
      ? Icon(Icons.person, color: colors.onSurface.withValues(alpha: 0.5))
      : null,
)
```

### Key files likely needing updates:
- `transaction_management_screen.dart` — viewer/saver/offer cards
- `seller_center_screen.dart` — Active Transactions buyer avatars
- `buyer_center_screen.dart` — order cards (if showing seller avatar)
- `order_detail_screen.dart` — buyer/seller info section

### Data availability
Check if the order/viewer/saver models include `avatarUrl`.
If not, the data might need to be joined in the repository query.

For the **Manage Transactions** screen (Views/Saves/Offers tabs):
- The user profiles are fetched — check if `avatar_url` is included
  in the select query in the repository

---

## Files to create/modify (summary)

| File | Changes |
|------|---------|
| `supabase/migrations/00024_missed_order_notification.sql` | **CREATE** — Differentiate missed vs cancelled notifications |
| `lib/features/chat/widgets/chat_popup.dart` | Verify/fix price display |
| Multiple files with `CircleAvatar` | Pull real `avatarUrl` |

## Testing

1. Accept offer → other buyers receive "Offer Missed" notification
   (not "Order cancelled")
2. Manually cancel order → both parties receive "Order cancelled"
3. Chat popup shows correct order price
4. All avatars display real images when available
5. Run `flutter analyze` — zero errors

## Execution order

1. Create the SQL migration file first (00024)
2. Fix chat popup price
3. Avatar audit (broad but low-risk)
