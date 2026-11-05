import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../types/godude.dart';
import '../theme/app_theme.dart';
import '../utils/calculations.dart';
import '../components/visual_assets.dart';

class FoodsView extends StatefulWidget {
  final String initialQuery;
  final String? initialRestaurantId;
  final List<Restaurant> restaurants;
  final List<FoodItem> foodItems;
  final List<CartItem> cart;
  final PromotionalOffer? appliedOffer;
  final List<PromotionalOffer> offers;
  final SriLankaLocation currentLocation;
  final CustomerProfile profile;
  final ValueChanged<CartItem> onAddToCart;
  final Function(String cartItemId, int delta) onUpdateCartQuantity;
  final VoidCallback onClearCart;
  final ValueChanged<PromotionalOffer?> onApplyOffer;
  final Function(
    ActivityBooking booking,
    int savingsCreditLKR,
    int eligibleBaseLKR,
  ) onCompleteFoodOrder;
  final VoidCallback onBackHome;
  final VoidCallback onGoToActivity;

  const FoodsView({
    super.key,
    this.initialQuery = '',
    this.initialRestaurantId,
    required this.restaurants,
    required this.foodItems,
    required this.cart,
    this.appliedOffer,
    required this.offers,
    required this.currentLocation,
    required this.profile,
    required this.onAddToCart,
    required this.onUpdateCartQuantity,
    required this.onClearCart,
    required this.onApplyOffer,
    required this.onCompleteFoodOrder,
    required this.onBackHome,
    required this.onGoToActivity,
  });

  @override
  State<FoodsView> createState() => _FoodsViewState();
}

class _FoodsViewState extends State<FoodsView> {
  late TextEditingController _searchController;
  RestaurantSortOption _sortBy = RestaurantSortOption.rating;
  String? _selectedRestaurantId;

  // Customization modal state
  FoodItem? _customizingFood;
  String _portion = 'Regular';
  String _spiceLevel = 'Medium Spicy';
  List<FoodCustomizationOption> _selectedAddons = [];
  final TextEditingController _specialInstructionsController =
      TextEditingController();

  // Checkout modal state
  bool _showCheckoutModal = false;
  late TextEditingController _deliveryAddressController;
  late TextEditingController _phoneController;
  String _paymentMethod = 'Visa •••• 4242';
  bool _isProcessingPayment = false;
  ActivityBooking? _confirmedReceipt;

