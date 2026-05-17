/**
 * Carpool trip detail page — mirrors all App-side information.
 * school_admin and above can modify trip status.
 */
import { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { ArrowLeft, MapPin, Clock, Users, DollarSign, Shield, FileText, User, Car } from 'lucide-react';
import { useCarpoolDetail, useUpdateCarpoolStatus } from '@/hooks/useCarpool';
import { useAdminRole } from '@/hooks/useAdminRole';
import {
  CARPOOL_STATUS_META,
  CARPOOL_MEMBER_STATUS_META,
  LUGGAGE_LABELS,
} from '@/types';
import type { CarpoolTripStatus, CarpoolMember } from '@/types';

// NOTE: All valid status values for the admin status update dropdown
const ALL_STATUSES: CarpoolTripStatus[] = [
  'active', 'inactive', 'confirmed', 'departed', 'arrived', 'completed', 'cancelled',
];

export function CarpoolDetailPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { canEditCarpoolStatus } = useAdminRole();
  const { trip, isLoading, error, refresh } = useCarpoolDetail(id);
  const { updateStatus, isUpdating } = useUpdateCarpoolStatus();

  const [newStatus, setNewStatus] = useState<CarpoolTripStatus | ''>('');
  const [reason, setReason] = useState('');
  const [statusError, setStatusError] = useState('');

  const handleStatusUpdate = async () => {
    if (!trip || !newStatus) return;
    setStatusError('');
    try {
      await updateStatus(trip.id, newStatus, reason);
      setNewStatus('');
      setReason('');
      await refresh();
    } catch (err) {
      setStatusError((err as Error).message);
    }
  };

  if (isLoading) {
    return <div className="cp-detail-loading">Loading trip details...</div>;
  }

  if (error || !trip) {
    return (
      <div className="cp-detail-error">
        <p>Failed to load trip details</p>
        <button onClick={() => navigate('/carpool')}>← Back to list</button>
      </div>
    );
  }

  const statusMeta = CARPOOL_STATUS_META[trip.status];
  const activeMemberCount = trip.members.filter(
    (m) => m.cancelled_at == null && (m.status === 'approved' || m.role === 'creator')
  ).length;

  return (
    <div className="cp-detail">
      {/* Header */}
      <header className="cp-detail-header">
        <button className="back-btn" onClick={() => navigate('/carpool')}>
          <ArrowLeft size={18} /> Back to Trips
        </button>
        <div className="header-row">
          <div>
            <h1 className="page-title">{trip.departure_description || trip.departure_address} → {trip.destination_description || trip.destination_address}</h1>
            <div className="header-meta">
              <span className="status-badge" style={{ backgroundColor: statusMeta.bgColor, color: statusMeta.color }}>
                {statusMeta.label}
              </span>
              <span className="meta-sep">·</span>
              <span className="meta-text">{trip.role === 'driver' ? '🚗 Driver' : '👥 Organizer'}</span>
              {trip.school?.name && (
                <>
                  <span className="meta-sep">·</span>
                  <span className="meta-text">{trip.school.name}</span>
                </>
              )}
              <span className="meta-sep">·</span>
              <span className="meta-text">ID: {trip.id.slice(0, 8)}...</span>
            </div>
          </div>
        </div>
      </header>

      {/* Content Grid */}
      <div className="cp-detail-grid">
        {/* Left Column */}
        <div className="cp-detail-left">
          {/* Route Card */}
          <InfoCard title="Route" icon={<MapPin size={16} />}>
            <InfoRow label="From" value={trip.departure_address} />
            <InfoRow label="To" value={trip.destination_address} />
            {trip.departure_description && (
              <InfoRow label="Origin Label" value={trip.departure_description} />
            )}
            {trip.destination_description && (
              <InfoRow label="Dest. Label" value={trip.destination_description} />
            )}
            {trip.departure_lat != null && trip.departure_lng != null && (
              <InfoRow label="Origin Coords" value={`${trip.departure_lat.toFixed(5)}, ${trip.departure_lng.toFixed(5)}`} />
            )}
            {trip.destination_lat != null && trip.destination_lng != null && (
              <InfoRow label="Dest. Coords" value={`${trip.destination_lat.toFixed(5)}, ${trip.destination_lng.toFixed(5)}`} />
            )}
          </InfoCard>

          {/* Trip Details Card */}
          <InfoCard title="Trip Details" icon={<Clock size={16} />}>
            <InfoRow label="Departure Time" value={new Date(trip.departure_time).toLocaleString()} />
            <InfoRow
              label="Est. Arrival"
              value={trip.estimated_arrival_time ? new Date(trip.estimated_arrival_time).toLocaleString() : 'Not set'}
            />
            <InfoRow label="Total Seats" value={String(trip.total_seats)} />
            <InfoRow label="Available Seats" value={String(trip.available_seats)} />
            <InfoRow label="Luggage Limit" value={trip.luggage_limit ? LUGGAGE_LABELS[trip.luggage_limit] || trip.luggage_limit : 'Not specified'} />
            <InfoRow label="Approval Mode" value={trip.approval_mode === 'auto' ? 'Auto-approve' : 'Manual approval'} />
            {trip.closing_time && (
              <InfoRow label="Closing Time" value={new Date(trip.closing_time).toLocaleString()} />
            )}
            {trip.note && (
              <InfoRow label="Note" value={trip.note} />
            )}
          </InfoCard>

          {/* Cost Card */}
          <InfoCard title="Cost & Settlement" icon={<DollarSign size={16} />}>
            {trip.role === 'driver' && trip.estimated_total_price != null && (
              <InfoRow label="Fixed Price" value={`$${trip.estimated_total_price.toFixed(2)}/person`} />
            )}
            {trip.role === 'organizer' && trip.estimated_total_price != null && (
              <>
                <InfoRow label="Est. Total" value={`$${trip.estimated_total_price.toFixed(2)}`} />
                <InfoRow
                  label="Est. Per Person"
                  value={`~$${(trip.estimated_total_price / (trip.total_seats + 1)).toFixed(2)}`}
                />
              </>
            )}
            {trip.actual_total_cost != null && (
              <>
                <InfoRow label="Final Total" value={`$${trip.actual_total_cost.toFixed(2)}`} highlight />
                {activeMemberCount > 0 && (
                  <InfoRow
                    label="Final Per Person"
                    value={`$${(trip.actual_total_cost / activeMemberCount).toFixed(2)} (${activeMemberCount} people)`}
                    highlight
                  />
                )}
              </>
            )}
            <InfoRow label="Settled At" value={trip.settled_at ? new Date(trip.settled_at).toLocaleString() : 'Not settled'} />
          </InfoCard>

          {/* Timestamps */}
          <InfoCard title="Timestamps" icon={<FileText size={16} />}>
            <InfoRow label="Created At" value={new Date(trip.created_at).toLocaleString()} />
            <InfoRow label="Updated At" value={new Date(trip.updated_at).toLocaleString()} />
          </InfoCard>
        </div>

        {/* Right Column */}
        <div className="cp-detail-right">
          {/* Organizer Card */}
          <InfoCard title="Organizer" icon={<User size={16} />}>
            <div className="organizer-info">
              {trip.creator?.avatar_url ? (
                <img src={trip.creator.avatar_url} alt="" className="organizer-avatar" />
              ) : (
                <div className="organizer-avatar-placeholder"><User size={20} /></div>
              )}
              <div>
                <div className="organizer-name">{trip.creator?.display_name || 'Unknown'}</div>
                <div className="organizer-email">{trip.creator?.email || '—'}</div>
                <div className="organizer-role">
                  {trip.role === 'driver' ? <><Car size={14} /> Driver</> : <><Users size={14} /> Organizer</>}
                </div>
              </div>
            </div>
          </InfoCard>

          {/* Members Card */}
          <InfoCard title={`Members (${trip.members.length})`} icon={<Users size={16} />}>
            {trip.members.length === 0 ? (
              <p className="empty-text">No members yet</p>
            ) : (
              <div className="members-list">
                {trip.members.map((m) => (
                  <MemberRow key={m.id} member={m} isCreator={m.user_id === trip.creator_id} />
                ))}
              </div>
            )}
          </InfoCard>

          {/* Status Update Card — only for school_admin+ */}
          {canEditCarpoolStatus && (
            <InfoCard title="Update Status" icon={<Shield size={16} />}>
              <div className="status-form">
                <div className="form-row">
                  <label>Current Status</label>
                  <span className="status-badge" style={{ backgroundColor: statusMeta.bgColor, color: statusMeta.color }}>
                    {statusMeta.label}
                  </span>
                </div>
                <div className="form-row">
                  <label>New Status</label>
                  <select
                    value={newStatus}
                    onChange={(e) => setNewStatus(e.target.value as CarpoolTripStatus)}
                  >
                    <option value="">Select status...</option>
                    {ALL_STATUSES.filter((s) => s !== trip.status).map((s) => (
                      <option key={s} value={s}>{CARPOOL_STATUS_META[s].label}</option>
                    ))}
                  </select>
                </div>
                <div className="form-row">
                  <label>Reason (required)</label>
                  <textarea
                    rows={3}
                    placeholder="Explain why you are changing the status..."
                    value={reason}
                    onChange={(e) => setReason(e.target.value)}
                  />
                </div>
                {statusError && <div className="status-error">{statusError}</div>}
                <button
                  className="update-btn"
                  disabled={!newStatus || !reason.trim() || isUpdating}
                  onClick={handleStatusUpdate}
                >
                  {isUpdating ? 'Updating...' : 'Update Status'}
                </button>
              </div>
            </InfoCard>
          )}
        </div>
      </div>

      <style>{`
        .cp-detail {
          padding: 24px;
          display: flex;
          flex-direction: column;
          gap: 24px;
        }

        .cp-detail-loading, .cp-detail-error {
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          min-height: 300px;
          gap: 12px;
          color: var(--color-text-tertiary);
        }

        .cp-detail-error button {
          padding: 8px 16px;
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border);
          border-radius: var(--radius-md);
          cursor: pointer;
        }

        .back-btn {
          display: inline-flex;
          align-items: center;
          gap: 6px;
          background: none;
          border: none;
          color: var(--color-text-secondary);
          font-size: 13px;
          cursor: pointer;
          padding: 4px 0;
          margin-bottom: 8px;
        }

        .back-btn:hover {
          color: var(--color-info);
        }

        .header-row {
          display: flex;
          justify-content: space-between;
          align-items: flex-start;
        }

        .page-title {
          font-size: 22px;
          font-weight: 700;
          color: var(--color-text-primary);
        }

        .header-meta {
          display: flex;
          align-items: center;
          gap: 8px;
          margin-top: 8px;
          flex-wrap: wrap;
        }

        .meta-sep {
          color: var(--color-text-tertiary);
        }

        .meta-text {
          font-size: 13px;
          color: var(--color-text-secondary);
        }

        .status-badge {
          display: inline-flex;
          padding: 2px 10px;
          border-radius: 10px;
          font-size: 11px;
          font-weight: 600;
          text-transform: uppercase;
        }

        .cp-detail-grid {
          display: grid;
          grid-template-columns: 1fr 380px;
          gap: 24px;
          align-items: start;
        }

        @media (max-width: 1024px) {
          .cp-detail-grid {
            grid-template-columns: 1fr;
          }
        }

        .cp-detail-left, .cp-detail-right {
          display: flex;
          flex-direction: column;
          gap: 16px;
        }

        /* Info Card */
        .info-card {
          background: var(--color-bg-primary);
          border: 1px solid var(--color-border-light);
          border-radius: var(--radius-lg);
          overflow: hidden;
        }

        .info-card-header {
          display: flex;
          align-items: center;
          gap: 8px;
          padding: 14px 20px;
          border-bottom: 1px solid var(--color-border-light);
          background: var(--color-bg-secondary);
        }

        .info-card-header h3 {
          font-size: 13px;
          font-weight: 600;
          color: var(--color-text-secondary);
          text-transform: uppercase;
          letter-spacing: 0.03em;
        }

        .info-card-header svg {
          color: var(--color-text-tertiary);
        }

        .info-card-body {
          padding: 16px 20px;
          display: flex;
          flex-direction: column;
          gap: 10px;
        }

        /* Info Row */
        .info-row {
          display: flex;
          justify-content: space-between;
          align-items: flex-start;
          gap: 16px;
        }

        .info-row-label {
          font-size: 13px;
          color: var(--color-text-tertiary);
          white-space: nowrap;
          min-width: 120px;
          flex-shrink: 0;
        }

        .info-row-value {
          font-size: 13px;
          color: var(--color-text-primary);
          font-weight: 500;
          text-align: right;
          word-break: break-word;
        }

        .info-row-value--highlight {
          color: var(--color-info);
          font-weight: 600;
        }

        /* Organizer */
        .organizer-info {
          display: flex;
          align-items: center;
          gap: 14px;
        }

        .organizer-avatar, .organizer-avatar-placeholder {
          width: 48px;
          height: 48px;
          border-radius: 50%;
          object-fit: cover;
          background: var(--color-bg-tertiary);
          display: flex;
          align-items: center;
          justify-content: center;
          color: var(--color-text-tertiary);
          flex-shrink: 0;
        }

        .organizer-name {
          font-weight: 600;
          font-size: 14px;
        }

        .organizer-email {
          font-size: 12px;
          color: var(--color-text-secondary);
        }

        .organizer-role {
          display: flex;
          align-items: center;
          gap: 4px;
          font-size: 12px;
          color: var(--color-text-tertiary);
          margin-top: 2px;
        }

        /* Members */
        .members-list {
          display: flex;
          flex-direction: column;
          gap: 8px;
        }

        .member-row {
          display: flex;
          align-items: center;
          gap: 10px;
          padding: 8px 0;
          border-bottom: 1px solid var(--color-border-light);
        }

        .member-row:last-child {
          border-bottom: none;
        }

        .member-avatar, .member-avatar-placeholder {
          width: 32px;
          height: 32px;
          border-radius: 50%;
          object-fit: cover;
          background: var(--color-bg-tertiary);
          display: flex;
          align-items: center;
          justify-content: center;
          color: var(--color-text-tertiary);
          flex-shrink: 0;
        }

        .member-info {
          flex: 1;
          min-width: 0;
        }

        .member-name {
          font-size: 13px;
          font-weight: 500;
        }

        .member-email {
          font-size: 11px;
          color: var(--color-text-tertiary);
        }

        .member-meta {
          display: flex;
          align-items: center;
          gap: 6px;
          flex-shrink: 0;
        }

        .member-badge {
          font-size: 10px;
          font-weight: 600;
          padding: 1px 6px;
          border-radius: 8px;
        }

        .member-role-tag {
          font-size: 10px;
          color: var(--color-text-tertiary);
          background: var(--color-bg-tertiary);
          padding: 1px 6px;
          border-radius: 8px;
        }

        .empty-text {
          font-size: 13px;
          color: var(--color-text-tertiary);
          text-align: center;
          padding: 12px 0;
        }

        /* Status Form */
        .status-form {
          display: flex;
          flex-direction: column;
          gap: 14px;
        }

        .form-row {
          display: flex;
          flex-direction: column;
          gap: 4px;
        }

        .form-row label {
          font-size: 12px;
          font-weight: 600;
          color: var(--color-text-secondary);
        }

        .form-row select,
        .form-row textarea {
          padding: 8px 10px;
          border: 1px solid var(--color-border);
          border-radius: var(--radius-sm);
          background: var(--color-bg-primary);
          color: var(--color-text-primary);
          font-size: 13px;
          font-family: inherit;
          outline: none;
          resize: vertical;
        }

        .form-row select:focus,
        .form-row textarea:focus {
          border-color: var(--color-info);
        }

        .status-error {
          font-size: 12px;
          color: var(--color-danger);
          background: var(--color-danger-light);
          padding: 8px 12px;
          border-radius: var(--radius-sm);
        }

        .update-btn {
          padding: 10px 16px;
          background: var(--color-info);
          color: white;
          border: none;
          border-radius: var(--radius-md);
          font-size: 13px;
          font-weight: 600;
          cursor: pointer;
          transition: opacity 0.2s;
        }

        .update-btn:disabled {
          opacity: 0.5;
          cursor: not-allowed;
        }

        .update-btn:hover:not(:disabled) {
          opacity: 0.85;
        }
      `}</style>
    </div>
  );
}

