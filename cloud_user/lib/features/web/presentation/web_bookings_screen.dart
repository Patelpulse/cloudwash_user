import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_user/features/orders/data/order_provider.dart';
import 'package:cloud_user/features/orders/data/order_model.dart';
import 'package:cloud_user/features/web/presentation/web_layout.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class WebBookingsScreen extends ConsumerStatefulWidget {
  const WebBookingsScreen({super.key});

  @override
  ConsumerState<WebBookingsScreen> createState() => _WebBookingsScreenState();
}

class _WebBookingsScreenState extends ConsumerState<WebBookingsScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 1000;
    final ordersAsync = ref.watch(userOrdersRealtimeProvider);

    return WebLayout(
      child: Container(
        constraints: const BoxConstraints(minHeight: 600),
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 20 : 40,
          horizontal: isMobile ? 16 : 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A73E8).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: Color(0xFF1A73E8),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Bookings',
                      style: GoogleFonts.outfit(
                        fontSize: isMobile ? 24 : 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      'Manage and track all your service requests',
                      style: GoogleFonts.inter(
                        fontSize: isMobile ? 12 : 14,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Filters
            _buildFilterBar(),

            const SizedBox(height: 32),

            // Orders Grid
            ordersAsync.when(
              data: (orders) {
                // Filter orders
                final filteredOrders = _selectedFilter == 'all'
                    ? orders
                    : orders.where((o) => o.status == _selectedFilter).toList();

                if (filteredOrders.isEmpty) {
                  return _buildEmptyState(orders.isEmpty);
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 500,
                    mainAxisExtent: isMobile ? 380 : 360,
                    crossAxisSpacing: isMobile ? 12 : 24,
                    mainAxisSpacing: isMobile ? 12 : 24,
                  ),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) => _BookingCard(
                    order: filteredOrders[index],
                    onTap: () =>
                        _showOrderDetails(context, filteredOrders[index]),
                  ),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => _buildErrorState(error.toString()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = [
      {'label': 'All', 'value': 'all', 'icon': Icons.apps},
      {'label': 'Active', 'value': 'pending', 'icon': Icons.access_time_filled},
      {'label': 'Confirmed', 'value': 'confirmed', 'icon': Icons.thumb_up},
      {
        'label': 'In Progress',
        'value': 'in-progress',
        'icon': Icons.cleaning_services,
      },
      {'label': 'Completed', 'value': 'completed', 'icon': Icons.check_circle},
      {'label': 'Cancelled', 'value': 'cancelled', 'icon': Icons.cancel},
    ];

    return Container(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['value'];
          return InkWell(
            onTap: () =>
                setState(() => _selectedFilter = filter['value'] as String),
            borderRadius: BorderRadius.circular(30),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1A73E8) : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF1A73E8)
                      : const Color(0xFFE5E7EB),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF1A73E8).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Icon(
                    filter['icon'] as IconData,
                    size: 18,
                    color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    filter['label'] as String,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF374151),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool noOrdersAtAll) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              noOrdersAtAll
                  ? Icons.calendar_today_rounded
                  : Icons.filter_list_off,
              size: 64,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            noOrdersAtAll ? 'No Bookings Yet' : 'No $_selectedFilter orders',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            noOrdersAtAll
                ? 'Your service history will appear here once you make a booking'
                : 'Try changing the status filter to see other orders',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF6B7280),
            ),
          ),
          if (noOrdersAtAll) ...[
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.add_circle, size: 20),
              label: const Text('Book New Service'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A73E8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 20,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 400),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(error, style: GoogleFonts.inter(color: Colors.grey)),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => ref.invalidate(userOrdersRealtimeProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(BuildContext context, OrderModel order) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Order Details',
      pageBuilder: (context, _, __) => _BookingDetailsModal(order: order),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, anim, _, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }
}

