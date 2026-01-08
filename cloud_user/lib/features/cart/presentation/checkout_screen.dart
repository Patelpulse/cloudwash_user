import 'package:cloud_user/core/theme/app_theme.dart';
import 'package:cloud_user/features/cart/data/addons_provider.dart';
import 'package:cloud_user/features/cart/data/cart_provider.dart';
import 'package:cloud_user/features/web/presentation/web_layout.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_user/features/location/data/address_provider.dart';
import 'package:cloud_user/features/orders/data/order_provider.dart';
import 'package:cloud_user/features/auth/presentation/providers/auth_state_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _currentStep = 0; // 0: Details, 1: Payment
  String _selectedPaymentMethod = 'Cash'; // Cash After Service only
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // ... existing init code ...
  }

  // ... _placeOrder mod ...
  Future<void> _placeOrder() async {
    // Validate address
    final selectedAddress = ref.read(selectedAddressProvider);
    if (selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery address')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cart = ref.read(cartProvider);
      final total = ref.read(cartTotalProvider);

      // ... existing services/addons prep ...
      final services = cart.items.map((item) {
        return {
          'serviceId': item.service.id,
          'name': item.service.title,
          'categoryName': item.service.category,
          'subCategoryName': item.service.subCategory ?? item.service.category,
          'price': item.service.price,
          'quantity': item.quantity,
          'total': item.service.price * item.quantity,
        };
      }).toList();

      final subtotal = total;
      final tax = subtotal * 0.18; // Match UI 18% GST
      final deliveryCharge = 50.0;
      final grandTotal = subtotal + tax + deliveryCharge;

      final addons = cart.selectedAddons.map((addon) {
        return {'addonId': addon.id, 'name': addon.name, 'price': addon.price};
      }).toList();

      final scheduledDateTime = DateTime.now();

      final orderData = {
        'address': {
          'label': selectedAddress.label,
          'name': selectedAddress.name,
          'phone': selectedAddress.phone,
          'houseNumber': selectedAddress.houseNumber,
          'street': selectedAddress.street,
          'landmark': selectedAddress.landmark,
          'city': selectedAddress.city,
          'pincode': selectedAddress.pincode,
          'fullAddress': selectedAddress.fullAddress,
        },
        'services': services,
        'addons': addons,
        'priceSummary': {
          'subtotal': subtotal,
          'tax': tax,
          'deliveryCharge': deliveryCharge,
          'discount': 0.0,
          'total': grandTotal,
        },
        'paymentMethod': _selectedPaymentMethod,
        'scheduledDate': scheduledDateTime.toIso8601String(),
        'notes': 'Please handle with care',
      };

      // ... existing createOrder call ...
      final result = await ref
          .read(userOrdersProvider.notifier)
          .createOrder(orderData);

      final otp = result['order']['otp'];
      final orderNumber = result['order']['orderNumber'];

      ref.read(cartProvider.notifier).clearCart();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order #$orderNumber placed! Your OTP is: $otp'),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/');
      }
    } catch (e) {
      print('❌ Order creation error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    final isDesktop = MediaQuery.of(context).size.width > 1000;

    Widget layout = isDesktop
        ? _buildDesktopLayout(cartState, total)
        : _buildMobileLayout(cartState, total);

    if (kIsWeb) {
      return WebLayout(
        floatingBottomBar: isDesktop ? null : _buildBottomAction(total),
        child: Container(
          color: const Color(0xFFF8F9FB),
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop
                ? MediaQuery.of(context).size.width * 0.08
                : 20,
            vertical: isDesktop ? 60 : 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepIndicator(isWeb: true),
              const SizedBox(height: 40),
              layout,
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => _currentStep == 0
              ? context.pop()
              : setState(() => _currentStep = 0),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: layout,
            ),
          ),
          if (!isDesktop) _buildBottomAction(total),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(cartState, double total) {
    return _currentStep == 0
        ? _buildDetailsSection(cartState, total) // This uses the new section
        : _buildPaymentSection(total);
  }

  Widget _buildDesktopLayout(cartState, double total) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 600,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepIndicator(isWeb: true),
              const SizedBox(height: 40),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _currentStep == 0
                    ? _buildDetailsSection(
                        cartState,
                        total,
                        isDesktop: true,
                        key: const ValueKey('details_step'),
                      )
                    : _buildPaymentSection(
                        total,
                        isDesktop: true,
                        key: const ValueKey('payment_step'),
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 60),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF262626),
              borderRadius: BorderRadius.circular(24),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://images.weserv.nl/?url=https://i.pinimg.com/736x/ab/66/8c/ab668c335e6b33a03695b169df175f73.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.9),
                    Colors.black.withOpacity(0.4),
                  ],
                ),
              ),
              child: Column(
                children: [
                  _buildPricingCard(
                    cartState,
                    total,
                    isDesktop: true,
                    isDark: true,
                  ),
                  const SizedBox(height: 24),
                  _buildDesktopAction(total),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator({bool isWeb = false}) {
    return Container(
      color: isWeb ? Colors.transparent : Colors.white,
      padding: EdgeInsets.symmetric(vertical: isWeb ? 0 : 20),
      child: Row(
        mainAxisAlignment: isWeb
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: [
          _stepItem(0, 'Details', _currentStep >= 0),
          _stepDivider(_currentStep >= 1),
          _stepItem(1, 'Payment', _currentStep >= 1),
        ],
      ),
    );
  }

  Widget _buildDesktopAction(double total) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : () {
                if (_currentStep == 0) {
                  setState(() => _currentStep = 1);
                } else {
                  _placeOrder();
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                _currentStep == 0 ? 'Review & Pay' : 'Pay & Confirm Booking',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _stepItem(int step, String label, bool isActive) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primary : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _stepDivider(bool isActive) {
    return Container(
      width: 50,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: isActive ? AppTheme.primary : Colors.grey.shade300,
    );
  }

  Widget _buildDetailsSection(
    cartState,
    double total, {
    bool isDesktop = false,
    Key? key,
  }) {
    final selectedAddress = ref.watch(selectedAddressProvider);
    final addonsAsync = ref.watch(addonsProvider);

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Service Address', isDesktop: isDesktop),
        const SizedBox(height: 12),
        Consumer(
          builder: (context, ref, _) {
            final isLoggedIn = ref.watch(authStateProvider).value ?? false;

            if (!isLoggedIn) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Log in to select address',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please login to continue with your booking',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.push('/login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Login Now'),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Container(
              padding: EdgeInsets.all(isDesktop ? 32 : 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: AppTheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedAddress?.label ?? 'No address selected',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isDesktop ? 18 : 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          selectedAddress?.fullAddress ??
                              'Please add a service address',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: isDesktop ? 14 : 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showAddressSelection(context),
                    child: const Text(
                      'Change',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 32),

        if (!isDesktop) ...[
          const SizedBox(height: 32),
          _sectionTitle('Order Summary', isDesktop: isDesktop),
          const SizedBox(height: 12),
          _buildPricingCard(cartState, total),
        ],
      ],
    );
  }

  Widget _buildPaymentSection(
    double total, {
    bool isDesktop = false,
    Key? key,
  }) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show selected address confirmation
        Consumer(
          builder: (context, ref, _) {
            final address = ref.watch(selectedAddressProvider);
            if (address == null) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivering to ${address.label}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          address.fullAddress,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _currentStep = 0),
                    child: const Text('Change'),
                  ),
                ],
              ),
            );
          },
        ),

        _sectionTitle('Select Payment Method', isDesktop: isDesktop),
        const SizedBox(height: 16),
        _paymentMethodItem(
          'Cash After Service',
          'Pay once work is done',
          Icons.money,
          'Cash',
          isDesktop: isDesktop,
        ),
        const SizedBox(height: 32),
        Container(
          padding: EdgeInsets.all(isDesktop ? 32 : 24),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.shield_outlined,
                color: Colors.blue,
                size: isDesktop ? 32 : 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Your payment is 100% secure. We use industry-standard encryption.',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: isDesktop ? 15 : 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _paymentMethodItem(
    String title,
    String subtitle,
    IconData icon,
    String value, {
    bool isDesktop = false,
  }) {
    final isSelected = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(isDesktop ? 28 : 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primary : Colors.grey,
              size: isDesktop ? 28 : 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isDesktop ? 18 : 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: isDesktop ? 13 : 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppTheme.primary,
                size: isDesktop ? 28 : 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, {bool isDesktop = false}) {
    return Text(
      title,
      style: TextStyle(
        fontSize: isDesktop ? 22 : 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPricingCard(
    cartState,
    double total, {
    bool isDesktop = false,
    bool isDark = false,
  }) {
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryColor = isDark ? Colors.white70 : Colors.grey;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : 24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: Colors.white12) : null,
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          ...cartState.items.map(
            (item) => _itemRow(
              item.service.title,
              '₹${item.totalPrice}',
              color: textColor,
              secondaryColor: secondaryColor,
            ),
          ),
          ...cartState.selectedAddons.map(
            (addon) => _itemRow(
              addon.name,
              '₹${addon.price}',
              color: textColor,
              secondaryColor: secondaryColor,
            ),
          ),
          Divider(height: 48, color: isDark ? Colors.white12 : null),
          _itemRow(
            'Subtotal',
            '₹${total.toStringAsFixed(0)}',
            color: textColor,
            secondaryColor: secondaryColor,
          ),
          _itemRow(
            'GST (18%)',
            '₹${(total * 0.18).toStringAsFixed(0)}',
            color: textColor,
            secondaryColor: secondaryColor,
          ),
          Divider(height: 48, color: isDark ? Colors.white12 : null),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grand Total',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isDesktop ? 20 : 18,
                  color: textColor,
                ),
              ),
              Text(
                '₹${(total * 1.18).toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: isDesktop ? 28 : 22,
                  color: isDark ? const Color(0xFFFFCC00) : AppTheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _itemRow(
    String label,
    String value, {
    Color? color,
    Color? secondaryColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: secondaryColor ?? Colors.grey,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddonsRow(
    AsyncValue<List<dynamic>> addonsAsync,
    cartState, {
    bool isDesktop = false,
  }) {
    return addonsAsync.when(
      data: (addons) {
        final filtered = addons
            .where((a) => !cartState.selectedAddons.any((sa) => sa.id == a.id))
            .take(6)
            .toList();
        if (filtered.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: isDesktop ? 160 : 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final addon = filtered[index];
              return Container(
                width: isDesktop ? 140 : 100,
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  children: [
                    Image.network(
                      addon.imageUrl,
                      width: isDesktop ? 50 : 30,
                      height: isDesktop ? 50 : 30,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.add_task),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      addon.name,
                      style: TextStyle(
                        fontSize: isDesktop ? 12 : 10,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '₹${addon.price}',
                      style: TextStyle(
                        fontSize: isDesktop ? 12 : 10,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () =>
                          ref.read(cartProvider.notifier).toggleAddon(addon),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.primary),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Add',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildBottomAction(double total) {
    return Container(
      padding: const EdgeInsets.all(24),
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
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Amount to Pay',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  '₹${(total * 1.18).toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        if (_currentStep == 0) {
                          setState(() => _currentStep = 1);
                        } else {
                          _placeOrder();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _currentStep == 0
                            ? 'Review & Pay'
                            : 'Pay & Confirm Booking',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddressSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final addressesAsync = ref.watch(userAddressesProvider);

          return Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Address',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: addressesAsync.when(
                    data: (addresses) => addresses.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_off_outlined,
                                  size: 64,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No addresses saved yet',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: addresses.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final address = addresses[index];
                              final isSelected =
                                  ref.watch(selectedAddressProvider)?.id ==
                                  address.id;

                              return InkWell(
                                onTap: () {
                                  ref
                                      .read(selectedAddressProvider.notifier)
                                      .select(address);
                                  Navigator.pop(context);
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.primary
                                          : Colors.grey.shade200,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    color: isSelected
                                        ? AppTheme.primary.withOpacity(0.02)
                                        : Colors.white,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        address.label == 'Home'
                                            ? Icons.home_outlined
                                            : address.label == 'Work'
                                            ? Icons.work_outline
                                            : Icons.location_on_outlined,
                                        color: isSelected
                                            ? AppTheme.primary
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              address.label,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? AppTheme.primary
                                                    : Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              address.fullAddress,
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        Icon(
                                          Icons.check_circle,
                                          color: AppTheme.primary,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Error: $err')),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/add-address');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Address'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: BorderSide(color: AppTheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