// ── Sub-components ───────────────────────────────────────────

function InfoCard({ title, icon, children }: {
  title: string;
  icon: React.ReactNode;
  children: React.ReactNode;
}) {
  return (
    <div className="info-card">
      <div className="info-card-header">
        {icon}
        <h3>{title}</h3>
      </div>
      <div className="info-card-body">{children}</div>
    </div>
  );
}

function InfoRow({ label, value, highlight }: {
  label: string;
  value: string;
  highlight?: boolean;
}) {
  return (
    <div className="info-row">
      <span className="info-row-label">{label}</span>
      <span className={`info-row-value ${highlight ? 'info-row-value--highlight' : ''}`}>{value}</span>
    </div>
  );
}

function MemberRow({ member, isCreator }: { member: CarpoolMember; isCreator: boolean }) {
  const statusMeta = CARPOOL_MEMBER_STATUS_META[member.status];
  return (
    <div className="member-row">
      {member.user?.avatar_url ? (
        <img src={member.user.avatar_url} alt="" className="member-avatar" />
      ) : (
        <div className="member-avatar-placeholder"><User size={14} /></div>
      )}
      <div className="member-info">
        <div className="member-name">{member.user?.display_name || 'Unknown'}</div>
        <div className="member-email">{member.user?.email || '—'}</div>
      </div>
      <div className="member-meta">
        {isCreator && <span className="member-role-tag">Creator</span>}
        <span
          className="member-badge"
          style={{ backgroundColor: statusMeta.bgColor, color: statusMeta.color }}
        >
          {statusMeta.label}
        </span>
        {member.cancelled_at && (
          <span className="member-role-tag" title={`Cancelled: ${new Date(member.cancelled_at).toLocaleString()}`}>
            ❌
          </span>
        )}
      </div>
    </div>
  );
}
