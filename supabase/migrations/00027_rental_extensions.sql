-- ════════════════════════════════════════════════════════════
-- 00027: Rental Extensions Table
--
-- Allows buyers to request rental period changes (extend/shorten).
-- Seller can approve or reject. On approval, order dates update.
-- ════════════════════════════════════════════════════════════

-- ─── New table for extension requests ───

CREATE TABLE public.rental_extensions (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id       uuid NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  requested_by   uuid NOT NULL REFERENCES auth.users(id),
  request_type   text NOT NULL CHECK (request_type IN ('extend', 'shorten')),
  original_end_date timestamptz NOT NULL,
  new_end_date   timestamptz NOT NULL,
  price_diff     numeric(10,2) NOT NULL DEFAULT 0,
  new_total      numeric(10,2) NOT NULL,
  status         text NOT NULL DEFAULT 'pending'
                   CHECK (status IN ('pending', 'approved', 'rejected')),
  responded_at   timestamptz,
  rejection_note text,
  created_at     timestamptz NOT NULL DEFAULT now(),
  updated_at     timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_rental_ext_order ON public.rental_extensions(order_id);
CREATE INDEX idx_rental_ext_status ON public.rental_extensions(status);

-- ─── RLS ───

ALTER TABLE public.rental_extensions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Buyer and seller can view extensions"
  ON public.rental_extensions FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.orders o
      WHERE o.id = rental_extensions.order_id
        AND (o.buyer_id = auth.uid() OR o.seller_id = auth.uid())
    )
  );

CREATE POLICY "Buyer can request extensions"
  ON public.rental_extensions FOR INSERT
  WITH CHECK (requested_by = auth.uid());

CREATE POLICY "Seller can respond to extensions"
  ON public.rental_extensions FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.orders o
      WHERE o.id = rental_extensions.order_id
        AND o.seller_id = auth.uid()
    )
  );

-- ─── Auto-update order on approval ───

CREATE OR REPLACE FUNCTION public.apply_rental_extension()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  -- Only act when status changes to 'approved'
  IF OLD.status = 'pending' AND NEW.status = 'approved' THEN
    UPDATE public.orders
    SET rental_end_date = NEW.new_end_date,
        total_price = NEW.new_total,
        updated_at = now()
    WHERE id = NEW.order_id;
  END IF;
  
  -- Set responded_at timestamp
  IF OLD.status = 'pending' AND NEW.status IN ('approved', 'rejected') THEN
    NEW.responded_at := now();
    NEW.updated_at := now();
  END IF;
  
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_rental_extension_response
  BEFORE UPDATE OF status ON public.rental_extensions
  FOR EACH ROW EXECUTE FUNCTION public.apply_rental_extension();

-- ─── Notifications for extension requests ───

CREATE OR REPLACE FUNCTION public.notify_rental_extension()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_listing_title text;
  v_seller_id uuid;
  v_buyer_id uuid;
  v_type_label text;
BEGIN
  SELECT o.seller_id, o.buyer_id, l.title
  INTO v_seller_id, v_buyer_id, v_listing_title
  FROM public.orders o
  JOIN public.listings l ON l.id = o.listing_id
  WHERE o.id = NEW.order_id;

  v_listing_title := coalesce(v_listing_title, 'a rental');
  v_type_label := CASE WHEN NEW.request_type = 'extend' THEN 'extension' ELSE 'early return' END;

  -- New request → notify seller
  IF TG_OP = 'INSERT' THEN
    INSERT INTO public.notifications
      (user_id, type, title, body, related_order_id, action_type)
    VALUES (
      v_seller_id, 'rental_extension', 'Rental ' || initcap(v_type_label) || ' Request',
      'The buyer requested a rental ' || v_type_label || ' for "' || v_listing_title || '"',
      NEW.order_id, 'order'
    );
  END IF;

  -- Response → notify buyer
  IF TG_OP = 'UPDATE' AND OLD.status = 'pending' AND NEW.status IN ('approved', 'rejected') THEN
    INSERT INTO public.notifications
      (user_id, type, title, body, related_order_id, action_type)
    VALUES (
      v_buyer_id,
      'rental_extension',
      'Rental ' || initcap(v_type_label) || ' ' || initcap(NEW.status),
      CASE WHEN NEW.status = 'approved'
        THEN 'The seller approved your rental ' || v_type_label || ' for "' || v_listing_title || '"'
        ELSE 'The seller rejected your rental ' || v_type_label || ' for "' || v_listing_title || '"'
      END,
      NEW.order_id,
      'order'
    );
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER on_rental_extension_notify
  AFTER INSERT OR UPDATE OF status ON public.rental_extensions
  FOR EACH ROW EXECUTE FUNCTION public.notify_rental_extension();

-- ─── Updated timestamp trigger ───

CREATE TRIGGER set_rental_extension_updated_at
  BEFORE UPDATE ON public.rental_extensions
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();
