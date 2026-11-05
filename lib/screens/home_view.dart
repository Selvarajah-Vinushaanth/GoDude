import 'package:flutter/material.dart';
import '../types/godude.dart';
import '../theme/app_theme.dart';
import '../utils/calculations.dart';
import '../components/visual_assets.dart';

class HomeView extends StatefulWidget {
  final SriLankaLocation currentLocation;
  final List<SriLankaLocation> locations;
  final ValueChanged<String> onSelectLocation;
  final List<Restaurant> restaurants;
  final List<ActivityBooking> activeBookings;
  final int totalBalanceLKR;
  final int currentMonthSavedLKR;
  final List<PromotionalOffer> offers;
  final List<String> bookmarkedIds;
  final ValueChanged<String> onToggleBookmark;
  final Function(
    ActiveServiceView service, {
    String? foodQuery,
    String? restaurantId,
    String? pickDropMode,
    bool? isParcel,
  }) onOpenService;
  final ValueChanged<MainTab> onNavigateTab;
  final ValueChanged<PromotionalOffer> onApplyOfferCode;

  const HomeView({
    super.key,
    required this.currentLocation,
    required this.locations,
    required this.onSelectLocation,
    required this.restaurants,
    required this.activeBookings,
    required this.totalBalanceLKR,
    required this.currentMonthSavedLKR,
    required this.offers,
    required this.bookmarkedIds,
    required this.onToggleBookmark,
    required this.onOpenService,
    required this.onNavigateTab,
    required this.onApplyOfferCode,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _searchController = TextEditingController();
  bool _showLocationPicker = false;
  int _activeBannerIdx = 0;

  final List<String> _quickFoodSearches = [
    'Chicken Kottu',
    'Cheese Kottu',
    'Biriyani',
    'Fried Rice',
    'Lamprais',
    'Burgers',
    'Isso Wade',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchSubmit() {
    final q = _searchController.text.trim();
    if (q.isEmpty) {
      widget.onOpenService(ActiveServiceView.foods);
      return;
    }
    final lower = q.toLowerCase();
    if (lower.contains('ride') ||
        lower.contains('tuk') ||
        lower.contains('car') ||
        lower.contains('bike') ||
        lower.contains('drop')) {
      widget.onOpenService(
        ActiveServiceView.pickdrop,
        pickDropMode: 'p2p',
        isParcel: false,
      );
    } else if (lower.contains('parcel') ||
        lower.contains('package') ||
        lower.contains('courier')) {
      widget.onOpenService(
        ActiveServiceView.pickdrop,
        pickDropMode: 'p2p',
        isParcel: true,
      );
    } else if (lower.contains('save') ||
        lower.contains('saving') ||
        lower.contains('donate')) {
      widget.onOpenService(ActiveServiceView.savings);
    } else {
      widget.onOpenService(ActiveServiceView.foods, foodQuery: q);
    }
  }

  @override
  Widget build(BuildContext context) {
    const monthlyTargetLKR = 5000;
    final monthlyProgressPct = (widget.currentMonthSavedLKR / monthlyTargetLKR * 100)
        .clamp(0.0, 100.0)
        .toInt();

    final trending = List<Restaurant>.from(widget.restaurants)
      ..sort((a, b) => b.rating.compareTo(a.rating));

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // STICKY TOP FROSTED NAVY HEADER
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            decoration: const BoxDecoration(
              color: AppTheme.darkNavy,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
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
                  // Top Row: Brand Logo, SL Pill, Wallet Balance, Profile Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const GoDudeBrandLogo(size: 'sm'),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Sri Lanka',
                                  style: TextStyle(
                                    color: AppTheme.skyBlue,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                        children: [
                          // Quick Wallet Pill
                          InkWell(
                            onTap: () => widget.onOpenService(ActiveServiceView.savings),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.account_balance_wallet,
                                      size: 15, color: AppTheme.savingsOrangeLight),
                                  const SizedBox(width: 5),
                                  Text(
                                    'LKR ${formatLKR(widget.totalBalanceLKR)}',
                                    style: const TextStyle(
                                      color: AppTheme.foodYellow,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Profile Button
                          InkWell(
                            onTap: () => widget.onNavigateTab(MainTab.profile),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: AppTheme.slate800,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.skyBlue.withValues(alpha: 0.5),
                                ),
                              ),
                              child: const Icon(
                                Icons.person_outline,
                                color: AppTheme.skyBlue,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                        ),
                      ),
                    ),
                  ],
                ),

                  const SizedBox(height: 12),

                  // Deliver to location selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _showLocationPicker = !_showLocationPicker;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 16, color: AppTheme.skyBlue),
                            const SizedBox(width: 4),
                            const Text(
                              'Deliver to ',
                              style: TextStyle(
                                color: AppTheme.slate300,
                                fontSize: 11,
                              ),
                            ),
                            Icon(
                              _showLocationPicker
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 16,
                              color: AppTheme.slate300,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.currentLocation.name.split('·')[0].trim(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: AppTheme.foodGreen.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              '● ',
                              style: TextStyle(
                                  color: Color(0xFF4ADE80), fontSize: 8),
                            ),
                            Text(
                              'GPS Active',
                              style: TextStyle(
                                color: Color(0xFF86EFAC),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Location picker dropdown list
                  if (_showLocationPicker) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.slate900,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppTheme.skyBlue.withValues(alpha: 0.35)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Select Sri Lanka Location',
                                style: TextStyle(
                                  color: AppTheme.skyBlue,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.close,
                                    size: 16, color: Colors.white70),
                                onPressed: () {
                                  setState(() {
                                    _showLocationPicker = false;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 180),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: widget.locations.length,
                              itemBuilder: (context, idx) {
                                final loc = widget.locations[idx];
                                final isSel = loc.id == widget.currentLocation.id;
                                return InkWell(
                                  onTap: () {
                                    widget.onSelectLocation(loc.id);
                                    setState(() {
                                      _showLocationPicker = false;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSel
                                          ? AppTheme.primaryBlue
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
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
                                                loc.name,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                loc.address,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: isSel
                                                      ? Colors.white70
                                                      : AppTheme.slate400,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          loc.city,
                                          style: TextStyle(
                                            color: isSel
                                                ? Colors.white
                                                : AppTheme.skyBlue,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Search bar
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onSubmitted: (_) => _handleSearchSubmit(),
                            style: const TextStyle(
                              color: AppTheme.slate900,
                              fontSize: 12,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Search for food, rides, packages...',
                              hintStyle: TextStyle(
                                color: AppTheme.slate400,
                                fontSize: 11,
                              ),
                              prefixIcon: Icon(Icons.search,
                                  size: 18, color: AppTheme.slate400),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _handleSearchSubmit,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Search',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // MAIN BODY CONTENT
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 2x2 CORE SERVICES GRID
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.35,
                  children: [
                    // Card 1: Food Delivery (Green)
                    _buildServiceCard(
                      gradient: const [
                        Color(0xFF16A34A),
                        Color(0xFF22C55E),
                        Color(0xFF84CC16),
                      ],
                      title: 'Food\nDelivery',
                      actionLabel: 'Order Now →',
                      icon: Icons.restaurant,
                      onTap: () => widget.onOpenService(ActiveServiceView.foods),
                      darkText: true,
                    ),

                    // Card 2: Pick & Drop (Blue)
                    _buildServiceCard(
                      gradient: const [
                        Color(0xFF0284C7),
                        Color(0xFF2563EB),
                        Color(0xFF1D4ED8),
                      ],
                      title: 'Pick &\nDrop',
                      actionLabel: 'Courier & Parcels',
                      icon: Icons.local_shipping,
                      onTap: () => widget.onOpenService(
                        ActiveServiceView.pickdrop,
                        pickDropMode: 'p2p',
                        isParcel: true,
                      ),
                    ),

                    // Card 3: Ride Booking (Navy)
                    _buildServiceCard(
                      gradient: const [
                        Color(0xFF091931),
                        Color(0xFF0F294A),
                        Color(0xFF1E3A8A),
                      ],
                      title: 'Ride\nBooking',
                      actionLabel: 'Book a Ride →',
                      icon: Icons.directions_car,
                      onTap: () => widget.onOpenService(
                        ActiveServiceView.pickdrop,
                        pickDropMode: 'p2p',
                        isParcel: false,
                      ),
                    ),

                    // Card 4: Savings & Deals (Orange)
                    _buildServiceCard(
                      gradient: const [
                        Color(0xFFEA580C),
                        Color(0xFFF97316),
                        Color(0xFFFB923C),
                      ],
                      title: 'Savings &\nDeals',
                      actionLabel: 'Save 10% Every Order',
                      icon: Icons.savings,
                      onTap: () => widget.onOpenService(ActiveServiceView.savings),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Quick Food Search Chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Text(
                        'Search Sri Lankan Dishes',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.slate800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => widget.onOpenService(ActiveServiceView.foods),
                      child: const Text(
                        'All Menus',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _quickFoodSearches.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final dish = _quickFoodSearches[idx];
                      return InkWell(
                        onTap: () => widget.onOpenService(
                          ActiveServiceView.foods,
                          foodQuery: dish,
                        ),
                        borderRadius: BorderRadius.circular(17),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(17),
                            border: Border.all(color: AppTheme.slate200),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x06000000),
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            dish,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.slate800,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Promotional Carousel Banner
                if (widget.offers.isNotEmpty) ...[
                  Builder(
                    builder: (context) {
                      final offer = widget.offers[_activeBannerIdx % widget.offers.length];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF0C0A09),
                              Color(0xFF0F172A),
                              Color(0xFF451A03),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.white12),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x20000000),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    offer.businessName.toUpperCase(),
                                    style: const TextStyle(
                                      color: Color(0xFF4ADE80),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    offer.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    offer.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFFD6D3D1),
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      widget.onApplyOfferCode(offer);
                                      widget.onOpenService(
                                        ActiveServiceView.foods,
                                        foodQuery: 'Chicken Kottu',
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF10B981),
                                      foregroundColor: Colors.black,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Claim ${offer.discountLabel}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: SizedBox(
                                width: 85,
                                height: 85,
                                child: FoodIllustration(
                                  type: _activeBannerIdx == 0
                                      ? 'kottu'
                                      : _activeBannerIdx == 1
                                          ? 'biriyani'
                                          : 'cheese_kottu',
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Dots Indicator
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (idx) {
                      final isSel = idx == _activeBannerIdx;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _activeBannerIdx = idx;
                          });
                        },
                        child: Container(
                          width: isSel ? 20 : 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 2.5),
                          decoration: BoxDecoration(
                            color: isSel
                                ? AppTheme.primaryBlue
                                : AppTheme.slate300,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    }),
                  ),
                ],

                const SizedBox(height: 20),

                // Simultaneous Active Bookings Status Bar
                if (widget.activeBookings.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.slate200),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x06000000),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(Icons.navigation,
                                      size: 16, color: AppTheme.primaryBlue),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Active Live Bookings (${widget.activeBookings.length})',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.slate900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => widget.onNavigateTab(MainTab.activity),
                              child: const Text(
                                'Track Live →',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Column(
                          children: widget.activeBookings.take(2).map((booking) {
                            return InkWell(
                              onTap: () => widget.onNavigateTab(MainTab.activity),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            booking.title,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.slate900,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${booking.id} · ${booking.status} · +LKR ${booking.savingsEarnedLKR} Saved',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.slate500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'ETA ${booking.etaMins}m',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900,
                                            color: AppTheme.primaryBlue,
                                          ),
                                        ),
                                        const Text(
                                          'Map View →',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: AppTheme.slate500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Trending Near You',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.slate900,
                            ),
                          ),
                          Text(
                            'Top-rated Sri Lankan restaurants in ${widget.currentLocation.city}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.slate500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => widget.onOpenService(ActiveServiceView.foods),
                      child: Text(
                        'See All (${widget.restaurants.length})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Restaurant Cards
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: trending.take(4).length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, idx) {
                    final rest = trending[idx];
                    final isBookmarked = widget.bookmarkedIds.contains(rest.id);

                    return InkWell(
                      onTap: () => widget.onOpenService(
                        ActiveServiceView.foods,
                        restaurantId: rest.id,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppTheme.slate200),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x04000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: SizedBox(
                                width: 72,
                                height: 72,
                                child: FoodIllustration(
                                    type: rest.illustrationType),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          rest.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.slate900,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                        icon: Icon(
                                          isBookmarked
                                              ? Icons.bookmark
                                              : Icons.bookmark_border,
                                          size: 18,
                                          color: isBookmarked
                                              ? AppTheme.primaryBlue
                                              : AppTheme.slate400,
                                        ),
                                        onPressed: () =>
                                            widget.onToggleBookmark(rest.id),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          size: 14, color: Color(0xFFFBBF24)),
                                      const SizedBox(width: 3),
                                      Text(
                                        rest.rating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.slate900,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '· ${rest.reviewCount} ratings',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.slate500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time,
                                          size: 13, color: AppTheme.foodGreen),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${rest.deliveryTimeMins} mins · LKR ${rest.deliveryFeeLKR} fee',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.slate500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Orange Savings & Deals Card matching Reference Design
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFEA580C),
                        Color(0xFFF97316),
                        Color(0xFFFB923C),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x30EA580C),
                        blurRadius: 14,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Savings & Deals',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  '10% Automatic Savings Credited on Every Order',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Color(0xFFFFEDD5),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.auto_awesome,
                                size: 18, color: Colors.amberAccent),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Two stat boxes
                      Row(
                        children: [
                          // Left White Box
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total Saved',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.slate800,
                                    ),
                                  ),
                                  const Text(
                                    'Wallet Balance',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.slate500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'LKR ${formatLKR(widget.totalBalanceLKR)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.savingsOrange,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      _miniBar(10, const Color(0xFFFDBA74)),
                                      const SizedBox(width: 4),
                                      _miniBar(14, const Color(0xFFFB923C)),
                                      const SizedBox(width: 4),
                                      _miniBar(18, const Color(0xFFF97316)),
                                      const SizedBox(width: 4),
                                      _miniBar(14, const Color(0xFF38BDF8)),
                                      const SizedBox(width: 4),
                                      _miniBar(24, const Color(0xFF2563EB)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Right Navy Box
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F243C),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Saved This Month',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '+LKR ${formatLKR(widget.currentMonthSavedLKR)}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.skyBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: monthlyProgressPct / 100.0,
                                      backgroundColor: AppTheme.slate700,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                        Color(0xFFFACC15),
                                      ),
                                      minHeight: 8,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        '0',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 9),
                                      ),
                                      Text(
                                        '$monthlyProgressPct% Goal',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Text(
                                        '100',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 9),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  widget.onNavigateTab(MainTab.offers),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                              ),
                              child: const Text(
                                'Active Coupons',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => widget
                                  .onOpenService(ActiveServiceView.savings),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppTheme.slate900,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                              ),
                              child: const Text(
                                'Withdraw or Donate',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                ),
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
          ),
        ],
      ),
    );
  }

  Widget _miniBar(double h, Color color) {
    return Container(
      width: 8,
      height: h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
      ),
    );
  }

  Widget _buildServiceCard({
    required List<Color> gradient,
    required String title,
    required String actionLabel,
    required IconData icon,
    required VoidCallback onTap,
    bool darkText = false,
  }) {
    final textColor = darkText ? AppTheme.slate950 : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x15000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                ),
                Icon(icon, size: 26, color: textColor.withValues(alpha: 0.85)),
              ],
            ),
            Text(
              actionLabel,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.95),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
