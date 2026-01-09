import 'package:cloud_user/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_user/features/orders/data/order_provider.dart';
import 'package:cloud_user/features/orders/data/order_model.dart';
import 'package:intl/intl.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
                letterSpacing: 1,
              ),
            ),
            Text(
              'My Bookings',
              style: GoogleFonts.poppins(
                color: const Color(0xFF1E293B),
                fontWeight: FontWeight.w800,
                fontSize: 24,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.help_outline_rounded,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF1E293B),
              unselectedLabelColor: const Color(0xFF64748B),
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              labelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              unselectedLabelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              tabs: const [
                Tab(text: 'Ongoing'),
                Tab(text: 'History'),
                Tab(text: 'Cancelled'),
              ],
            ),
          ),
        ),
      ),
      body: ref
          .watch(userOrdersRealtimeProvider)
          .when(
            data: (orders) => TabBarView(
              controller: _tabController,
              children: [
                _buildOngoingTab(orders),
                _buildHistoryTab(orders),
                _buildCancelledTab(orders),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading bookings',
                    style: GoogleFonts.poppins(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(err.toString(), style: GoogleFonts.inter()),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => ref.invalidate(userOrdersRealtimeProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildOngoingTab(List<OrderModel> allOrders) {
    final ongoingOrders = allOrders
        .where(
          (o) =>
              o.status == 'pending' ||
              o.status == 'confirmed' ||
              o.status == 'in-progress',
        )
        .toList();
    return _buildBookingList(ongoingOrders);
  }

  Widget _buildHistoryTab(List<OrderModel> allOrders) {
    final completedOrders = allOrders
        .where((o) => o.status == 'completed')
        .toList();
    return _buildBookingList(completedOrders);
  }

  Widget _buildCancelledTab(List<OrderModel> allOrders) {
    final cancelledOrders = allOrders
        .where((o) => o.status == 'cancelled')
        .toList();
    return _buildBookingList(cancelledOrders);
  }

  Widget _buildBookingList(List<OrderModel> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                size: 64,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No bookings found',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: const Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your service history will appear here.',
              style: GoogleFonts.inter(
                color: const Color(0xFF64748B),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _BookingCard(order: order);
      },
    );
  }
}

class _BookingCard extends StatelessWidget {
  final OrderModel order;

  const _BookingCard({required this.order});

  IconData _getServiceIcon(String serviceName) {
    final lower = serviceName.toLowerCase();
    if (lower.contains('laundry') || lower.contains('wash')) {
      return Icons.local_laundry_service_outlined;
    } else if (lower.contains('clean')) {
      return Icons.cleaning_services_outlined;
    } else if (lower.contains('carpet')) {
      return Icons.texture_outlined;
    } else if (lower.contains('sofa')) {
      return Icons.weekend_outlined;
    } else if (lower.contains('ac') || lower.contains('air')) {
      return Icons.ac_unit_outlined;
    }
    return Icons.home_repair_service_outlined;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'confirmed':
        return const Color(0xFF3B82F6);
      case 'in-progress':
        return const Color(0xFF8B5CF6);
      case 'completed':
        return const Color(0xFF10B981);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Professional Assigned';
      case 'in-progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final serviceName = order.services.isNotEmpty
        ? order.services.first.name
        : 'Service';
    final icon = _getServiceIcon(serviceName);
    final statusColor = _getStatusColor(order.status);
    final statusText = _getStatusText(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: statusColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          order.orderNumber,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF94A3B8),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        _buildStatusPill(statusText, statusColor),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      serviceName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMM dd, hh:mm a').format(order.createdAt),
                  style: GoogleFonts.inter(
                    color: const Color(0xFF475569),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '₹${order.priceSummary.total.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.push('/booking-details/${order.id}');
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Details',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF1E293B),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Reorder',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: GoogleFonts.inter(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
