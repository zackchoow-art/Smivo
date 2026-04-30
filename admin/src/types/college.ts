/**
 * College entity — core of multi-tenant architecture.
 * NOTE: In the database, this maps to the `schools` table (00010).
 * The Admin Web uses "college" terminology in the UI but queries
 * the `schools` table. This type mirrors the DB schema exactly.
 */
export interface College {
  id: string;
  slug: string;
  name: string;
  email_domain: string;
  primary_color: string | null;
  logo_url: string | null;
  is_active: boolean;
  created_at: string;
  updated_at: string;

  // Extended fields from 00038
  address: string | null;
  city: string | null;
  state: string | null;
  zip_code: string | null;
  country: string | null;
  latitude: number | null;
  longitude: number | null;
  timezone: string | null;
  website_url: string | null;
  description: string | null;
  student_count: number | null;
  cover_image_url: string | null;
}

/**
 * DB table name mapping — use this constant when querying Supabase.
 * The table is called `schools` in the DB but we call it `colleges` in the UI.
 */
export const COLLEGE_TABLE = 'schools' as const;
