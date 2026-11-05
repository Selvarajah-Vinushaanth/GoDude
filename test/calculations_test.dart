import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/types/godude.dart';
import 'package:my_first_app/utils/calculations.dart';

void main() {
  const sampleRestaurants = [
    Restaurant(
      id: 'r1',
      name: 'Colombo Spice House',
      tagline: 'Authentic Kottu',
      city: 'Colombo',
      address: 'Galle Rd',
      rating: 4.5,
      reviewCount: 210,
      deliveryTimeMins: 30,
      deliveryFeeLKR: 180,
      distanceKm: 2.4,
      isOpen: true,
      cuisineTags: ['Sri Lankan', 'Kottu'],
      bannerColor: '#16a34a',
      illustrationType: 'kottu',
    ),
    Restaurant(
      id: 'r2',
      name: 'Hotel de Pilawoos',
      tagline: 'Legendary Kottu & Cheese Kottu',
      city: 'Colombo',
      address: 'Bambalapitiya',
      rating: 4.9,
      reviewCount: 1450,
      deliveryTimeMins: 22,
      deliveryFeeLKR: 150,
      distanceKm: 1.6,
      isOpen: true,
      cuisineTags: ['Sri Lankan', 'Kottu', 'Late Night'],
      bannerColor: '#15803d',
      illustrationType: 'cheese_kottu',
    ),
  ];

  const sampleFoods = [
    FoodItem(
      id: 'f1',
      restaurantId: 'r1',
      name: 'Roast Chicken Kottu',
      category: 'Kottu & Roti',
      description: 'Godamba roti chopped on hot iron griddle',
      priceLKR: 1150,
      largePriceDeltaLKR: 350,
      prepTimeMins: 18,
      calories: 780,
      illustrationType: 'kottu',
      availableAddons: [
        FoodCustomizationOption(
            id: 'a1', label: 'Extra Cheese', priceLKR: 250),
      ],
    ),
    FoodItem(
      id: 'f2',
      restaurantId: 'r2',
      name: 'Special Chicken Kottu',
      category: 'Kottu & Roti',
      description: 'Signature Bambalapitiya style chicken kottu',
      priceLKR: 1250,
      largePriceDeltaLKR: 400,
      prepTimeMins: 15,
      calories: 820,
      illustrationType: 'kottu',
      availableAddons: [],
    ),
  ];

  test('10% savings allocation calculates exact 10% credit and 90% settlement',
      () {
    final res = calculateSavingsAllocation(1000);
    expect(res.eligibleAmountLKR, 1000);
    expect(res.savingsCreditLKR, 100);
    expect(res.remainingSettlementLKR, 900);
  });

  test(
      'searchRestaurantsByFood filters by food item and sorts highest rating first',
      () {
    final results = searchRestaurantsByFood(
      'Chicken Kottu',
      sampleRestaurants,
      sampleFoods,
      sortBy: RestaurantSortOption.rating,
    );
    expect(results.length, 2);
    expect(results[0].restaurant.id, 'r2');
    expect(results[1].restaurant.id, 'r1');
  });

  test('calculateCustomizedFoodUnitPrice adds portion delta and add-on prices',
      () {
    final unitPrice = calculateCustomizedFoodUnitPrice(
        sampleFoods[0], 'Large', [250, 150]);
    // 1150 + 350 (Large) + 400 (addons) = 1900
    expect(unitPrice, 1900);
  });

  test(
      'calculateCartTotals computes subtotal, discount, delivery fee, and 10% savings',
      () {
    final cart = [
      CartItem(
        cartItemId: 'c1',
        foodItem: sampleFoods[0],
        restaurantId: 'r1',
        restaurantName: 'Colombo Spice House',
        quantity: 2,
        portion: 'Regular',
        spiceLevel: 'Medium Spicy',
        selectedAddons: [],
        specialInstructions: '',
        unitTotalLKR: 1000,
      ),
    ];

    final totals = calculateCartTotals(cart, 200, null);
    expect(totals.foodSubtotalLKR, 2000);
    expect(totals.deliveryFeeLKR, 200);
    expect(totals.finalPayableLKR, 2200);
    expect(totals.eligibleForSavingsLKR, 2000);
    expect(totals.savingsAllocationLKR, 200);
    expect(totals.netMerchantSettlementLKR, 1800);
  });

  test('calculatePointToPointFare and flexible ride running fare compute accurate fares',
      () {
    const tuktuk = VehicleOption(
      id: VehicleTypeId.tuktuk,
      name: 'Three-Wheeler (Tuk-Tuk)',
      sinhalaTamilSub: 'ත්‍රීවීලර්',
      description: 'Iconic city breeze ride',
      capacity: '3 Passengers',
      baseFareLKR: 150,
      perKmRateLKR: 95,
      perMinWaitLKR: 10,
      etaMins: 3,
    );

    // 5km ride: 150 base (includes first 1km) + 4km * 95 = 150 + 380 = 530
    final p2p = calculatePointToPointFare(tuktuk, 5, false);
    expect(p2p.totalFareLKR, 530);
    expect(p2p.savingsAllocationLKR, 53);

    // Flexible ride: 3.0 km travelled, 120 seconds (2 mins) -> 150 + 285 + 20 = 455
    final flex = calculateFlexibleRideRunningFare(tuktuk, 3.0, 120);
    expect(flex.runningTotalLKR, 455);
    expect(flex.estimatedSavingsLKR, 46);
  });

  test('validateMonthlyWithdrawal enforces monthly limit and balance cap', () {
    final blocked =
        validateMonthlyWithdrawal(500, 2000, '2026-10', '2026-10');
    expect(blocked.valid, false);

    final overBalance =
        validateMonthlyWithdrawal(3000, 2000, '2026-09', '2026-10');
    expect(overBalance.valid, false);

    final allowed =
        validateMonthlyWithdrawal(1000, 2000, '2026-09', '2026-10');
    expect(allowed.valid, true);
  });

  test('summarizeSavingsLedger aggregates credits, withdrawals, and donations',
      () {
    final summary = summarizeSavingsLedger(
      [
        const SavingsTransaction(
          id: 't1',
          type: 'credit_order',
          title: '10% Savings Credit',
          referenceId: 'ORD-1',
          date: '2026-10-18',
          amountLKR: 500,
          status: 'Completed',
        ),
        const SavingsTransaction(
          id: 't2',
          type: 'donation_charity',
          title: 'Suwa Seriya Donation',
          referenceId: 'DON-1',
          date: '2026-10-19',
          amountLKR: -200,
          status: 'Completed',
        ),
      ],
      '2026-10',
    );

    expect(summary.totalBalanceLKR, 300);
    expect(summary.currentMonthSavedLKR, 500);
    expect(summary.totalDonatedLKR, 200);
  });
}
