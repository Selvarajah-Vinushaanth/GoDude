import 'package:flutter/material.dart';
import '../types/godude.dart';
import '../theme/app_theme.dart';
import '../utils/calculations.dart';

class OffersView extends StatefulWidget {
  final List<PromotionalOffer> offers;
  final List<BusinessMembershipPlan> membershipPlans;
  final PromotionalOffer? appliedOffer;
  final ValueChanged<PromotionalOffer> onClaimOffer;
  final Function(PromotionalOffer newOffer, BusinessMembershipPlan selectedPlan)
      onPublishDemoOffer;

  const OffersView({
    super.key,
    required this.offers,
    required this.membershipPlans,
    this.appliedOffer,
    required this.onClaimOffer,
    required this.onPublishDemoOffer,
  });

  @override
  State<OffersView> createState() => _OffersViewState();
}

class _OffersViewState extends State<OffersView> {
  String _activeTab = 'browse'; // 'browse' | 'advertise'
  String _selectedCategory = 'All';
  String _selectedCity = 'All';
  final TextEditingController _searchController = TextEditingController();

  // Merchant Portal Form State
  late String _selectedPlanId;
  final TextEditingController _businessNameController =
      TextEditingController();
  final TextEditingController _offerTitleController =
      TextEditingController();
  final String _offerCategory = 'Restaurants';
  final String _offerCity = 'Colombo';
  final TextEditingController _discountLabelController =
      TextEditingController(text: '25% OFF');
  final TextEditingController _promoCodeController =
      TextEditingController(text: 'COLOMBO25');
  final TextEditingController _descriptionController =
      TextEditingController();
  String? _adFormError;
  Map<String, dynamic>? _publishedConfirmation;

  final List<String> _categories = [
    'All',
    'Restaurants',
    'Hotels & Stays',
    'Local Businesses',
    'Ride Deals',
  ];

  final List<String> _cities = [
    'All',
    'Colombo',
    'Kandy',
    'Galle',
    'Negombo',
  ];

