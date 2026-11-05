import 'package:flutter/material.dart';
import 'types/godude.dart';
import 'data/sri_lanka_data.dart';
import 'theme/app_theme.dart';
import 'utils/calculations.dart';
import 'components/visual_assets.dart';
import 'screens/home_view.dart';
import 'screens/foods_view.dart';
import 'screens/pick_drop_view.dart';
import 'screens/savings_view.dart';
import 'screens/activity_view.dart';
import 'screens/offers_view.dart';
import 'screens/profile_view.dart';

void main() {
  runApp(const GoDudeApp());
}

class GoDudeApp extends StatelessWidget {
  const GoDudeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GO DUDE – Sri Lanka Super App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const GoDudeMainScreen(),
    );
  }
}

class GoDudeMainScreen extends StatefulWidget {
  const GoDudeMainScreen({super.key});

  @override
  State<GoDudeMainScreen> createState() => _GoDudeMainScreenState();
}

class _GoDudeMainScreenState extends State<GoDudeMainScreen> {
  MainTab _activeTab = MainTab.home;
  ActiveServiceView _activeService = ActiveServiceView.none;

  // Contextual parameters
  String _foodSearchSeed = '';
  String? _foodRestaurantSeed;
  String _pickDropModeSeed = 'p2p';
  bool _pickDropParcelSeed = false;

  final List<CartItem> _cart = [];
  late List<ActivityBooking> _bookings;
  late List<SavingsTransaction> _savingsTransactions;
  late List<PromotionalOffer> _offers;
  late CustomerProfile _profile;
  List<String> _bookmarkedIds = ['rest-pilawoos', 'rest-upalis'];
  PromotionalOffer? _appliedOffer;
  String? _toastMessage;

  @override
  void initState() {
    super.initState();
    _bookings = List.from(INITIAL_ACTIVITIES);
    _savingsTransactions = List.from(INITIAL_SAVINGS_LEDGER);
    _offers = List.from(INITIAL_OFFERS);
    _profile = INITIAL_CUSTOMER_PROFILE;
    _appliedOffer = INITIAL_OFFERS.isNotEmpty ? INITIAL_OFFERS[0] : null;
  }

  void _showToast(String msg) {
    setState(() {
      _toastMessage = msg;
    });
    Future.delayed(const Duration(milliseconds: 3800), () {
      if (mounted && _toastMessage == msg) {
        setState(() {
          _toastMessage = null;
        });
      }
    });
  }

  SriLankaLocation get _currentLocation {
    return SRI_LANKA_LOCATIONS.firstWhere(
      (l) => l.id == _profile.selectedLocationId,
      orElse: () => SRI_LANKA_LOCATIONS[0],
    );
  }

  SavingsLedgerSummary get _savingsSummary {
    return summarizeSavingsLedger(_savingsTransactions, '2026-10');
  }

  List<ActivityBooking> get _activeBookings {
    return _bookings
        .where((b) =>
            b.status != 'Delivered' &&
            b.status != 'Completed' &&
            b.status != 'Cancelled')
        .toList();
  }

  void _handleOpenService(
    ActiveServiceView service, {
    String? foodQuery,
    String? restaurantId,
    String? pickDropMode,
    bool? isParcel,
  }) {
    setState(() {
      _activeTab = MainTab.home;
      if (service == ActiveServiceView.foods) {
        _foodSearchSeed = foodQuery ?? '';
        _foodRestaurantSeed = restaurantId;
      } else if (service == ActiveServiceView.pickdrop) {
        _pickDropModeSeed = pickDropMode ?? 'p2p';
        _pickDropParcelSeed = isParcel ?? false;
      }
      _activeService = service;
    });
  }

  void _handleNavigateMainTab(MainTab tab) {
    setState(() {
      _activeService = ActiveServiceView.none;
      _activeTab = tab;
    });
  }

  void _handleAddToCart(CartItem newItem) {
    setState(() {
      final existingIdx =
          _cart.indexWhere((i) => i.cartItemId == newItem.cartItemId);
      if (existingIdx > -1) {
        _cart[existingIdx].quantity += newItem.quantity;
      } else {
        _cart.add(newItem);
      }
    });
    _showToast('Added ${newItem.foodItem.name} (${newItem.portion}) to cart');
  }

  void _handleUpdateCartQuantity(String cartItemId, int delta) {
    setState(() {
      final idx = _cart.indexWhere((i) => i.cartItemId == cartItemId);
      if (idx > -1) {
        _cart[idx].quantity += delta;
        if (_cart[idx].quantity <= 0) {
          _cart.removeAt(idx);
        }
      }
    });
  }

