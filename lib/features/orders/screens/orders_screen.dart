import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/theme/app_colors.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/features/orders/providers/orders_provider.dart';
import 'package:smivo/features/orders/widgets/order_card.dart';

import 'package:smivo/features/orders/widgets/list_order_card.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  bool _isListView = false;

  List<Widget> _buildSectionSlivers(String title, List<Order> items) {
    if (items.isEmpty) return [];
    
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 16, left: 24, right: 24),
          child: Text(
            title,
            style: AppTextStyles.headlineSmall.copyWith(
              color: const Color(0xFF2B2A51),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final order = items[index];
              if (_isListView) {
                return ListOrderCard(order: order);
              } else {
                return OrderCard(order: order);
              }
            },
            childCount: items.length,
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = ref.watch(ordersTabProvider);
    final orderList = ref.watch(ordersProvider);

    final pendingOrders = orderList.where((o) => 
      o.statusType == OrderStatusType.processing || 
      o.statusType == OrderStatusType.pendingPickUp || 
      o.statusType == OrderStatusType.pendingDropOff).toList();
    final activeRentals = orderList.where((o) => o.statusType == OrderStatusType.rentedOut || o.statusType == OrderStatusType.available).toList();
    final historyOrders = orderList.where((o) => 
      o.statusType == OrderStatusType.completed || 
      o.statusType == OrderStatusType.cancelled).toList();

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Orders',
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: const Color(0xFF2B2A51),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      // View Toggle
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.grid_view, color: !_isListView ? AppColors.primary : Colors.grey),
                            onPressed: () => setState(() => _isListView = false),
                          ),
                          IconButton(
                            icon: Icon(Icons.view_list, color: _isListView ? AppColors.primary : Colors.grey),
                            onPressed: () => setState(() => _isListView = true),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track your campus transactions, from dorm\nessentials to textbook rentals.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: const Color(0xFF2B2A51).withOpacity(0.7),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Segmented Control
                  _SegmentedControl(
                    currentTab: currentTab,
                    onTabChanged: (tab) => ref.read(ordersTabProvider.notifier).setTab(tab),
                  ),
                  const SizedBox(height: 8),
                ]),
              ),
            ),
            
            // Grouped Orders Lists
            ..._buildSectionSlivers('Action Needed', pendingOrders),
            ..._buildSectionSlivers('Active', activeRentals),
            ..._buildSectionSlivers('History', historyOrders),

            // Promotional Banner
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              sliver: SliverToBoxAdapter(
                child: _PromoBanner(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentedControl extends StatelessWidget {
  final OrderTab currentTab;
  final ValueChanged<OrderTab> onTabChanged;

  const _SegmentedControl({
    required this.currentTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFE2DFFF),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTab(OrderTab.buying, 'Buying & Renting')),
          Expanded(child: _buildTab(OrderTab.selling, 'Selling & Renting\nOut')),
        ],
      ),
    );
  }

  Widget _buildTab(OrderTab tab, String label) {
    final isSelected = currentTab == tab;

    return GestureDetector(
      onTap: () => onTabChanged(tab),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xFF013DFD),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF013DFD).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              )
            : null,
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? Colors.white : const Color(0xFF2B2A51).withOpacity(0.8),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF013DFD), Color(0xFF436BFF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background graphic could go here (e.g. flying books)
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.menu_book,
              size: 150,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'List your old\ntextbooks today.',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Clean out your dorm and make\nsome quick cash before finals\nweek.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF013DFD),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Start Selling',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