  @override
  void initState() {
    super.initState();
    _selectedPlanId = widget.membershipPlans
        .firstWhere((p) => p.recommended,
            orElse: () => widget.membershipPlans[0])
        .id;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _businessNameController.dispose();
    _offerTitleController.dispose();
    _discountLabelController.dispose();
    _promoCodeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handlePublishOffer() {
    final bName = _businessNameController.text.trim();
    final title = _offerTitleController.text.trim();
    final discount = _discountLabelController.text.trim();
    final code = _promoCodeController.text.trim().toUpperCase();
    final desc = _descriptionController.text.trim();

    if (bName.isEmpty || title.isEmpty || discount.isEmpty || code.isEmpty) {
      setState(() {
        _adFormError = 'Please fill in all required business and promo fields.';
      });
      return;
    }

    final plan = widget.membershipPlans.firstWhere(
      (p) => p.id == _selectedPlanId,
      orElse: () => widget.membershipPlans[0],
    );

    final newOffer = PromotionalOffer(
      id: 'off-custom-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      businessName: bName,
      category: _offerCategory,
      city: _offerCity,
      discountLabel: discount,
      promoCode: code,
      description: desc.isNotEmpty ? desc : 'Exclusive deal on GO DUDE.',
      minSpendLKR: 1000,
      maxDiscountLKR: 500,
      validUntil: '2026-12-31',
      isSponsored: true,
      accentColor: '#0284c7',
    );

    widget.onPublishDemoOffer(newOffer, plan);

    setState(() {
      _adFormError = null;
      _publishedConfirmation = {
        'offer': newOffer,
        'plan': plan,
      };
      _businessNameController.clear();
      _offerTitleController.clear();
      _descriptionController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.offers.where((off) {
      if (_selectedCategory != 'All' && off.category != _selectedCategory) {
        return false;
      }
      if (_selectedCity != 'All' &&
          off.city != 'All Sri Lanka' &&
          off.city != _selectedCity) {
        return false;
      }
      final q = _searchController.text.trim().toLowerCase();
      if (q.isNotEmpty) {
        return off.title.toLowerCase().contains(q) ||
            off.businessName.toLowerCase().contains(q) ||
            off.promoCode.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // HEADER (NAVY FROSTED)
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
                  const Text(
                    'Exclusive Offers & Deals',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    'Sri Lanka discounts, food vouchers & merchant ad platform',
                    style: TextStyle(
                      color: AppTheme.skyBlue,
                      fontSize: 11,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Segmented Tabs: Browse vs Merchant
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _activeTab = 'browse';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _activeTab == 'browse'
                                    ? AppTheme.primaryBlue
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Browse Offers',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _activeTab = 'advertise';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _activeTab == 'advertise'
                                    ? AppTheme.savingsOrange
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Merchant Portal & Ad Plans',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // TAB 1: BROWSE OFFERS
          if (_activeTab == 'browse') ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Search
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.slate200),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(fontSize: 12),
                      decoration: const InputDecoration(
                        hintText: 'Search promo code or business...',
                        hintStyle: TextStyle(fontSize: 11, color: AppTheme.slate400),
                        prefixIcon: Icon(Icons.search, size: 18, color: AppTheme.slate400),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Category Filters
                  SizedBox(
                    height: 30,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, index) => const SizedBox(width: 6),
                      itemBuilder: (context, idx) {
                        final cat = _categories[idx];
                        final isSel = _selectedCategory == cat;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedCategory = cat;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? AppTheme.primaryBlue
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: isSel
                                    ? AppTheme.primaryBlue
                                    : AppTheme.slate200,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSel ? Colors.white : AppTheme.slate700,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 6),

                  // City Filters
                  SizedBox(
                    height: 28,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _cities.length,
                      separatorBuilder: (_, index) => const SizedBox(width: 6),
                      itemBuilder: (context, idx) {
                        final city = _cities[idx];
                        final isSel = _selectedCity == city;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedCity = city;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? const Color(0xFFEFF6FF)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSel
                                    ? AppTheme.primaryBlue
                                    : AppTheme.slate200,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              city,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSel
                                    ? AppTheme.primaryBlue
                                    : AppTheme.slate600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Offers Cards
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final off = filtered[idx];
                      final isApplied = widget.appliedOffer?.id == off.id;

                      return Container(
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
                                Row(
                                  children: [
                                    Text(
                                      off.businessName,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.primaryBlue,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '· ${off.city}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.slate500,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    off.discountLabel,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFB45309),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              off.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.slate900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              off.description,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.slate600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.slate100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: AppTheme.slate300,
                                        style: BorderStyle.solid),
                                  ),
                                  child: Text(
                                    'Code: ${off.promoCode}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'monospace',
                                      color: AppTheme.slate900,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => widget.onClaimOffer(off),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isApplied
                                        ? AppTheme.foodGreen
                                        : AppTheme.primaryBlue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    isApplied ? 'Applied ✓' : 'Claim Voucher',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ] else ...[
            // TAB 2: MERCHANT PORTAL & MEMBERSHIP PLANS
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'GO DUDE Merchant Advertising Plans',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.slate900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Promote your Sri Lankan restaurant, hotel, or retail store to hundreds of thousands of active customers.',
                    style: TextStyle(fontSize: 11, color: AppTheme.slate600),
                  ),
                  const SizedBox(height: 12),

                  // Plans cards
                  Column(
                    children: widget.membershipPlans.map((plan) {
                      final isSel = _selectedPlanId == plan.id;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedPlanId = plan.id;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSel
                                ? const Color(0xFFEFF6FF)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSel
                                  ? AppTheme.primaryBlue
                                  : AppTheme.slate200,
                              width: isSel ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    plan.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.slate900,
                                    ),
                                  ),
                                  Text(
                                    'LKR ${formatLKR(plan.monthlyPriceLKR)}/mo',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Reach: ${plan.reachEstimate} · ${plan.adSlotsPerMonth} Ad Slots',
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.foodGreen),
                              ),
                              const SizedBox(height: 6),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: plan.features.map((f) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.check,
                                            size: 12,
                                            color: AppTheme.foodGreen),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            f,
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: AppTheme.slate700),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Interactive Ad Form
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.slate200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Publish a Demo Promo Offer',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.slate900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _businessNameController,
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            labelText: 'Business Name (e.g. Upali’s by Nawaloka)',
                            labelStyle: const TextStyle(fontSize: 11),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _offerTitleController,
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            labelText: 'Offer Title (e.g. 25% Off Sunday Curry Feast)',
                            labelStyle: const TextStyle(fontSize: 11),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _discountLabelController,
                                style: const TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                  labelText: 'Discount Label',
                                  labelStyle: const TextStyle(fontSize: 11),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _promoCodeController,
                                style: const TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                  labelText: 'Promo Code',
                                  labelStyle: const TextStyle(fontSize: 11),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _descriptionController,
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            labelText: 'Short Description',
                            labelStyle: const TextStyle(fontSize: 11),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        if (_adFormError != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            _adFormError!,
                            style: const TextStyle(
                                color: Colors.red,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _handlePublishOffer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.savingsOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Publish Offer Live to App',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_publishedConfirmation != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'Offer published successfully! Switch to "Browse Offers" tab to see it live.',
                        style: const TextStyle(
                          color: Color(0xFF166534),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
