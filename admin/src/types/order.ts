/**
 * Order type — mirrors `orders` table for admin read-only views.
 */

export type OrderStatus = 'pending' | 'confirmed' | 'completed' | 'cancelled' | 'missed';
export type RentalStatus = 'active' | 'return_requested' | 'returned' | 'deposit_refunded' | null;

export interface Order {
  id: string;
  listing_id: string;
  buyer_id: string;
  seller_id: string;
  college_id: string;
  order_type: 'sale' | 'rental';
  status: OrderStatus;
  rental_status: RentalStatus;
  total_price: number;
  deposit_amount: number | null;
  created_at: string;
  updated_at: string;
}
