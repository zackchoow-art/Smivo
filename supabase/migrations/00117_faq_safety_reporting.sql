-- ============================================================
-- Migration 00117: Add Safety & Reporting FAQ entries
-- ============================================================
-- Adds a new "Safety & Reporting" category covering:
--   1. AI content moderation (listing images, what happens when flagged)
--   2. How to report a listing or user
--   3. What happens after submitting a report
--   4. Blocking users
--
-- Pattern: Insert as global (school_id = NULL) first, then
-- copy to all existing schools that don't yet have each question.
-- ============================================================


-- ─── 1. Insert global FAQ entries (school_id = NULL) ─────────

INSERT INTO public.faqs (school_id, category, question, answer, display_order) VALUES

-- Content moderation
(NULL,
 'Safety & Reporting',
 'Why is my listing under review?',
 'Smivo uses an AI-powered content review system to help keep the marketplace safe for everyone. When you post a new listing or upload photos, our system automatically scans the content in the background. If anything is flagged for review, your listing will temporarily display an "Under Review" status. This is usually resolved within a few minutes. Your listing remains visible to you at all times, and you will be notified of the outcome.',
 19),

(NULL,
 'Safety & Reporting',
 'Why is one of my listing photos blurred?',
 'If a photo in your listing was found to contain content that violates our community guidelines (such as nudity, graphic imagery, or prohibited items), it will be automatically blurred for other users while your listing is under review. You can edit your listing to replace the flagged photo with a compliant one. Once updated, the listing will be re-reviewed automatically.',
 20),

(NULL,
 'Safety & Reporting',
 'What happens if my listing is rejected or taken down?',
 'If our system or a platform moderator determines that a listing violates Smivo''s Community Guidelines, the listing will be marked as "Rejected" or "Taken Down" and will no longer be visible to other users. You will see a note in your listing detail explaining the reason. You may edit the listing to fix the issue and resubmit it. Repeated or severe violations may result in account suspension.',
 21),

-- Reporting
(NULL,
 'Safety & Reporting',
 'How do I report a listing or a user?',
 'To report a listing: open the listing detail page, tap the ⋯ (more) icon in the top-right corner, and select "Report." To report a user: open their profile from a listing or chat, tap the ⋯ menu, and select "Report User." Choose the most applicable reason and add any additional context. All reports are reviewed by our Trust & Safety team.',
 22),

(NULL,
 'Safety & Reporting',
 'What happens after I submit a report?',
 'Your report is sent to Smivo''s Trust & Safety team for review. You will receive an in-app notification once the review is complete. If the report is upheld, you may earn contribution points as a thank-you for helping keep the community safe. You can view past reports and their outcomes in Settings > Help Center. Reports are always confidential — the reported user will never know who flagged them.',
 23),

(NULL,
 'Safety & Reporting',
 'What counts as a violation?',
 'Violations include: listing counterfeit, illegal, or prohibited items; using misleading photos or descriptions; harassment or threatening behavior in chat; sharing personal contact details in public listing descriptions; and posting content that is sexually explicit, violent, or discriminatory. When in doubt, refer to our Community Guidelines linked in Settings > Help Center.',
 24),

-- Blocking
(NULL,
 'Safety & Reporting',
 'How do I block another user?',
 'Open the chat with the user or visit their profile from a listing, then tap the ⋯ (more) icon and select "Block User." Once blocked: they cannot message you, view your listings, or submit offers to you — and you won''t see their listings either. Blocking is mutual and immediate. You can unblock a user at any time from Settings > Blocked Users.',
 25),

(NULL,
 'Safety & Reporting',
 'Can a blocked user still see my listings?',
 'No. When you block someone, they will no longer be able to see your listings in their feed or search results, and they cannot send you messages or submit purchase/rental requests. Likewise, you will not see their listings. Any existing chat threads between you will be archived.',
 26);


-- ─── 2. Copy new global FAQs to all existing schools ─────────
-- IDEMPOTENT: skips questions already present in a school's FAQ list.

INSERT INTO public.faqs (school_id, category, question, answer, display_order)
SELECT
  s.id,
  f.category,
  f.question,
  f.answer,
  f.display_order
FROM public.faqs f
CROSS JOIN public.schools s
WHERE f.school_id IS NULL
  AND f.category = 'Safety & Reporting'
  AND NOT EXISTS (
    SELECT 1 FROM public.faqs f2
    WHERE f2.school_id = s.id
      AND f2.question = f.question
  );
