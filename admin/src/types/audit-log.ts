/**
 * Audit log types — the "black box" of admin operations.
 * Defined in 04_ADMIN_WEB_SPEC.md §20.
 */

export interface AuditLog {
  id: string;
  admin_id: string;
  // NOTE: DB column is 'action_type', not 'action'
  action_type: string;
  target_type: string;
  target_id: string | null;
  college_id: string | null;
  payload: Record<string, unknown> | null;
  status_before: string | null;
  status_after: string | null;
  ip_address: string | null;
  user_agent: string | null;
  created_at: string;
}

/** Audit log with admin name for display */
export interface AuditLogWithAdmin extends AuditLog {
  admin_name: string | null;
  admin_email: string;
}