  void _handleCompleteFoodOrder(
    ActivityBooking newOrder,
    int savingsCreditLKR,
    int eligibleBaseLKR,
  ) {
    setState(() {
      _bookings.insert(0, newOrder);
      _cart.clear();

      if (savingsCreditLKR > 0) {
        final creditTx = SavingsTransaction(
          id: 'SAV-${1000 + (savingsCreditLKR % 8999)}',
          type: 'credit_order',
          title: '10% Savings · ${newOrder.title}',
          referenceId: newOrder.id,
          date: '2026-10-21',
          eligibleBaseAmountLKR: eligibleBaseLKR,
          amountLKR: savingsCreditLKR,
          status: 'Completed',
        );
        _savingsTransactions.insert(0, creditTx);
      }
    });
    _showToast(
      'Order ${newOrder.id} confirmed! +LKR $savingsCreditLKR credited to your 10% Savings Wallet.',
    );
  }

  void _handleCompleteRideBooking(
    ActivityBooking newBooking,
    int savingsCreditLKR,
    int eligibleBaseLKR,
  ) {
    setState(() {
      _bookings.insert(0, newBooking);

      if (savingsCreditLKR > 0) {
        final creditTx = SavingsTransaction(
          id: 'SAV-${1000 + (savingsCreditLKR % 8999)}',
          type: 'credit_ride',
          title: '10% Savings · ${newBooking.serviceType}',
          referenceId: newBooking.id,
          date: '2026-10-21',
          eligibleBaseAmountLKR: eligibleBaseLKR,
          amountLKR: savingsCreditLKR,
          status: 'Completed',
        );
        _savingsTransactions.insert(0, creditTx);
      }
    });
    _showToast(
      '${newBooking.serviceType} ${newBooking.id} booked! +LKR $savingsCreditLKR added to Savings.',
    );
  }

  void _handleWithdrawToBank(int amountLKR, BankAccount bankAccount) {
    setState(() {
      final withdrawTx = SavingsTransaction(
        id: 'SAV-${1000 + (amountLKR % 8999)}',
        type: 'withdrawal_bank',
        title: 'Monthly Bank Transfer · ${bankAccount.bankName}',
        referenceId: 'WDR-GD-${100 + (amountLKR % 800)}',
        date: '2026-10-21',
        amountLKR: -amountLKR.abs(),
        status: 'Completed',
        recipientDetails:
            '${bankAccount.bankName} (${bankAccount.accountNumberMasked})',
      );
      _savingsTransactions.insert(0, withdrawTx);
      _profile.lastWithdrawalMonth = '2026-10';
    });
    _showToast('Transferred LKR ${formatLKR(amountLKR)} to ${bankAccount.bankName}');
  }

  void _handleDonateToCharity(int amountLKR, CharityOrganization charity) {
    setState(() {
      final donateTx = SavingsTransaction(
        id: 'SAV-${1000 + (amountLKR % 8999)}',
        type: 'donation_charity',
        title: 'Social Cause Donation · ${charity.name}',
        referenceId: 'DON-GD-${100 + (amountLKR % 800)}',
        date: '2026-10-21',
        amountLKR: -amountLKR.abs(),
        status: 'Completed',
        recipientDetails: '${charity.name} (${charity.registrationNo})',
      );
      _savingsTransactions.insert(0, donateTx);
    });
    _showToast('Donated LKR ${formatLKR(amountLKR)} to ${charity.name}!');
  }

  void _handleAdvanceBookingStatus(String bookingId) {
    setState(() {
      for (final b in _bookings) {
        if (b.id == bookingId) {
          final nextStep = (b.progressStep + 1).clamp(1, 5);
          final statusMap = {
            1: 'Confirmed',
            2: 'Preparing',
            3: 'Rider Assigned',
            4: 'On the Way',
            5: b.serviceType == 'Food Delivery' ? 'Delivered' : 'Completed',
          };
          b.progressStep = nextStep;
          b.status = statusMap[nextStep] ?? 'Completed';
          b.etaMins = nextStep == 5 ? 0 : (b.etaMins - 4).clamp(2, 99);
          break;
        }
      }
    });
    _showToast('Updated live status for booking $bookingId');
  }

  void _handleCancelBooking(String bookingId) {
    setState(() {
      for (final b in _bookings) {
        if (b.id == bookingId) {
          b.status = 'Cancelled';
          b.paymentStatus = 'Refunded';
          b.etaMins = 0;
          break;
        }
      }
    });
    _showToast('Booking $bookingId cancelled & marked for full refund.');
  }