  final List<String> _popularDishes = [
    'Chicken Kottu',
    'Cheese Kottu',
    'Biriyani',
    'Fried Rice',
    'Lamprais',
    'Hoppers',
    'Burgers',
    'Isso Wade',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _selectedRestaurantId = widget.initialRestaurantId;
    _deliveryAddressController =
        TextEditingController(text: widget.currentLocation.address);
    _phoneController = TextEditingController(text: widget.profile.phone);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _specialInstructionsController.dispose();
    _deliveryAddressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Restaurant? get _activeRestaurant {
    if (_selectedRestaurantId == null) return null;
    return widget.restaurants
        .firstWhere((r) => r.id == _selectedRestaurantId, orElse: () => widget.restaurants.first);
  }

  Restaurant? get _cartRestaurant {
    if (widget.cart.isEmpty) return _activeRestaurant;
    return widget.restaurants
        .firstWhere((r) => r.id == widget.cart[0].restaurantId, orElse: () => widget.restaurants.first);
  }

  int get _deliveryFeeLKR => _cartRestaurant?.deliveryFeeLKR ?? 150;

  CartTotalsResult get _cartTotals => calculateCartTotals(
        widget.cart,
        _deliveryFeeLKR,
        widget.appliedOffer,
      );

  void _openCustomizeModal(FoodItem food) {
    setState(() {
      _customizingFood = food;
      _portion = 'Regular';
      _spiceLevel = food.isSpicy ? 'Sri Lankan Fiery' : 'Medium Spicy';
      _selectedAddons = [];
      _specialInstructionsController.clear();
    });
  }

  void _confirmAddToCart() {
    final food = _customizingFood;
    if (food == null) return;

    final rest = widget.restaurants.firstWhere(
      (r) => r.id == food.restaurantId,
      orElse: () => widget.restaurants.first,
    );

    final unitTotal = calculateCustomizedFoodUnitPrice(
      food,
      _portion,
      _selectedAddons.map((a) => a.priceLKR).toList(),
    );

    final newItem = CartItem(
      cartItemId:
          '${food.id}-$_portion-$_spiceLevel-${_selectedAddons.map((a) => a.id).join(",")}',
      foodItem: food,
      restaurantId: food.restaurantId,
      restaurantName: rest.name,
      quantity: 1,
      portion: _portion,
      spiceLevel: _spiceLevel,
      selectedAddons: List.from(_selectedAddons),
      specialInstructions: _specialInstructionsController.text.trim(),
      unitTotalLKR: unitTotal,
    );

    widget.onAddToCart(newItem);
    setState(() {
      _customizingFood = null;
    });
  }

  void _handlePlaceOrder() {
    if (widget.cart.isEmpty || _deliveryAddressController.text.trim().isEmpty) {
      return;
    }
    setState(() {
      _isProcessingPayment = true;
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      final orderNum = math.Random().nextInt(8999) + 1000;
      final order = ActivityBooking(
        id: 'ORD-GD-$orderNum',
        serviceType: 'Food Delivery',
        title: widget.cart[0].restaurantName,
        subtitle: widget.cart
            .map((c) => '${c.quantity}x ${c.foodItem.name} (${c.portion})')
            .join(', '),
        createdAt: 'Just now',
        status: 'Preparing',
        paymentMethod: _paymentMethod,
        paymentStatus: 'Paid (Verified)',
        pickupAddress: _cartRestaurant?.address ?? 'Colombo Partner Kitchen',
        destinationAddress: _deliveryAddressController.text.trim(),
        subtotalLKR: _cartTotals.foodSubtotalLKR,
        deliveryOrServiceFeeLKR: _cartTotals.deliveryFeeLKR,
        discountLKR: _cartTotals.discountLKR,
        totalPaidLKR: _cartTotals.finalPayableLKR,
        savingsEarnedLKR: _cartTotals.savingsAllocationLKR,
        etaMins: _cartRestaurant?.deliveryTimeMins ?? 24,
        distanceKm: _cartRestaurant?.distanceKm ?? 1.9,
        driverOrRider: const DriverOrRider(
          name: 'Kasun Rajapaksha',
          phone: '+94 77 812 4490',
          vehicleName: 'Honda Dio Food Express',
          plateNumber: 'WP BKT-6621',
          rating: 4.95,
        ),
        itemsSummary: widget.cart
            .map(
              (c) =>
                  '${c.quantity}x ${c.foodItem.name} (${c.portion}, ${c.spiceLevel}) — LKR ${formatLKR(c.unitTotalLKR * c.quantity)}',
            )
            .toList(),
        progressStep: 2,
      );

      widget.onCompleteFoodOrder(
        order,
        _cartTotals.savingsAllocationLKR,
        _cartTotals.eligibleForSavingsLKR,
      );

      setState(() {
        _isProcessingPayment = false;
        _showCheckoutModal = false;
        _confirmedReceipt = order;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final matchedResults = searchRestaurantsByFood(
      _searchController.text,
      widget.restaurants,
      widget.foodItems,
      sortBy: _sortBy,
      cityFilter: 'All',
    );

    final totalCartUnits =
        widget.cart.fold<int>(0, (sum, i) => sum + i.quantity);

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // TOP GREEN STICKY HEADER
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                decoration: const BoxDecoration(
                  color: Color(0xFF0E3A1F),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(26)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Nav Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              if (_selectedRestaurantId != null) {
                                setState(() {
                                  _selectedRestaurantId = null;
                                });
                              } else {
                                widget.onBackHome();
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.arrow_back,
                                      size: 16, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    _selectedRestaurantId != null
                                        ? 'All Restaurants'
                                        : 'Home',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'GO DUDE Foods',
                                style: TextStyle(
                                  color: AppTheme.foodYellow,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                'Fresh · +10% Auto Savings',
                                style: TextStyle(
                                  color: Color(0xFFD1FAE5),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Dish search input
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) {
                            setState(() {
                              if (_selectedRestaurantId != null) {
                                _selectedRestaurantId = null;
                              }
                            });
                          },
                          style: const TextStyle(
                            color: AppTheme.slate900,
                            fontSize: 12,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Search dish e.g. Chicken Kottu, Biriyani...',
                            hintStyle: const TextStyle(
                              color: AppTheme.slate400,
                              fontSize: 11,
                            ),
                            prefixIcon: const Icon(Icons.search,
                                size: 18, color: Color(0xFF0E3A1F)),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 16),
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                      });
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Popular dish filter chips
                      SizedBox(
                        height: 28,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _popularDishes.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 6),
                          itemBuilder: (context, idx) {
                            final dish = _popularDishes[idx];
                            final active = _searchController.text
                                    .toLowerCase() ==
                                dish.toLowerCase();
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _searchController.text = active ? '' : dish;
                                  _selectedRestaurantId = null;
                                });
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: active
                                      ? AppTheme.foodYellow
                                      : const Color(0xFF062312)
                                          .withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: active
                                        ? AppTheme.foodYellow
                                        : Colors.white12,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  dish,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: active
                                        ? AppTheme.slate950
                                        : const Color(0xFFD1FAE5),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // BODY CONTENT
              if (_activeRestaurant == null) ...[
                // VIEW 1: RESTAURANT LIST
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Sort bar
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.slate200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'Matching (${matchedResults.length})'
                                  : 'All Kitchens (${matchedResults.length})',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.slate800,
                              ),
                            ),
                            Row(
                              children: [
                                _sortChip('Top Rated ★', RestaurantSortOption.rating),
                                const SizedBox(width: 4),
                                _sortChip('Fastest', RestaurantSortOption.deliveryTime),
                                const SizedBox(width: 4),
                                _sortChip('Lowest', RestaurantSortOption.price),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Restaurants List
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: matchedResults.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, idx) {
                          final item = matchedResults[idx];
                          final rest = item.restaurant;
                          final topItem = item.matchingItems.isNotEmpty
                              ? item.matchingItems.first
                              : null;

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.slate200),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x06000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedRestaurantId = rest.id;
                                        });
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: Stack(
                                          children: [
                                            SizedBox(
                                              width: 76,
                                              height: 76,
                                              child: FoodIllustration(
                                                type: topItem?.illustrationType ??
                                                    rest.illustrationType,
                                              ),
                                            ),
                                            Positioned(
                                              left: 2,
                                              right: 2,
                                              bottom: 2,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.black87,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  'From LKR ${formatLKR(item.lowestMatchingPriceLKR)}',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: AppTheme.foodYellow,
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '${idx + 1}. ${rest.name}',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme.slate900,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFEF3C7),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.star,
                                                        size: 13,
                                                        color:
                                                            Color(0xFFD97706)),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      rest.rating
                                                          .toStringAsFixed(1),
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color:
                                                            AppTheme.slate900,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            rest.tagline,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.slate500,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            '${rest.deliveryTimeMins} mins · LKR ${rest.deliveryFeeLKR} fee · ${rest.distanceKm} km',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.slate600,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                // Top matched item bar
                                if (topItem != null) ...[
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.only(top: 8),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                            color: AppTheme.slate100),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                topItem.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.slate900,
                                                ),
                                              ),
                                              Text(
                                                'LKR ${formatLKR(topItem.priceLKR)} · +LKR ${(topItem.priceLKR * 0.1).round()} Saved',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.foodGreen,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            ElevatedButton(
                                              onPressed: () =>
                                                  _openCustomizeModal(topItem),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppTheme.foodYellow,
                                                foregroundColor: Colors.black,
                                                elevation: 0,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: const Text(
                                                '+ Add',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            OutlinedButton(
                                              onPressed: () {
                                                setState(() {
                                                  _selectedRestaurantId =
                                                      rest.id;
                                                });
                                              },
                                              style: OutlinedButton.styleFrom(
                                                side: const BorderSide(
                                                    color: AppTheme.foodGreen),
                                                foregroundColor:
                                                    AppTheme.foodGreen,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: const Text(
                                                'Menu',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // VIEW 2: RESTAURANT MENU VIEW
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Restaurant Info Card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.slate200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _activeRestaurant!.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.slate900,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        size: 16, color: Color(0xFFD97706)),
                                    const SizedBox(width: 2),
                                    Text(
                                      _activeRestaurant!.rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      ' (${_activeRestaurant!.reviewCount})',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.slate500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _activeRestaurant!.tagline,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.slate600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 14, color: AppTheme.foodGreen),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _activeRestaurant!.address,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.slate500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Delivery: ${_activeRestaurant!.deliveryTimeMins} mins · Fee: LKR ${_activeRestaurant!.deliveryFeeLKR} · Distance: ${_activeRestaurant!.distanceKm} km',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.foodGreen,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        'Menu Dishes (${widget.foodItems.where((f) => f.restaurantId == _activeRestaurant!.id).length})',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.slate900,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Dishes list
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.foodItems
                            .where((f) => f.restaurantId == _activeRestaurant!.id)
                            .length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, idx) {
                          final item = widget.foodItems
                              .where((f) => f.restaurantId == _activeRestaurant!.id)
                              .toList()[idx];

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppTheme.slate200),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: SizedBox(
                                    width: 70,
                                    height: 70,
                                    child: FoodIllustration(
                                        type: item.illustrationType),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.slate900,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.slate500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${item.prepTimeMins}m prep · ${item.calories} kcal',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppTheme.slate400,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'LKR ${formatLKR(item.priceLKR)}',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w900,
                                                  color: AppTheme.slate900,
                                                ),
                                              ),
                                              Text(
                                                '+LKR ${(item.priceLKR * 0.1).round()} Savings',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.savingsOrange,
                                                ),
                                              ),
                                            ],
                                          ),
                                          ElevatedButton.icon(
                                            onPressed: () =>
                                                _openCustomizeModal(item),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppTheme.foodGreen,
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            icon: const Icon(Icons.add,
                                                size: 14),
                                            label: const Text(
                                              'Customize',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // FLOATING CART SUMMARY BAR
        if (widget.cart.isNotEmpty)
          Positioned(
            left: 16,
            right: 16,
            bottom: 76,
            child: InkWell(
              onTap: () {
                setState(() {
                  _showCheckoutModal = true;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF065F46), Color(0xFF047857)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppTheme.foodYellow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$totalCartUnits',
                        style: const TextStyle(
                          color: AppTheme.slate950,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'View Cart · ${widget.cart[0].restaurantName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Earns +LKR ${_cartTotals.savingsAllocationLKR} 10% Savings Credit',
                            style: const TextStyle(
                              color: Color(0xFFA7F3D0),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'LKR ${formatLKR(_cartTotals.finalPayableLKR)} →',
                      style: const TextStyle(
                        color: AppTheme.foodYellow,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // CUSTOMIZATION BOTTOM SHEET / MODAL
        if (_customizingFood != null) _buildCustomizationDialog(),

        // CHECKOUT BOTTOM SHEET / MODAL
        if (_showCheckoutModal) _buildCheckoutDialog(),

        // ORDER CONFIRMED RECEIPT MODAL
        if (_confirmedReceipt != null) _buildReceiptDialog(),
      ],
    );
  }

  Widget _sortChip(String label, RestaurantSortOption opt) {
    final active = _sortBy == opt;
    return InkWell(
      onTap: () {
        setState(() {
          _sortBy = opt;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active ? AppTheme.foodGreen : AppTheme.slate100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: active ? Colors.white : AppTheme.slate700,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomizationDialog() {
    final food = _customizingFood!;
    final unitPrice = calculateCustomizedFoodUnitPrice(
      food,
      _portion,
      _selectedAddons.map((a) => a.priceLKR).toList(),
    );

    return Container(
      color: Colors.black54,
      alignment: Alignment.bottomCenter,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // FIXED HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          food.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.slate900,
                          ),
                        ),
                        Text(
                          food.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.slate500),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _customizingFood = null;
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.slate200),

            // SCROLLABLE CUSTOMIZATION OPTIONS
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

              const SizedBox(height: 16),

              // 1. Portion
              const Text(
                '1. Choose Portion Size',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.slate900),
              ),
              const SizedBox(height: 8),
              Row(
                children: ['Regular', 'Large'].map((p) {
                  final isSel = _portion == p;
                  final pPrice = food.priceLKR +
                      (p == 'Large' ? food.largePriceDeltaLKR : 0);
                  return Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _portion = p;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSel
                              ? const Color(0xFFECFDF5)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSel
                                ? AppTheme.foodGreen
                                : AppTheme.slate200,
                            width: isSel ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$p Portion',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSel
                                    ? AppTheme.foodGreen
                                    : AppTheme.slate800,
                              ),
                            ),
                            Text(
                              'LKR ${formatLKR(pPrice)}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.slate600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 14),

              // 2. Spice Level
              const Text(
                '2. Spice Preference',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.slate900),
              ),
              const SizedBox(height: 8),
              Row(
                children: ['Mild', 'Medium Spicy', 'Sri Lankan Fiery'].map((sp) {
                  final isSel = _spiceLevel == sp;
                  return Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _spiceLevel = sp;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2.5),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? AppTheme.foodGreen : AppTheme.slate100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          sp,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSel ? Colors.white : AppTheme.slate800,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // 3. Add-ons
              if (food.availableAddons.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Text(
                  '3. Extra Customizations (Optional)',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.slate900),
                ),
                const SizedBox(height: 8),
                Column(
                  children: food.availableAddons.map((addon) {
                    final isChecked =
                        _selectedAddons.any((a) => a.id == addon.id);
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isChecked) {
                            _selectedAddons
                                .removeWhere((a) => a.id == addon.id);
                          } else {
                            _selectedAddons.add(addon);
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isChecked
                              ? const Color(0xFFECFDF5)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isChecked
                                ? AppTheme.foodGreen
                                : AppTheme.slate200,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              addon.label,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '+LKR ${addon.priceLKR}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.foodGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 14),

              // Kitchen Instructions
              const Text(
                'Special Kitchen Instructions',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.slate900),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _specialInstructionsController,
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'e.g. Extra gravy on the side, less oil...',
                  hintStyle:
                      const TextStyle(fontSize: 11, color: AppTheme.slate400),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppTheme.slate200),
                  ),
                ),
              ),

                  ],
                ),
              ),
            ),

            // PINNED BOTTOM ACTION BAR (ALWAYS VISIBLE)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, -3),
                  ),
                ],
                border: const Border(
                  top: BorderSide(color: AppTheme.slate200),
                ),
              ),
              child: SafeArea(
                top: false,
                child: ElevatedButton(
                  onPressed: _confirmAddToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.foodGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Add to Cart · LKR ${formatLKR(unitPrice)}',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutDialog() {
    return Container(
      color: Colors.black54,
      alignment: Alignment.bottomCenter,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // FIXED HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shopping_bag,
                          size: 20, color: AppTheme.foodGreen),
                      SizedBox(width: 8),
                      Text(
                        'Order Summary & Checkout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.slate900,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _showCheckoutModal = false;
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.slate200),

            // SCROLLABLE ORDER DETAILS, ADDRESS & PAYMENT OPTIONS
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

              // Items
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Items from ${widget.cart.isNotEmpty ? widget.cart[0].restaurantName : ''}',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.slate700),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      widget.onClearCart();
                      setState(() {
                        _showCheckoutModal = false;
                      });
                    },
                    icon: const Icon(Icons.delete_outline,
                        size: 14, color: Colors.red),
                    label: const Text(
                      'Clear Cart',
                      style: TextStyle(color: Colors.red, fontSize: 11),
                    ),
                  ),
                ],
              ),

              Column(
                children: widget.cart.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.slate50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.slate200),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.foodItem.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.slate900,
                                ),
                              ),
                              Text(
                                '${item.portion} · ${item.spiceLevel}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.slate500,
                                ),
                              ),
                              Text(
                                'LKR ${formatLKR(item.unitTotalLKR * item.quantity)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.foodGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16),
                              onPressed: () =>
                                  widget.onUpdateCartQuantity(item.cartItemId, -1),
                            ),
                            Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16),
                              onPressed: () =>
                                  widget.onUpdateCartQuantity(item.cartItemId, 1),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 10),

