/**
 * Hook for carpool trip management in admin dashboard.
 * Provides list, detail, status update, and analytics queries.
 */
import { useState, useEffect, useCallback } from 'react';
import { supabase } from '@/lib/supabase';
import { TABLES, DEFAULT_PAGE_SIZE } from '@/lib/constants';
import type {
  CarpoolTrip,
  CarpoolTripWithMembers,
  CarpoolMember,
  CarpoolTripStatus,
  LocationCount,
  TimeSlotCount,
  CarpoolAnalyticsSummary,
} from '@/types';

// ── List filters ─────────────────────────────────────────────

interface CarpoolListFilters {
  status?: CarpoolTripStatus | '';
  role?: 'driver' | 'organizer' | '';
  search?: string;
  schoolId?: string | null;
  dateFrom?: string;
  dateTo?: string;
}

interface CarpoolListResult {
  data: CarpoolTrip[];
  totalCount: number;
}

// ── List hook ────────────────────────────────────────────────

export function useCarpoolList(page: number, filters: CarpoolListFilters) {
  const [data, setData] = useState<CarpoolListResult | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function fetchTrips() {
      setIsLoading(true);
      setError(null);

      try {
        let query = supabase
          .from(TABLES.CARPOOL_TRIPS)
          .select(
            `*, creator:user_profiles!carpool_trips_creator_id_fkey(id, display_name, email, avatar_url), school:schools!carpool_trips_school_id_fkey(id, name)`,
            { count: 'exact' }
          )
          .order('departure_time', { ascending: false })
          .range(page * DEFAULT_PAGE_SIZE, (page + 1) * DEFAULT_PAGE_SIZE - 1);

        if (filters.status) {
          query = query.eq('status', filters.status);
        }
        if (filters.role) {
          query = query.eq('role', filters.role);
        }
        if (filters.schoolId) {
          query = query.eq('school_id', filters.schoolId);
        }
        if (filters.dateFrom) {
          query = query.gte('departure_time', filters.dateFrom);
        }
        if (filters.dateTo) {
          // Add 1 day to include the full end date
          query = query.lte('departure_time', filters.dateTo + 'T23:59:59');
        }
        if (filters.search) {
          query = query.or(
            `departure_address.ilike.%${filters.search}%,destination_address.ilike.%${filters.search}%,departure_description.ilike.%${filters.search}%,destination_description.ilike.%${filters.search}%`
          );
        }

        const { data: trips, error: fetchError, count } = await query;

        if (fetchError) throw fetchError;
        if (!cancelled) {
          setData({ data: (trips as CarpoolTrip[]) || [], totalCount: count || 0 });
        }
      } catch (err) {
        if (!cancelled) setError(err as Error);
      } finally {
        if (!cancelled) setIsLoading(false);
      }
    }

    fetchTrips();
    return () => { cancelled = true; };
  }, [page, filters.status, filters.role, filters.search, filters.schoolId, filters.dateFrom, filters.dateTo]);

  return { data, isLoading, error };
}

// ── Detail hook ──────────────────────────────────────────────

export function useCarpoolDetail(tripId: string | undefined) {
  const [trip, setTrip] = useState<CarpoolTripWithMembers | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  const refresh = useCallback(async () => {
    if (!tripId) return;
    setIsLoading(true);
    setError(null);

    try {
      // Fetch trip with creator and school
      const { data: tripData, error: tripError } = await supabase
        .from(TABLES.CARPOOL_TRIPS)
        .select(
          `*, creator:user_profiles!carpool_trips_creator_id_fkey(id, display_name, email, avatar_url), school:schools!carpool_trips_school_id_fkey(id, name)`
        )
        .eq('id', tripId)
        .single();

      if (tripError) throw tripError;

      // Fetch members with user profiles
      const { data: membersData, error: membersError } = await supabase
        .from(TABLES.CARPOOL_MEMBERS)
        .select(
          `*, user:user_profiles!carpool_members_user_id_fkey(id, display_name, email, avatar_url)`
        )
        .eq('trip_id', tripId)
        .order('created_at', { ascending: true });

      if (membersError) throw membersError;

      setTrip({
        ...tripData as CarpoolTrip,
        members: (membersData as CarpoolMember[]) || [],
      });
    } catch (err) {
      setError(err as Error);
    } finally {
      setIsLoading(false);
    }
  }, [tripId]);

  useEffect(() => {
    refresh();
  }, [refresh]);

  return { trip, isLoading, error, refresh };
}

// ── Status update ────────────────────────────────────────────

export function useUpdateCarpoolStatus() {
  const [isUpdating, setIsUpdating] = useState(false);

  const updateStatus = useCallback(async (
    tripId: string,
    newStatus: CarpoolTripStatus,
    reason: string,
  ) => {
    setIsUpdating(true);
    try {
      const { error } = await supabase.rpc('admin_update_carpool_status', {
        p_trip_id: tripId,
        p_new_status: newStatus,
        p_reason: reason,
      });

      if (error) throw error;
    } finally {
      setIsUpdating(false);
    }
  }, []);

  return { updateStatus, isUpdating };
}