  void _handleResetDemoData() {
    setState(() {
      _cart.clear();
      _bookings = List.from(INITIAL_ACTIVITIES);
      _savingsTransactions = List.from(INITIAL_SAVINGS_LEDGER);
      _offers = List.from(INITIAL_OFFERS);
      _profile = INITIAL_CUSTOMER_PROFILE;
      _bookmarkedIds = ['rest-pilawoos', 'rest-upalis'];
      _appliedOffer = INITIAL_OFFERS.isNotEmpty ? INITIAL_OFFERS[0] : null;
    });
    _showToast('All GO DUDE Customer App demo data reset to initial state.');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;

    return Scaffold(
      backgroundColor: isDesktop ? AppTheme.pageBg : AppTheme.mobilePhoneBg,
      body: Stack(
        children: [
          if (isDesktop) _buildDesktopLayout() else _buildMobileLayout(),

          // GLOBAL TOAST NOTIFICATION
          if (_toastMessage != null)
            Positioned(
              top: 14,
              left: 20,
              right: 20,
              child: Center(
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(16),
                  color: AppTheme.darkNavy.withValues(alpha: 0.95),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 440),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.skyBlue.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _toastMessage!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _toastMessage = null;
                            });
                          },
                          child: const Text(
                            'OK',
                            style: TextStyle(
                              color: AppTheme.skyBlue,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      children: [
        // DESKTOP HEADER BAR (Zone 1 Brand, Zone 2 Nav, Zone 3 CTA)
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          color: AppTheme.darkNavy,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  _handleNavigateMainTab(MainTab.home);
                },
                child: const GoDudeBrandLogo(size: 'md'),
              ),
              Row(
                children: [
                  _navLink('Home', () => _handleNavigateMainTab(MainTab.home)),
                  const SizedBox(width: 24),
                  _navLink(
                    'Foods',
                    () => _handleOpenService(ActiveServiceView.foods,
                        foodQuery: 'Chicken Kottu'),
                  ),
                  const SizedBox(width: 24),
                  _navLink(
                    'Pick & Drop',
                    () => _handleOpenService(ActiveServiceView.pickdrop,
                        pickDropMode: 'p2p'),
                  ),
                  const SizedBox(width: 24),
                  _navLink(
                    'Savings Wallet',
                    () => _handleOpenService(ActiveServiceView.savings),
                  ),
                  const SizedBox(width: 24),
                  _navLink(
                    'Activity (${_activeBookings.length})',
                    () => _handleNavigateMainTab(MainTab.activity),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => _handleOpenService(ActiveServiceView.foods,
                    foodQuery: 'Chicken Kottu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.skyBlue,
                  foregroundColor: AppTheme.darkNavy,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Order Chicken Kottu',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),

        // DESKTOP BODY: Dual Column (Mobile Showcase on left, Companion Deck on right)
        Expanded(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1280),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LEFT: Mobile Application Phone Frame
                  Expanded(
                    flex: 7,
                    child: Center(
                      child: Container(
                        width: 440,
                        height: 840,
                        decoration: BoxDecoration(
                          color: AppTheme.mobilePhoneBg,
                          borderRadius: BorderRadius.circular(38),
                          border: Border.all(
                            color: AppTheme.slate900,
                            width: 8,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x25000000),
                              blurRadius: 30,
                              offset: Offset(0, 15),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _buildPhoneAppInner(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),

                  // RIGHT: Desktop Companion Deck
                  Expanded(
                    flex: 5,
                    child: SingleChildScrollView(
                      child: _buildDesktopCompanionDeck(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return _buildPhoneAppInner();
  }

  Widget _buildPhoneAppInner() {
    return Column(
      children: [
        // Current Screen Content (Takes all available space above bottom nav)
        Expanded(
          child: _renderActiveScreen(),
        ),

        // BOTTOM NAVIGATION BAR (Fixed at bottom without obscuring content)
        Container(
          height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.96),
              border: const Border(
                top: BorderSide(color: AppTheme.slate200),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 10,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildBottomNavBtn(
                  tab: MainTab.home,
                  label: 'Home',
                  icon: Icons.home,
                ),
                _buildBottomNavBtn(
                  tab: MainTab.activity,
                  label: 'Activity (${_activeBookings.length})',
                  icon: Icons.assignment,
                ),
                _buildBottomNavBtn(
                  tab: MainTab.offers,
                  label: 'Offers',
                  icon: Icons.local_offer,
                ),
                _buildBottomNavBtn(
                  tab: MainTab.profile,
                  label: 'Profile',
                  icon: Icons.person,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBottomNavBtn({
    required MainTab tab,
    required String label,
    required IconData icon,
  }) {
    final isSelected =
        _activeService == ActiveServiceView.none && _activeTab == tab;

    return Expanded(
      child: InkWell(
        onTap: () => _handleNavigateMainTab(tab),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? AppTheme.primaryBlue : AppTheme.slate500,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected ? AppTheme.primaryBlue : AppTheme.slate500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _renderActiveScreen() {
    if (_activeService == ActiveServiceView.foods) {
      return FoodsView(
        initialQuery: _foodSearchSeed,
        initialRestaurantId: _foodRestaurantSeed,
        restaurants: RESTAURANTS,
        foodItems: FOOD_ITEMS,
        cart: _cart,
        appliedOffer: _appliedOffer,
        offers: _offers,
        currentLocation: _currentLocation,
        profile: _profile,
        onAddToCart: _handleAddToCart,
        onUpdateCartQuantity: _handleUpdateCartQuantity,
        onClearCart: () => setState(() => _cart.clear()),
        onApplyOffer: (off) => setState(() => _appliedOffer = off),
        onCompleteFoodOrder: _handleCompleteFoodOrder,
        onBackHome: () =>
            setState(() => _activeService = ActiveServiceView.none),
        onGoToActivity: () => _handleNavigateMainTab(MainTab.activity),
      );
    }

    if (_activeService == ActiveServiceView.pickdrop) {
      return PickDropView(
        initialMode: _pickDropModeSeed,
        initialIsParcel: _pickDropParcelSeed,
        locations: SRI_LANKA_LOCATIONS,
        currentLocation: _currentLocation,
        vehicles: VEHICLE_OPTIONS,
        onCompleteRideBooking: _handleCompleteRideBooking,
        onBackHome: () =>
            setState(() => _activeService = ActiveServiceView.none),
        onGoToActivity: () => _handleNavigateMainTab(MainTab.activity),
      );
    }

    if (_activeService == ActiveServiceView.savings) {
      return SavingsView(
        transactions: _savingsTransactions,
        charities: CHARITY_ORGANIZATIONS,
        profile: _profile,
        onWithdrawToBank: _handleWithdrawToBank,
        onDonateToCharity: _handleDonateToCharity,
        onBackHome: () =>
            setState(() => _activeService = ActiveServiceView.none),
      );
    }

    switch (_activeTab) {
      case MainTab.home:
        return HomeView(
          currentLocation: _currentLocation,
          locations: SRI_LANKA_LOCATIONS,
          onSelectLocation: (locId) {
            setState(() {
              _profile.selectedLocationId = locId;
            });
          },
          restaurants: RESTAURANTS,
          activeBookings: _activeBookings,
          totalBalanceLKR: _savingsSummary.totalBalanceLKR,
          currentMonthSavedLKR: _savingsSummary.currentMonthSavedLKR,
          offers: _offers,
          bookmarkedIds: _bookmarkedIds,
          onToggleBookmark: (rId) {
            setState(() {
              if (_bookmarkedIds.contains(rId)) {
                _bookmarkedIds.remove(rId);
              } else {
                _bookmarkedIds.add(rId);
              }
            });
          },
          onOpenService: _handleOpenService,
          onNavigateTab: _handleNavigateMainTab,
          onApplyOfferCode: (off) {
            setState(() {
              _appliedOffer = off;
            });
            _showToast(
                'Promo voucher ${off.promoCode} (${off.discountLabel}) applied!');
          },
        );
      case MainTab.activity:
        return ActivityView(
          bookings: _bookings,
          currentLocation: _currentLocation,
          onAdvanceBookingStatus: _handleAdvanceBookingStatus,
          onCancelBooking: _handleCancelBooking,
          onBookNewService: (srv) => _handleOpenService(srv),
        );
      case MainTab.offers:
        return OffersView(
          offers: _offers,
          membershipPlans: BUSINESS_MEMBERSHIP_PLANS,
          appliedOffer: _appliedOffer,
          onClaimOffer: (off) {
            setState(() {
              _appliedOffer = off;
            });
            _showToast(
                'Applied ${off.promoCode} (${off.discountLabel}) to your checkout!');
          },
          onPublishDemoOffer: (newOffer, plan) {
            setState(() {
              _offers.insert(0, newOffer);
            });
            _showToast(
                'Published demo offer "${newOffer.title}" under ${plan.name} plan.');
          },
        );
      case MainTab.profile:
        return ProfileView(
          profile: _profile,
          bookings: _bookings,
          transactions: _savingsTransactions,
          onUpdateProfile: (up) {
            setState(() {
              _profile = up;
            });
          },
          onResetDemoData: _handleResetDemoData,
        );
    }
  }

  Widget _buildDesktopCompanionDeck() {
    final totalCartItems =
        _cart.fold<int>(0, (sum, i) => sum + i.quantity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Quick Service Launcher Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.slate200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GO DUDE Sri Lanka · Quick Service Deck',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.slate900),
                        ),
                        Text(
                          'Switch between the 3 core services & 4 bottom navigation tabs',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: AppTheme.slate500),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.explore, color: AppTheme.primaryBlue, size: 20),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _companionServiceBtn(
                      title: 'Foods',
                      sub: 'Green & Yellow',
                      icon: Icons.restaurant,
                      isActive: _activeService == ActiveServiceView.foods,
                      activeColor: AppTheme.foodGreen,
                      onTap: () => _handleOpenService(ActiveServiceView.foods,
                          foodQuery: 'Chicken Kottu'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _companionServiceBtn(
                      title: 'Pick & Drop',
                      sub: 'P2P & Flexible',
                      icon: Icons.navigation,
                      isActive: _activeService == ActiveServiceView.pickdrop,
                      activeColor: AppTheme.primaryBlue,
                      onTap: () => _handleOpenService(ActiveServiceView.pickdrop,
                          pickDropMode: 'p2p'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _companionServiceBtn(
                      title: '10% Savings',
                      sub: 'Bank & Charity',
                      icon: Icons.savings,
                      isActive: _activeService == ActiveServiceView.savings,
                      activeColor: AppTheme.savingsOrange,
                      onTap: () =>
                          _handleOpenService(ActiveServiceView.savings),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Active Cart Status Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.slate50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.slate200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.shopping_bag,
                              size: 18, color: AppTheme.foodGreen),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Shopping Cart ($totalCartItems items)',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Active Voucher: ${_appliedOffer != null ? _appliedOffer!.promoCode : 'None'}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 10, color: AppTheme.slate500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () =>
                          _handleOpenService(ActiveServiceView.foods),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.foodGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Open Cart',
                          style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // LIVE COMPANION SAVINGS & ACTIVE BOOKINGS CARD
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF071529), Color(0xFF0C2342), Color(0xFF1E3A8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x25000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const GoDudeBrandLogo(size: 'sm'),
                  Text(
                    'Account ${_profile.accountId}',
                    style: const TextStyle(
                      color: AppTheme.skyBlue,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('10% Savings Balance',
                              style: TextStyle(
                                  color: Color(0xFFBAE6FD), fontSize: 10)),
                          Text(
                            'LKR ${formatLKR(_savingsSummary.totalBalanceLKR)}',
                            style: const TextStyle(
                              color: Color(0xFFFDE047),
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '+LKR ${formatLKR(_savingsSummary.currentMonthSavedLKR)} this month',
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Social Donations',
                              style: TextStyle(
                                  color: Color(0xFFBAE6FD), fontSize: 10)),
                          Text(
                            'LKR ${formatLKR(_savingsSummary.totalDonatedLKR)}',
                            style: const TextStyle(
                              color: Color(0xFF86EFAC),
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '${CHARITY_ORGANIZATIONS.length} Verified SL Charities',
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Simultaneous Active Bookings (${_activeBookings.length})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _handleNavigateMainTab(MainTab.activity),
                    child: const Text(
                      'Manage All →',
                      style: TextStyle(
                        color: AppTheme.skyBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Column(
                children: _activeBookings.take(3).map((b) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.darkNavy.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                b.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${b.id} · ${b.status}',
                                style: const TextStyle(
                                  color: Color(0xFFBAE6FD),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _handleAdvanceBookingStatus(b.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppTheme.skyBlue.withValues(alpha: 0.2),
                            foregroundColor: AppTheme.skyBlue,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Step +1',
                              style: TextStyle(fontSize: 10)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),
              const Divider(color: Colors.white12),
              const SizedBox(height: 6),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome,
                            size: 14, color: AppTheme.foodYellow),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Local Prototype Active',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _handleResetDemoData,
                    child: const Text(
                      'Reset Demo State',
                      style: TextStyle(color: Color(0xFFFDA4AF), fontSize: 11),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _companionServiceBtn({
    required String title,
    required String sub,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? activeColor : AppTheme.slate200,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: isActive ? activeColor : AppTheme.slate600),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive ? activeColor : AppTheme.slate900,
              ),
            ),
            Text(
              sub,
              style: const TextStyle(fontSize: 9, color: AppTheme.slate500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navLink(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.slate300,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
