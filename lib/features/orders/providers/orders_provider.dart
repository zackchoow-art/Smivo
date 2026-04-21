import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'orders_provider.g.dart';

enum OrderTab { buying, selling }

enum OrderStatusType {
  rentedOut,
  completed,
  available,
  pendingDropOff,
  pendingPickUp,
  cancelled,
  processing,
}

class Order {
  final String id;
  final String title;
  final double amount;
  final String counterpartyName;
  final String counterpartyAvatarUrl;
  final String dateText;
  final OrderStatusType statusType;
  final String statusText;
  final String? imageUrl;
  final String? subtitle;
  final String? rentalPeriod;
  final String? backStatusText;
  final bool isRental;

  const Order({
    required this.id,
    required this.title,
    required this.amount,
    required this.counterpartyName,
    required this.counterpartyAvatarUrl,
    required this.dateText,
    required this.statusType,
    required this.statusText,
    this.imageUrl,
    this.subtitle,
    this.rentalPeriod,
    this.backStatusText,
    this.isRental = false,
  });
}

@riverpod
class OrdersTab extends _$OrdersTab {
  @override
  OrderTab build() => OrderTab.buying;

  void setTab(OrderTab tab) {
    state = tab;
  }
}

@riverpod
List<Order> orders(OrdersRef ref) {
  final tab = ref.watch(ordersTabProvider);

  if (tab == OrderTab.buying) {
    return _buyingOrders;
  } else {
    return _sellingOrders;
  }
}

final _buyingOrders = [
  const Order(
    id: 'b1',
    title: 'Advanced Calculus Set',
    amount: 45,
    counterpartyName: 'David Lee',
    counterpartyAvatarUrl: 'https://i.pravatar.cc/150?u=dl',
    dateText: 'Sep 1, 2023',
    statusType: OrderStatusType.rentedOut,
    statusText: 'Active Rental',
    imageUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=800&q=80',
    subtitle: 'Due: Dec 15th, 2023',
    rentalPeriod: 'Sep 1 - Dec 15 (Fall Sem)',
    backStatusText: 'Active Rental',
    isRental: true,
  ),
  const Order(
    id: 'b2',
    title: 'ErgoFit Desk Chair',
    amount: 120,
    counterpartyName: 'Alex Rivera',
    counterpartyAvatarUrl: 'https://i.pravatar.cc/150?u=ar',
    dateText: 'Oct 28, 2023',
    statusType: OrderStatusType.pendingPickUp,
    statusText: 'Ready for Exchange',
    imageUrl: 'https://images.unsplash.com/photo-1581557991964-125469da3b8a?auto=format&fit=crop&w=800&q=80',
    subtitle: 'Meet at: Student Union',
    backStatusText: 'Ready for Exchange',
  ),
  const Order(
    id: 'b3',
    title: 'Vintage Dorm Dresser',
    amount: 85,
    counterpartyName: 'Jordan Lee',
    counterpartyAvatarUrl: 'https://i.pravatar.cc/150?u=jl',
    dateText: 'Oct 24, 2023',
    statusType: OrderStatusType.completed,
    statusText: 'Transaction Finished',
    imageUrl: 'https://images.unsplash.com/photo-1595428774223-ef52624120d2?auto=format&fit=crop&w=800&q=80',
    subtitle: 'Purchased Oct 24',
    backStatusText: 'Transaction Finished',
  ),
  const Order(
    id: 'b4',
    title: 'Minimalist Watch',
    amount: 30,
    counterpartyName: 'System',
    counterpartyAvatarUrl: 'https://i.pravatar.cc/150?u=sys',
    dateText: 'Oct 15, 2023',
    statusType: OrderStatusType.cancelled,
    statusText: 'Refunded',
    imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=800&q=80',
    subtitle: 'Refund processed',
    backStatusText: 'Refunded',
  ),
  const Order(
    id: 'b5',
    title: 'Organic Chemistry 8th Ed',
    amount: 45,
    counterpartyName: 'Pending',
    counterpartyAvatarUrl: 'https://i.pravatar.cc/150?u=pen',
    dateText: 'Oct 10, 2023',
    statusType: OrderStatusType.processing,
    statusText: 'Waiting for seller confirmation',
    imageUrl: 'https://images.unsplash.com/photo-1532012197267-da84d127e765?auto=format&fit=crop&w=800&q=80',
    subtitle: 'Waiting for seller confirmation',
    backStatusText: 'Processing',
  ),
  const Order(
    id: 'b6',
    title: 'Sony Noise Cancelling',
    amount: 150,
    counterpartyName: 'Sarah Jenkins',
    counterpartyAvatarUrl: 'https://i.pravatar.cc/150?u=sj',
    dateText: 'Sep 12, 2023',
    statusType: OrderStatusType.completed,
    statusText: 'Transaction Finished',
    imageUrl: 'https://images.unsplash.com/photo-1546435770-a3e426fa99f5?auto=format&fit=crop&w=800&q=80',
    subtitle: 'Purchased Sep 12',
    backStatusText: 'Transaction Finished',
  ),
];

