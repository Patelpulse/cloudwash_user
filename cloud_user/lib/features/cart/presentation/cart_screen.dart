import 'package:cloud_user/core/models/addon_model.dart';
import 'package:cloud_user/features/cart/data/cart_model.dart';
import 'package:cloud_user/core/theme/app_theme.dart';
import 'package:cloud_user/features/cart/data/addons_provider.dart';
import 'package:cloud_user/features/cart/data/cart_provider.dart';
import 'package:cloud_user/features/location/data/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;
import 'package:cloud_user/features/orders/data/order_provider.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0; // 0: Cart, 1: Slot Selection
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  DateTime _focusedMonth = DateTime.now();
  String _selectedTimeSlot = '10 - 11 AM';

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final cartItems = cartState.items;
    final total = ref.watch(cartTotalProvider);
    final addonsAsync = ref.watch(addonsProvider);

    int totalDurationMinutes = 0;
    for (var item in cartItems) {
      totalDurationMinutes += (item.service.duration ?? 0) * item.quantity;
    }
    for (var addon in cartState.selectedAddons) {
      final parsed =
          int.tryParse(addon.duration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      totalDurationMinutes += parsed;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;

          if (isMobile) {
            return _buildMobileResponsiveLayout(
              cartState,
              cartItems,
              total,
              addonsAsync,
              totalDurationMinutes,
            );
          }

          return Row(
            children: [
              // --- LEFT SIDE CONTENT (70%) ---
              Expanded(
                flex: 7,
                child: _currentStep == 0
                    ? SingleChildScrollView(
                        child: _buildCartItemsView(
                          cartState,
                          cartItems,
                          total,
                          addonsAsync,
                        ),
                      )
                    : _buildSplitSlotSelectionView(),
              ),

              // --- RIGHT SIDE SIDEBAR (30%) ---
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image
                    Image.network(
                      'https://images.weserv.nl/?url=https://i.pinimg.com/736x/ab/66/8c/ab668c335e6b33a03695b169df175f73.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: const Color(0xFF1A1A1A)),
                    ),
                    // Gradient Overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.black.withOpacity(0.2),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.4, 0.7],
                        ),
                      ),
                    ),
                    // Content
                    Column(
                      children: [
                        _buildStepperIndicator(),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              key: ValueKey(_currentStep),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 60,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.0),
                                    Colors.black.withOpacity(0.4),
                                    Colors.black.withOpacity(0.6),
                                  ],
                                ),
                              ),
                              child: _currentStep == 0
                                  ? SingleChildScrollView(
                                      child: _buildSummaryContent(
                                        total,
                                        cartItems.length +
                                            cartState.selectedAddons.length,
                                        totalDurationMinutes,
                                      ),
                                    )
                                  : _buildBookingDetailsContent(
                                      total,
                                      totalDurationMinutes,
                                    ),
                            ),
                          ),
                        ),
                        _buildStickyCheckoutButton(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSplitSlotSelectionView() {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _currentStep = 0),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 10),
              const Text(
                'Schedule Your Service',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D1D1F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- CALENDAR HALF (50%) ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${months[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              _roundIconButton(
                                icon: Icons.chevron_left,
                                onTap: () => setState(
                                  () => _focusedMonth = DateTime(
                                    _focusedMonth.year,
                                    _focusedMonth.month - 1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _roundIconButton(
                                icon: Icons.chevron_right,
                                onTap: () => setState(
                                  () => _focusedMonth = DateTime(
                                    _focusedMonth.year,
                                    _focusedMonth.month + 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildCalendarGrid(isCompact: true),
                    ],
                  ),
                ),

                Container(
                  width: 1,
                  height: 400,
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  color: Colors.black12,
                ),

                // --- TIME SLOT HALF (50%) ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Peak Performance Slots',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Choose a time that fits your day',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 30),
                      Consumer(
                        builder: (context, ref, _) {
                          final bookedSlotsAsync = ref.watch(
                            bookedSlotsProvider(_selectedDate),
                          );
                          return bookedSlotsAsync.when(
                            data: (bookedSlots) {
                              final allSlots = [
                                '08 - 09 AM',
                                '09 - 10 AM',
                                '10 - 11 AM',
                                '11 - 12 AM',
                                '12 - 01 PM',
                                '01 - 02 PM',
                                '02 - 03 PM',
                                '03 - 04 PM',
                                '04 - 05 PM',
                                '05 - 06 PM',
                                '06 - 07 PM',
                                '07 - 08 PM',
                                '08 - 09 PM',
                              ];

                              final now = DateTime.now();
                              final isToday =
                                  _selectedDate.year == now.year &&
                                  _selectedDate.month == now.month &&
                                  _selectedDate.day == now.day;

                              final visibleSlots = allSlots.where((time) {
                                if (!isToday) return true;
                                final hourPart = time.split(' ')[0];
                                int hour = int.parse(hourPart);
                                if (time.contains('PM') && hour != 12) {
                                  hour += 12;
                                }
                                if (time.contains('AM') && hour == 12) hour = 0;
                                return hour > now.hour;
                              }).toList();

                              if (visibleSlots.isEmpty) {
                                return const Text(
                                  'No more slots available for today.',
                                  style: TextStyle(color: Colors.grey),
                                );
                              }

                              return Wrap(
                                spacing: 15,
                                runSpacing: 15,
                                children: visibleSlots.map((time) {
                                  // Check if booked
                                  final isBooked = bookedSlots.any((slot) {
                                    final slotTime = DateTime.parse(
                                      slot['time'],
                                    ).toLocal();

                                    final rangeStartHourPart = time.split(
                                      ' ',
                                    )[0];
                                    int rangeStartHour = int.parse(
                                      rangeStartHourPart,
                                    );
                                    if (time.contains('PM') &&
                                        rangeStartHour != 12) {
                                      rangeStartHour += 12;
                                    }
                                    if (time.contains('AM') &&
                                        rangeStartHour == 12) {
                                      rangeStartHour = 0;
                                    }

                                    return slotTime.year ==
                                            _selectedDate.year &&
                                        slotTime.month == _selectedDate.month &&
                                        slotTime.day == _selectedDate.day &&
                                        slotTime.hour == rangeStartHour;
                                  });

                                  return _buildModernTimeChip(
                                    time,
                                    isBooked: isBooked,
                                  );
                                }).toList(),
                              );
                            },
                            loading: () => const CircularProgressIndicator(),
                            error: (err, _) => Text('Error: $err'),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildSelectionTip(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionTip() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4A68FF).withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFF4A68FF)),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              'Same-day bookings are subject to availability. Pro-tip: Morning slots usually have faster turnaround times.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileResponsiveLayout(
    CartState state,
    List<CartItem> items,
    double total,
    AsyncValue<List<AddonModel>> addons,
    int duration,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10,
            bottom: 15,
            left: 20,
            right: 20,
          ),
          color: Colors.white,
          child: Row(
            children: [
              IconButton(
                onPressed: () => _currentStep == 1
                    ? setState(() => _currentStep = 0)
                    : context.pop(),
                icon: const Icon(Icons.arrow_back_ios, size: 20),
              ),
              const Expanded(
                child: Text(
                  'Checkout',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _currentStep == 0
                ? _buildMobileCartView(state, items, total, addons, duration)
                : _buildMobileSlotView(total, duration),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        '₹${(total * 1.18).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _onPanelAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCC00),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentStep == 0 ? 'NEXT' : 'PAY NOW',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileCartView(
    CartState state,
    List<CartItem> items,
    double total,
    AsyncValue<List<AddonModel>> addons,
    int duration,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Suggested Add-ons',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildSuggestedAddons(state, addons),
        const SizedBox(height: 24),
        const Text(
          'Items in Cart',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (i) => _buildMobileItemRow(
            i.service.image ?? '',
            i.service.title,
            i.totalPrice,
            qty: i.quantity,
            duration: i.service.duration,
            onRemove: () =>
                ref.read(cartProvider.notifier).removeFromCart(i.service.id),
            onUpdateQty: (q) =>
                ref.read(cartProvider.notifier).updateQuantity(i.service.id, q),
          ),
        ),
        ...state.selectedAddons.map(
          (a) => _buildMobileItemRow(
            a.imageUrl,
            a.name,
            a.price,
            duration: int.tryParse(
              a.duration.replaceAll(RegExp(r'[^0-9]'), ''),
            ),
            onRemove: () => ref.read(cartProvider.notifier).toggleAddon(a),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileItemRow(
    String img,
    String title,
    double price, {
    int? qty,
    int? duration,
    VoidCallback? onRemove,
    Function(int)? onUpdateQty,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: img,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (duration != null)
                  Text(
                    '$duration mins',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                Text(
                  '₹$price',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          if (qty != null) ...[
            IconButton(
              onPressed: () => onUpdateQty!(qty - 1),
              icon: const Icon(Icons.remove_circle_outline, size: 20),
            ),
            Text('$qty'),
            IconButton(
              onPressed: () => onUpdateQty!(qty + 1),
              icon: const Icon(Icons.add_circle_outline, size: 20),
            ),
          ] else
            IconButton(
              onPressed: onRemove,
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMobileSlotView(double total, int duration) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMobileSelectionHeader(),
        const SizedBox(height: 20),
        _buildCalendarGrid(isCompact: true),
        const SizedBox(height: 30),
        const Text(
          'Available Slots',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Consumer(
          builder: (context, ref, _) {
            final bookedSlotsAsync = ref.watch(
              bookedSlotsProvider(_selectedDate),
            );
            return bookedSlotsAsync.when(
              data: (bookedSlots) {
                final allSlots = [
                  '08 - 09 AM',
                  '09 - 10 AM',
                  '10 - 11 AM',
                  '11 - 12 AM',
                  '12 - 01 PM',
                  '01 - 02 PM',
                  '02 - 03 PM',
                  '03 - 04 PM',
                  '04 - 05 PM',
                  '05 - 06 PM',
                  '06 - 07 PM',
                  '07 - 08 PM',
                  '08 - 09 PM',
                ];

                final now = DateTime.now();
                final isToday =
                    _selectedDate.year == now.year &&
                    _selectedDate.month == now.month &&
                    _selectedDate.day == now.day;

                final visibleSlots = allSlots.where((time) {
                  if (!isToday) return true;
                  final hourPart = time.split(' ')[0];
                  int hour = int.parse(hourPart);
                  if (time.contains('PM') && hour != 12) {
                    hour += 12;
                  }
                  if (time.contains('AM') && hour == 12) hour = 0;
                  return hour > now.hour;
                }).toList();

                if (visibleSlots.isEmpty) {
                  return const Text(
                    'No more slots available for today.',
                    style: TextStyle(color: Colors.grey),
                  );
                }

                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: visibleSlots.map((time) {
                    final rangeStartHourPart = time.split(' ')[0];
                    int rangeStartHour = int.parse(rangeStartHourPart);
                    if (time.contains('PM') && rangeStartHour != 12) {
                      rangeStartHour += 12;
                    }
                    if (time.contains('AM') && rangeStartHour == 12) {
                      rangeStartHour = 0;
                    }

                    final isBooked = bookedSlots.any((slot) {
                      final slotTime = DateTime.parse(slot['time']).toLocal();
                      return slotTime.year == _selectedDate.year &&
                          slotTime.month == _selectedDate.month &&
                          slotTime.day == _selectedDate.day &&
                          slotTime.hour == rangeStartHour;
                    });

                    return _buildModernTimeChip(time, isBooked: isBooked);
                  }).toList(),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (err, _) => Text('Error: $err'),
            );
          },
        ),
        const SizedBox(height: 30),
        _buildBookingDetailsContent(total, duration, isDark: false),
      ],
    );
  }

  Widget _buildMobileSelectionHeader() {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${months[_focusedMonth.month - 1]} ${_focusedMonth.year}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            _roundIconButton(
              icon: Icons.chevron_left,
              onTap: () => setState(
                () => _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month - 1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _roundIconButton(
              icon: Icons.chevron_right,
              onTap: () => setState(
                () => _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month + 1,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCartItemsView(
    CartState cartState,
    List<CartItem> cartItems,
    double total,
    AsyncValue<List<AddonModel>> addonsAsync,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildLogo(),
              const SizedBox(width: 20),
              const Text(
                'Your Shopping Cart',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF1D1D1F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            'Suggested Add-ons',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          _buildSuggestedAddons(cartState, addonsAsync),
          const SizedBox(height: 40),
          const Text(
            'Items in Cart',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          if (cartItems.isEmpty && cartState.selectedAddons.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text('Your cart is empty'),
              ),
            )
          else ...[
            ...cartItems.map(
              (item) => _CartItemRow(
                imageUrl: item.service.image ?? '',
                title: item.service.title,
                subtitle: 'Service #${item.service.id.substring(0, 6)}',
                variant: 'Standard',
                quantity: item.quantity,
                price: item.totalPrice,
                duration: item.service.duration,
                onUpdateQuantity: (q) => ref
                    .read(cartProvider.notifier)
                    .updateQuantity(item.service.id, q),
                onRemove: () => ref
                    .read(cartProvider.notifier)
                    .removeFromCart(item.service.id),
              ),
            ),
            ...cartState.selectedAddons.map(
              (addon) => _CartItemRow(
                imageUrl: addon.imageUrl,
                title: addon.name,
                subtitle: 'Add-on',
                variant: 'Essential',
                quantity: 1,
                price: addon.price,
                duration: int.tryParse(
                  addon.duration.replaceAll(RegExp(r'[^0-9]'), ''),
                ),
                showQuantity: false,
                onRemove: () =>
                    ref.read(cartProvider.notifier).toggleAddon(addon),
                onUpdateQuantity: (_) {},
              ),
            ),
          ],
          _buildCartFooter(total),
        ],
      ),
    );
  }

  Widget _roundIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
    );
  }

  Widget _buildCalendarGrid({bool isCompact = false}) {
    final daysInMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    ).day;
    final firstDayOfWeek = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    ).weekday;
    final weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekdays
              .map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 15),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: isCompact ? 1.0 : 1.4,
          ),
          itemCount: daysInMonth + (firstDayOfWeek - 1),
          itemBuilder: (context, index) {
            if (index < firstDayOfWeek - 1) return const SizedBox.shrink();
            final day = index - (firstDayOfWeek - 2);
            final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
            final isSelected =
                _selectedDate.day == date.day &&
                _selectedDate.month == date.month &&
                _selectedDate.year == date.year;
            final isToday =
                DateTime.now().day == day &&
                DateTime.now().month == _focusedMonth.month &&
                DateTime.now().year == _focusedMonth.year;
            final isPast = date.isBefore(DateTime.now()) && !isToday;
            return InkWell(
              onTap: isPast ? null : () => setState(() => _selectedDate = date),
              borderRadius: BorderRadius.circular(12),
              child: _AnimatedGradientBox(
                isSelected: isSelected,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day.toString(),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isPast
                                    ? Colors.grey.shade300
                                    : (isToday
                                          ? const Color(0xFF4A68FF)
                                          : const Color(0xFF1D1D1F))),
                          fontSize: 16,
                          fontWeight: isSelected || isToday
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                      if (isToday && !isSelected)
                        Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: const BoxDecoration(
                            color: Color(0xFF4A68FF),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildModernTimeChip(String slot, {bool isBooked = false}) {
    final isSelected = _selectedTimeSlot == slot;
    return InkWell(
      onTap: isBooked ? null : () => setState(() => _selectedTimeSlot = slot),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isBooked
              ? Colors.grey.withOpacity(0.1)
              : isSelected
              ? const Color(0xFFFFCC00)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFCC00) : Colors.grey.shade200,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFCC00).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          slot,
          style: TextStyle(
            color: isBooked
                ? Colors.grey
                : isSelected
                ? Colors.black
                : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            decoration: isBooked ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
    );
  }

  Widget _buildBookingDetailsContent(
    double total,
    int totalDuration, {
    bool isDark = true,
  }) {
    final cartState = ref.watch(cartProvider);
    final location = ref.watch(userLocationProvider);
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryColor = isDark
        ? Colors.white.withOpacity(0.5)
        : Colors.grey.shade600;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Booking Details',
          style: TextStyle(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),
        _sidebarSectionHeader(
          'Items',
          isDark: isDark,
          onEdit: () => setState(() => _currentStep = 0),
        ),
        ...cartState.items.map(
          (item) => _sidebarItemRow(
            item.service.title,
            '₹${item.totalPrice}',
            qty: '${item.quantity}x',
            duration: item.service.duration != null
                ? '${item.service.duration} mins'
                : null,
            isDark: isDark,
          ),
        ),
        ...cartState.selectedAddons.map((addon) {
          final durationMins = int.tryParse(
            addon.duration.replaceAll(RegExp(r'[^0-9]'), ''),
          );
          return _sidebarItemRow(
            addon.name,
            '₹${addon.price}',
            qty: '1x',
            duration: durationMins != null ? '${durationMins} mins' : null,
            isDark: isDark,
          );
        }),
        const SizedBox(height: 24),
        _sidebarSectionHeader('Duration', isDark: isDark),
        Row(
          children: [
            const Icon(
              Icons.timer_outlined,
              color: Color(0xFFFFCC00),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              '$totalDuration mins',
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _sidebarSectionHeader('Location', isDark: isDark),
        Text(
          'CloudWasher Hub',
          style: TextStyle(
            color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        Text(
          location?.address ?? 'Main Branch, Madhapur, Hyd',
          style: TextStyle(color: secondaryColor, fontSize: 13),
        ),
        const SizedBox(height: 24),
        _sidebarSectionHeader('Date & Time', isDark: isDark),
        Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: Color(0xFFFFCC00),
              size: 16,
            ),
            const SizedBox(width: 10),
            Text(
              '$_selectedTimeSlot, ${_selectedDate.day} ${_buildMonthName(_selectedDate.month)} ${_selectedDate.year}',
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        if (isDark) const SizedBox(height: 20),
        if (isDark) const Divider(color: Colors.white24),
        if (isDark)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              Text(
                '₹${(total * 1.18).toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFFFFCC00),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _sidebarSectionHeader(
    String title, {
    bool isDark = true,
    VoidCallback? onEdit,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white.withOpacity(0.5) : Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          if (onEdit != null)
            InkWell(
              onTap: onEdit,
              child: const Text(
                'Edit',
                style: TextStyle(
                  color: Color(0xFF4A68FF),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sidebarItemRow(
    String name,
    String price, {
    String? qty,
    String? duration,
    bool isDark = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (qty != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    qty,
                    style: const TextStyle(
                      color: Color(0xFF00C853),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Text(
                price,
                style: TextStyle(
                  color: isDark ? const Color(0xFFFFCC00) : Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (duration != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 12,
                    color: isDark ? Colors.white54 : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    duration,
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _buildMonthName(int month) {
    return [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][month - 1];
  }

  Widget _buildSummaryContent(double total, int count, int totalDuration) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Summary',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 40),
        _summaryRow('Items', count.toString()),
        _summaryRow('Duration', '$totalDuration mins'),
        _summaryRow('Tax (18%)', '₹${(total * 0.18).toStringAsFixed(2)}'),
        const SizedBox(height: 20),
        const Divider(color: Colors.white24),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            Text(
              '₹${(total * 1.18).toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xFFFFCC00),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: const Center(
        child: Text(
          'Q',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
    );
  }

  Widget _buildStepperIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 40, left: 40),
      child: Row(
        children: [
          _indicatorDot(active: _currentStep == 0),
          const SizedBox(width: 10),
          _indicatorDot(active: _currentStep == 1),
        ],
      ),
    );
  }

  Widget _indicatorDot({required bool active}) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? const Color(0xFFFFCC00) : Colors.grey.shade600,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _onPanelAction() {
    if (_currentStep == 0) {
      if (ref.read(cartProvider).items.isEmpty &&
          ref.read(cartProvider).selectedAddons.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Your cart is empty')));
        return;
      }
      setState(() => _currentStep = 1);
    } else {
      context.push('/checkout');
    }
  }

  Widget _buildSuggestedAddons(
    CartState cartState,
    AsyncValue<List<AddonModel>> addonsAsync,
  ) {
    return addonsAsync.when(
      data: (addons) {
        final cartCategories = cartState.items
            .map((i) => i.service.category)
            .toSet();
        final cartSubCategories = cartState.items
            .map((i) => i.service.subCategory)
            .toSet();

        final available = addons.where((a) {
          // Match category OR subcategory (don't filter out selected ones)
          bool matchesCategory = cartCategories.contains(a.category);
          bool matchesSubCategory =
              a.subCategory != null &&
              cartSubCategories.contains(a.subCategory);

          return matchesCategory || matchesSubCategory;
        }).toList();

        if (available.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: available.length,
            itemBuilder: (context, index) {
              final addon = available[index];
              final isSelected = cartState.selectedAddons.any(
                (sa) => sa.id == addon.id,
              );

              return _AddonCardSmall(
                addon: addon,
                isSelected: isSelected,
                onAdd: () => ref.read(cartProvider.notifier).toggleAddon(addon),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const Text('Error loading addons'),
    );
  }

  Widget _buildCartFooter(double total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
          label: const Text('Back to Shop'),
        ),
        Text(
          'Subtotal: ₹${total.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildStickyCheckoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: ElevatedButton(
        onPressed: _onPanelAction,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFCC00),
          foregroundColor: Colors.black,
          shape: const RoundedRectangleBorder(),
          elevation: 0,
        ),
        child: Text(
          _currentStep == 0 ? 'NEXT' : 'PROCEED TO PAY',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _AnimatedGradientBox extends StatefulWidget {
  final bool isSelected;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const _AnimatedGradientBox({
    required this.isSelected,
    required this.child,
    this.padding,
  });
  @override
  State<_AnimatedGradientBox> createState() => _AnimatedGradientBoxState();
}

class _AnimatedGradientBoxState extends State<_AnimatedGradientBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: widget.isSelected ? null : Colors.white,
        border: Border.all(
          color: widget.isSelected ? Colors.transparent : Colors.grey.shade200,
        ),
        boxShadow: widget.isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFF4A68FF).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: widget.isSelected
          ? AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: SweepGradient(
                      center: Alignment.center,
                      startAngle: 0.0,
                      endAngle: math.pi * 2,
                      colors: const [
                        Color(0xFF4A68FF),
                        Color(0xFF8BA1FF),
                        Color(0xFF4A68FF),
                      ],
                      transform: _GradientRotation(
                        _controller.value * math.pi * 2,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: widget.padding ?? EdgeInsets.zero,
                    child: widget.child,
                  ),
                );
              },
            )
          : Padding(
              padding: widget.padding ?? EdgeInsets.zero,
              child: widget.child,
            ),
    );
  }
}

class _GradientRotation extends GradientTransform {
  final double radians;
  const _GradientRotation(this.radians);
  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final double centerWidth = bounds.width / 2;
    final double centerHeight = bounds.height / 2;
    return Matrix4.identity()
      ..translate(centerWidth, centerHeight)
      ..rotateZ(radians)
      ..translate(-centerWidth, -centerHeight);
  }
}

class _CartItemRow extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String variant;
  final int quantity;
  final double price;
  final int? duration;
  final bool showQuantity;
  final Function(int) onUpdateQuantity;
  final VoidCallback onRemove;
  const _CartItemRow({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.variant,
    required this.quantity,
    required this.price,
    this.duration,
    this.showQuantity = true,
    required this.onUpdateQuantity,
    required this.onRemove,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => const Icon(Icons.image),
            ),
          ),
          const SizedBox(width: 30),
          Flexible(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                if (duration != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$duration mins',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Flexible(
            flex: 2,
            child: Text(
              variant,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ),
          if (showQuantity)
            Flexible(
              flex: 1,
              child: Column(
                children: [
                  InkWell(
                    onTap: () => onUpdateQuantity(quantity + 1),
                    child: const Icon(Icons.keyboard_arrow_up, size: 18),
                  ),
                  Text(
                    quantity.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  InkWell(
                    onTap: () => onUpdateQuantity(quantity - 1),
                    child: const Icon(Icons.keyboard_arrow_down, size: 18),
                  ),
                ],
              ),
            )
          else
            const Expanded(flex: 1, child: SizedBox.shrink()),
          Expanded(
            flex: 2,
            child: Text(
              '${price.toStringAsFixed(2)} INR',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
          const SizedBox(width: 30),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 18, color: Colors.black26),
          ),
        ],
      ),
    );
  }
}

class _AddonCardSmall extends StatelessWidget {
  final dynamic addon;
  final VoidCallback onAdd;
  final bool isSelected;

  const _AddonCardSmall({
    required this.addon,
    required this.onAdd,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? AppTheme.primary : Colors.black12,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
              child: CachedNetworkImage(
                imageUrl: addon.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  addon.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₹${addon.price}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.primary),
                ),
                if (addon.duration != null)
                  Text(
                    '${addon.duration}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  height: 24,
                  child: ElevatedButton(
                    onPressed: onAdd,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      textStyle: const TextStyle(fontSize: 10),
                      backgroundColor: isSelected ? Colors.green : null,
                    ),
                    child: Text(isSelected ? 'ADDED ✓' : 'ADD'),
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