              // Promo Voucher Selection
              const Text(
                'Promotional Discount Voucher',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.slate800),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.offers
                      .where((o) => o.category == 'Restaurants')
                      .length,
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (context, idx) {
                    final off = widget.offers
                        .where((o) => o.category == 'Restaurants')
                        .toList()[idx];
                    final isApplied = widget.appliedOffer?.id == off.id;
                    return InkWell(
                      onTap: () {
                        widget.onApplyOffer(isApplied ? null : off);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: isApplied
                              ? const Color(0xFFECFDF5)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isApplied
                                ? AppTheme.foodGreen
                                : AppTheme.slate200,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${off.promoCode} (${off.discountLabel})',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isApplied
                                ? AppTheme.foodGreen
                                : AppTheme.slate700,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Address & Contact
              TextField(
                controller: _deliveryAddressController,
                style: const TextStyle(fontSize: 11),
                decoration: InputDecoration(
                  labelText: 'Delivery Address',
                  labelStyle: const TextStyle(fontSize: 11),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                style: const TextStyle(fontSize: 11),
                decoration: InputDecoration(
                  labelText: 'Contact Phone Number',
                  labelStyle: const TextStyle(fontSize: 11),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Payment Method
              const Text(
                'Payment Method (Simulated LKR Gateway)',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.slate800),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  'Visa •••• 4242',
                  'LankaPay QR',
                  'Genie Wallet',
                  'Cash on Delivery',
                ].map((pm) {
                  final isSel = _paymentMethod == pm;
                  return ChoiceChip(
                    label: Text(pm, style: const TextStyle(fontSize: 10)),
                    selected: isSel,
                    selectedColor: const Color(0xFFDBEAFE),
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _paymentMethod = pm;
                        });
                      }
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 14),

              // Bill Breakdown
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.slate50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.slate200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Food Items Subtotal',
                            style: TextStyle(
                                fontSize: 11, color: AppTheme.slate600)),
                        Text('LKR ${formatLKR(_cartTotals.foodSubtotalLKR)}',
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    if (_cartTotals.discountLKR > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Promo Discount (${widget.appliedOffer?.promoCode})',
                              style: const TextStyle(
                                  fontSize: 11, color: AppTheme.foodGreen)),
                          Text('-LKR ${formatLKR(_cartTotals.discountLKR)}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.foodGreen)),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Delivery Fee',
                            style: TextStyle(
                                fontSize: 11, color: AppTheme.slate600)),
                        Text('LKR ${formatLKR(_cartTotals.deliveryFeeLKR)}',
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Final Payable',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.slate900)),
                        Text('LKR ${formatLKR(_cartTotals.finalPayableLKR)}',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.slate900)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome,
                              size: 14, color: AppTheme.savingsOrange),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '+10% Savings Credit: LKR ${_cartTotals.savingsAllocationLKR} will be credited to your Savings Wallet.',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF7C2D12),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

                  ],
                ),
              ),
            ),

            // PINNED BOTTOM ACTION BAR (ALWAYS VISIBLE & NEVER CUT OFF)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
                border: const Border(
                  top: BorderSide(color: AppTheme.slate200),
                ),
              ),
              child: SafeArea(
                top: false,
                child: ElevatedButton(
                  onPressed: _isProcessingPayment ? null : _handlePlaceOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.foodGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  child: _isProcessingPayment
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Pay LKR ${formatLKR(_cartTotals.finalPayableLKR)} & Confirm Order',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptDialog() {
    final r = _confirmedReceipt!;
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.check_circle, size: 22, color: AppTheme.foodGreen),
                    SizedBox(width: 8),
                    Text(
                      'Order Confirmed!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.slate900,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _confirmedReceipt = null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Booking ID: ${r.id}',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue),
            ),
            Text(
              'Restaurant: ${r.title}',
              style: const TextStyle(fontSize: 12, color: AppTheme.slate800),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars, size: 18, color: AppTheme.foodGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '+LKR ${r.savingsEarnedLKR} Credited to 10% Savings Wallet',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.foodGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _confirmedReceipt = null;
                });
                widget.onGoToActivity();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Track Live in Activity Hub →'),
            ),
          ],
        ),
      ),
    );
  }
}