final _sellingOrders = [
  const Order(
    id: 's1',
    title: 'North Campus Loft Sublet',
    amount: 850,
    counterpartyName: 'Sarah Jenkins',
    counterpartyAvatarUrl: 'https://i.pravatar.cc/150?u=sj2',
    dateText: 'Aug 15, 2023',
    statusType: OrderStatusType.rentedOut,
    statusText: 'Active Contract',
    imageUrl: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=800&q=80',
    subtitle: 'Rented to: Sarah Jenkins',
    rentalPeriod: 'Sep 1 - May 31 (Academic Year)',
    backStatusText: 'Active Contract',
    isRental: true,
  ),
  const Order(
    id: 's2',
    title: 'Intro Biology Textbooks',
    amount: 65,
    counterpartyName: 'Tyler M.',
    counterpartyAvatarUrl: 'https://i.pravatar.cc/150?u=tm',
    dateText: 'Sep 05, 2023',
    statusType: OrderStatusType.completed,
    statusText: 'Payment Received',
    imageUrl: 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?auto=format&fit=crop&w=800&q=80',
    subtitle: 'Sold to: Tyler M.',
    backStatusText: 'Payment Received',
  ),
  const Order(
    id: 's3',
    title: 'MacBook Pro M1',
    amount: 700,
    counterpartyName: 'None yet',
    counterpartyAvatarUrl: '',
    dateText: 'Listed: Nov 1, 2023',
    statusType: OrderStatusType.available,
    statusText: 'Active Listing',
    imageUrl: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=800&q=80',
    subtitle: '2 Inquiries',
    backStatusText: 'Active Listing',
  ),
  const Order(
    id: 's4',
    title: 'Mini Fridge',
    amount: 35,
    counterpartyName: 'James K.',
    counterpartyAvatarUrl: 'https://i.pravatar.cc/150?u=jk',
    dateText: 'Nov 3, 2023',
    statusType: OrderStatusType.pendingDropOff,
    statusText: 'Deliver to Dorm 4B',
    imageUrl: 'https://images.unsplash.com/photo-1584568694244-14fbdf83bd30?auto=format&fit=crop&w=800&q=80',
    subtitle: 'Buyer: James K.',
    backStatusText: 'Awaiting Delivery',
  ),
  const Order(
    id: 's5',
    title: 'Dorm Chair',
    amount: 40,
    counterpartyName: 'Anna F.',
    counterpartyAvatarUrl: 'https://i.pravatar.cc/150?u=af',
    dateText: 'Oct 20, 2023',
    statusType: OrderStatusType.completed,
    statusText: 'Transaction Finished',
    imageUrl: 'https://images.unsplash.com/photo-1505843490538-5133c6c7d0e1?auto=format&fit=crop&w=800&q=80',
    subtitle: 'Sold to: Anna F.',
    backStatusText: 'Transaction Finished',
  ),
];
