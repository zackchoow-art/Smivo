-- Add is_admin to user_profiles
ALTER TABLE public.user_profiles
ADD COLUMN is_admin boolean NOT NULL DEFAULT false;

-- Update FAQs policies
-- We already have "FAQs are viewable by everyone." on public.faqs for select using (true);
-- Let's add admin policies

CREATE POLICY "Admins can insert FAQs"
ON public.faqs
FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.user_profiles
    WHERE id = auth.uid() AND is_admin = true
  )
);

CREATE POLICY "Admins can update FAQs"
ON public.faqs
FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM public.user_profiles
    WHERE id = auth.uid() AND is_admin = true
  )
);

CREATE POLICY "Admins can delete FAQs"
ON public.faqs
FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM public.user_profiles
    WHERE id = auth.uid() AND is_admin = true
  )
);

-- Convenience function to make someone an admin (run manually)
-- select make_admin('user_email@edu.com');
CREATE OR REPLACE FUNCTION public.make_admin(user_email text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.user_profiles SET is_admin = true WHERE email = user_email;
END;
$$;