class _BookingCard extends StatefulWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const _BookingCard({required this.order, required this.onTap});

  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isHovered
                  ? const Color(0xFF1A73E8).withValues(alpha: 0.3)
                  : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? const Color(0xFF1A73E8).withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: _isHovered ? 24 : 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '#${widget.order.orderNumber}',
                        style: GoogleFonts.sourceCodePro(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF374151),
                        ),
                      ),
                    ),
                    _StatusPill(status: widget.order.status),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Body
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat(
                              'MMM dd, yyyy • hh:mm a',
                            ).format(widget.order.createdAt),
                            style: GoogleFonts.inter(
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${widget.order.services.length} Service(s)',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.order.services.map((s) => s.name).join(', '),
                        style: GoogleFonts.inter(
                          color: const Color(0xFF6B7280),
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.order.address.fullAddress ?? 'No address',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF6B7280),
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Footer
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(22),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '₹${widget.order.priceSummary.total.toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A73E8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bg;
    IconData icon;
    String text;

    switch (status) {
      case 'pending':
        color = const Color(0xFFD97706);
        bg = const Color(0xFFFFFBEB);
        icon = Icons.hourglass_empty;
        text = 'Pending';
        break;
      case 'confirmed':
        color = const Color(0xFF2563EB);
        bg = const Color(0xFFEFF6FF);
        icon = Icons.check_circle_outline;
        text = 'Confirmed';
        break;
      case 'in-progress':
        color = const Color(0xFF7C3AED);
        bg = const Color(0xFFF5F3FF);
        icon = Icons.cleaning_services_outlined;
        text = 'In Progress';
        break;
      case 'completed':
        color = const Color(0xFF059669);
        bg = const Color(0xFFECFDF5);
        icon = Icons.task_alt;
        text = 'Completed';
        break;
      case 'cancelled':
        color = const Color(0xFFDC2626);
        bg = const Color(0xFFFEF2F2);
        icon = Icons.cancel_outlined;
        text = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        bg = Colors.grey.shade100;
        icon = Icons.info_outline;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.inter(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingDetailsModal extends ConsumerStatefulWidget {
  final OrderModel order;

  const _BookingDetailsModal({required this.order});

  @override
  ConsumerState<_BookingDetailsModal> createState() =>
      _BookingDetailsModalState();
}

class _BookingDetailsModalState extends ConsumerState<_BookingDetailsModal> {
  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 1000;
    return Align(
      alignment: isMobile ? Alignment.bottomCenter : Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: isMobile ? double.infinity : 500,
          height: isMobile
              ? MediaQuery.of(context).size.height * 0.9
              : double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: isMobile
                ? const BorderRadius.vertical(top: Radius.circular(24))
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 40,
                offset: isMobile ? const Offset(0, -10) : const Offset(-10, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFF3F4F6),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Details',
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '#${widget.order.orderNumber}',
                            style: GoogleFonts.sourceCodePro(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatusPill(status: widget.order.status),
                  ],
                ),
              ),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // OTP Section
                      if (widget.order.otp.isNotEmpty &&
                          widget.order.status != 'completed' &&
                          widget.order.status != 'cancelled') ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.lock_outline,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order OTP',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF1E40AF),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Share with professional',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF60A5FA),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.order.otp,
                                  style: GoogleFonts.sourceCodePro(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 4,
                                    color: const Color(0xFF1E40AF),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      _sectionTitle('Delivery Location'),
                      const SizedBox(height: 12),
                      _detailCard(
                        icon: Icons.location_on_rounded,
                        title: widget.order.address.name ?? 'Address',
                        subtitle: widget.order.address.fullAddress ?? 'N/A',
                        trailing: widget.order.address.phone,
                      ),

                      if (widget.order.scheduledDate != null) ...[
                        const SizedBox(height: 32),
                        _sectionTitle('Scheduled Date'),
                        const SizedBox(height: 12),
                        _detailCard(
                          icon: Icons.access_time_filled_rounded,
                          title: 'Service Date',
                          subtitle: DateFormat(
                            'EEEE, MMM dd, yyyy',
                          ).format(widget.order.scheduledDate!),
                        ),
                      ],

                      const SizedBox(height: 32),
                      _sectionTitle('Payment Details'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF3F4F6)),
                        ),
                        child: Column(
                          children: [
                            _infoRow('Method', widget.order.paymentMethod),
                            const Divider(height: 24),
                            _infoRow(
                              'Status',
                              widget.order.paymentStatus.toUpperCase(),
                              color: widget.order.paymentStatus == 'paid'
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ],
                        ),
                      ),

                      if (widget.order.notes != null &&
                          widget.order.notes!.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        _sectionTitle('Notes'),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFFEDD5)),
                          ),
                          child: Text(
                            widget.order.notes!,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF9A3412),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],

                      if (widget.order.status == 'cancelled' &&
                          widget.order.cancellationReason != null) ...[
                        const SizedBox(height: 32),
                        _sectionTitle('Cancellation Reason'),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFEE2E2)),
                          ),
                          child: Text(
                            widget.order.cancellationReason!,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF991B1B),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),
                      _sectionTitle('Services & Addons'),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF3F4F6)),
                        ),
                        child: Column(
                          children: [
                            ...widget.order.services.map(
                              (s) => _serviceItem(
                                s.name,
                                'x${s.quantity}',
                                s.total,
                              ),
                            ),
                            if (widget.order.addons.isNotEmpty)
                              ...widget.order.addons.map(
                                (a) => _serviceItem(
                                  '${a.name} (Addon)',
                                  '1',
                                  a.price,
                                  isAddon: true,
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                      _sectionTitle('Payment Summary'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _priceRow(
                              'Subtotal',
                              widget.order.priceSummary.subtotal,
                            ),
                            const SizedBox(height: 8),
                            _priceRow('Tax', widget.order.priceSummary.tax),
                            const SizedBox(height: 8),
                            _priceRow(
                              'Delivery',
                              widget.order.priceSummary.deliveryCharge,
                            ),
                            if (widget.order.priceSummary.discount > 0) ...[
                              const SizedBox(height: 8),
                              _priceRow(
                                'Discount',
                                -widget.order.priceSummary.discount,
                                isGreen: true,
                              ),
                            ],
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Paid',
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '₹${widget.order.priceSummary.total.toStringAsFixed(2)}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1A73E8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48), // Bottom spacing
                    ],
                  ),
                ),
              ),

              // Bottom Actions
              if (widget.order.status == 'pending' ||
                  widget.order.status == 'confirmed')
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _showCancelDialog(context, widget.order, ref),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      label: const Text('Cancel Booking'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(color: Color(0xFFFECACA)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: const Color(0xFF9CA3AF),
      ),
    );
  }

  Widget _detailCard({
    required IconData icon,
    required String title,
    required String subtitle,
    String? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF4B5563)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF6B7280),
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                trailing,
                style: GoogleFonts.sourceCodePro(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1D4ED8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _serviceItem(
    String name,
    String qty,
    double price, {
    bool isAddon = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (isAddon)
            const Icon(Icons.add_circle_outline, size: 16, color: Colors.blue)
          else
            const Icon(
              Icons.check_circle_outline,
              size: 16,
              color: Colors.green,
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                ),
                Text(
                  qty,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            '₹${price.toStringAsFixed(2)}',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, double amount, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(color: const Color(0xFF4B5563))),
        Text(
          '₹${amount.abs().toStringAsFixed(2)}',
          style: GoogleFonts.sourceCodePro(
            fontWeight: FontWeight.w600,
            color: isGreen ? Colors.green : const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF6B7280),
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: color ?? const Color(0xFF1F2937),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  void _showCancelDialog(
    BuildContext context,
    OrderModel order,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        String? selectedReason;
        final reasonController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Cancel Booking',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Please select a reason for cancellation:',
                    style: GoogleFonts.inter(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ...[
                    'Changed my mind',
                    'Found better price',
                    'Scheduling conflict',
                    'Other',
                  ].map(
                    (reason) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedReason == reason
                              ? const Color(0xFFEF4444)
                              : const Color(0xFFE5E7EB),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: selectedReason == reason
                            ? const Color(0xFFFEF2F2)
                            : Colors.white,
                      ),
                      child: RadioListTile<String>(
                        title: Text(
                          reason,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                        ),
                        value: reason,
                        groupValue: selectedReason,
                        onChanged: (val) =>
                            setState(() => selectedReason = val),
                        activeColor: const Color(0xFFEF4444),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  if (selectedReason == 'Other') ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: reasonController,
                      decoration: InputDecoration(
                        hintText: 'Tell us more...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
              ElevatedButton(
                onPressed: selectedReason == null
                    ? null
                    : () async {
                        final navigator = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);
                        final reason = selectedReason == 'Other'
                            ? reasonController.text
                            : selectedReason!;

                        // Close Cancel Dialog
                        navigator.pop();
                        // Close Details Sidebar
                        navigator.pop();

                        try {
                          await ref
                              .read(userOrdersProvider.notifier)
                              .cancelOrder(order.id, reason);
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Order cancelled successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Failed: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Confirm Cancellation'),
              ),
            ],
          ),
        );
      },
    );
  }
}