// ── Analytics hook ───────────────────────────────────────────

interface CarpoolAnalyticsData {
  summary: CarpoolAnalyticsSummary;
  topDepartures: LocationCount[];
  topDestinations: LocationCount[];
  hourlyDistribution: TimeSlotCount[];
  weekdayDistribution: TimeSlotCount[];
  statusDistribution: { status: string; count: number }[];
}

const WEEKDAY_LABELS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

export function useCarpoolAnalytics(schoolId?: string | null) {
  const [data, setData] = useState<CarpoolAnalyticsData | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function fetchAnalytics() {
      setIsLoading(true);
      setError(null);

      try {
        // Fetch all trips (limited to 5000 for analytics)
        let query = supabase
          .from(TABLES.CARPOOL_TRIPS)
          .select('departure_description, destination_description, departure_time, status, role, total_seats, available_seats, estimated_total_price')
          .order('departure_time', { ascending: false })
          .limit(5000);

        if (schoolId) {
          query = query.eq('school_id', schoolId);
        }

        const { data: trips, error: fetchError } = await query;
        if (fetchError) throw fetchError;
        if (cancelled) return;

        const allTrips = trips || [];
        const total = allTrips.length;

        // Summary
        const active = allTrips.filter(t => t.status === 'active').length;
        const completed = allTrips.filter(t => t.status === 'completed').length;
        const cancelledCount = allTrips.filter(t => t.status === 'cancelled').length;
        const driverCount = allTrips.filter(t => t.role === 'driver').length;
        const organizerCount = allTrips.filter(t => t.role === 'organizer').length;

        const tripsWithSeats = allTrips.filter(t => t.total_seats > 0);
        const avgSeatUtilization = tripsWithSeats.length > 0
          ? tripsWithSeats.reduce((sum, t) => sum + ((t.total_seats - t.available_seats) / t.total_seats), 0) / tripsWithSeats.length
          : 0;

        const tripsWithPrice = allTrips.filter(t => t.estimated_total_price != null);
        const avgPrice = tripsWithPrice.length > 0
          ? tripsWithPrice.reduce((sum, t) => sum + (t.estimated_total_price ?? 0), 0) / tripsWithPrice.length
          : 0;

        const summary: CarpoolAnalyticsSummary = {
          totalTrips: total,
          activeTrips: active,
          completedTrips: completed,
          cancelledTrips: cancelledCount,
          avgSeatUtilization: Math.round(avgSeatUtilization * 100),
          avgPrice: Math.round(avgPrice * 100) / 100,
          driverCount,
          organizerCount,
        };

        // Top departures
        const depMap = new Map<string, number>();
        allTrips.forEach(t => {
          const key = t.departure_description || t.departure_time; // fallback
          if (typeof key === 'string' && key.trim()) {
            depMap.set(key, (depMap.get(key) || 0) + 1);
          }
        });
        const topDepartures: LocationCount[] = [...depMap.entries()]
          .sort((a, b) => b[1] - a[1])
          .slice(0, 10)
          .map(([location, count]) => ({ location, count }));

        // Top destinations
        const destMap = new Map<string, number>();
        allTrips.forEach(t => {
          const key = t.destination_description || '';
          if (key.trim()) {
            destMap.set(key, (destMap.get(key) || 0) + 1);
          }
        });
        const topDestinations: LocationCount[] = [...destMap.entries()]
          .sort((a, b) => b[1] - a[1])
          .slice(0, 10)
          .map(([location, count]) => ({ location, count }));

        // Hourly distribution
        const hourMap = new Map<number, number>();
        allTrips.forEach(t => {
          const hour = new Date(t.departure_time).getHours();
          hourMap.set(hour, (hourMap.get(hour) || 0) + 1);
        });
        const hourlyDistribution: TimeSlotCount[] = Array.from({ length: 24 }, (_, i) => ({
          slot: i,
          label: `${i.toString().padStart(2, '0')}:00`,
          count: hourMap.get(i) || 0,
        }));

        // Weekday distribution
        const weekMap = new Map<number, number>();
        allTrips.forEach(t => {
          const day = new Date(t.departure_time).getDay();
          weekMap.set(day, (weekMap.get(day) || 0) + 1);
        });
        const weekdayDistribution: TimeSlotCount[] = Array.from({ length: 7 }, (_, i) => ({
          slot: i,
          label: WEEKDAY_LABELS[i],
          count: weekMap.get(i) || 0,
        }));

        // Status distribution
        const statusMap = new Map<string, number>();
        allTrips.forEach(t => {
          statusMap.set(t.status, (statusMap.get(t.status) || 0) + 1);
        });
        const statusDistribution = [...statusMap.entries()]
          .map(([status, count]) => ({ status, count }));

        setData({
          summary,
          topDepartures,
          topDestinations,
          hourlyDistribution,
          weekdayDistribution,
          statusDistribution,
        });
      } catch (err) {
        if (!cancelled) setError(err as Error);
      } finally {
        if (!cancelled) setIsLoading(false);
      }
    }

    fetchAnalytics();
    return () => { cancelled = true; };
  }, [schoolId]);

  return { data, isLoading, error };
}
