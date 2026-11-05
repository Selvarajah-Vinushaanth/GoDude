import 'dart:math' as math;
import '../types/godude.dart';

enum RestaurantSortOption { rating, deliveryTime, distance, price }

class MatchedRestaurantResult {
  final Restaurant restaurant;
  final List<FoodItem> matchingItems;
  final int lowestMatchingPriceLKR;

  const MatchedRestaurantResult({
    required this.restaurant,
    required this.matchingItems,
    required this.lowestMatchingPriceLKR,
  });
}

class SavingsAllocationResult {
  final int eligibleAmountLKR;
  final int savingsCreditLKR;
  final int remainingSettlementLKR;

  const SavingsAllocationResult({
    required this.eligibleAmountLKR,
    required this.savingsCreditLKR,
    required this.remainingSettlementLKR,
  });
}

class CartTotalsResult {
  final int foodSubtotalLKR;
  final int discountLKR;
  final int deliveryFeeLKR;
  final int finalPayableLKR;
  final int eligibleForSavingsLKR;
  final int savingsAllocationLKR;
  final int netMerchantSettlementLKR;

  const CartTotalsResult({
    required this.foodSubtotalLKR,
    required this.discountLKR,
    required this.deliveryFeeLKR,
    required this.finalPayableLKR,
    required this.eligibleForSavingsLKR,
    required this.savingsAllocationLKR,
    required this.netMerchantSettlementLKR,
  });
}

class RouteMetricsResult {
  final double distanceKm;
  final int estimatedMinutes;

  const RouteMetricsResult({
    required this.distanceKm,
    required this.estimatedMinutes,
  });
}

class PointToPointFareResult {
  final int baseFareLKR;
  final int distanceChargeLKR;
  final int parcelHandlingFeeLKR;
  final int totalFareLKR;
  final int savingsAllocationLKR;

  const PointToPointFareResult({
    required this.baseFareLKR,
    required this.distanceChargeLKR,
    required this.parcelHandlingFeeLKR,
    required this.totalFareLKR,
    required this.savingsAllocationLKR,
  });
}

class FlexibleRideFareResult {
  final int baseFareLKR;
  final int distanceFareLKR;
  final int timeChargeLKR;
  final int runningTotalLKR;
  final int estimatedSavingsLKR;

  const FlexibleRideFareResult({
    required this.baseFareLKR,
    required this.distanceFareLKR,
    required this.timeChargeLKR,
    required this.runningTotalLKR,
    required this.estimatedSavingsLKR,
  });
}

class SavingsLedgerSummary {
  final int totalBalanceLKR;
  final int currentMonthSavedLKR;
  final int totalWithdrawnLKR;
  final int totalDonatedLKR;

  const SavingsLedgerSummary({
    required this.totalBalanceLKR,
    required this.currentMonthSavedLKR,
    required this.totalWithdrawnLKR,
    required this.totalDonatedLKR,
  });
}

class WithdrawalValidationResult {
  final bool valid;
  final String? error;

  const WithdrawalValidationResult({
    required this.valid,
    this.error,
  });
}

/// Formats number with commas: e.g. 1500 -> "1,500"
String formatLKR(num amount) {
  final parts = amount.round().toString().split('');
  final buffer = StringBuffer();
  for (int i = 0; i < parts.length; i++) {
    if (i > 0 && (parts.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(parts[i]);
  }
  return buffer.toString();
}

/// Searches food items by query across all restaurants and returns matching restaurants
List<MatchedRestaurantResult> searchRestaurantsByFood(
  String query,
  List<Restaurant> restaurants,
  List<FoodItem> foodItems, {
  RestaurantSortOption sortBy = RestaurantSortOption.rating,
  String cityFilter = 'All',
}) {
  final normalizedQuery = query.trim().toLowerCase();
  final results = <MatchedRestaurantResult>[];

  for (final restaurant in restaurants) {
    if (cityFilter != 'All' && restaurant.city != cityFilter) {
      continue;
    }

    final restaurantMenu =
        foodItems.where((item) => item.restaurantId == restaurant.id).toList();

    final matchingItems = normalizedQuery.isNotEmpty
        ? restaurantMenu.where((item) {
            return item.name.toLowerCase().contains(normalizedQuery) ||
                item.category.toLowerCase().contains(normalizedQuery) ||
                item.description.toLowerCase().contains(normalizedQuery) ||
                restaurant.name.toLowerCase().contains(normalizedQuery) ||
                restaurant.cuisineTags
                    .any((t) => t.toLowerCase().contains(normalizedQuery));
          }).toList()
        : restaurantMenu;

    if (matchingItems.isNotEmpty) {
      int lowest = matchingItems.first.priceLKR;
      for (final i in matchingItems) {
        if (i.priceLKR < lowest) lowest = i.priceLKR;
      }
      results.add(
        MatchedRestaurantResult(
          restaurant: restaurant,
          matchingItems: matchingItems,
          lowestMatchingPriceLKR: lowest,
        ),
      );
    }
  }

  results.sort((a, b) {
    switch (sortBy) {
      case RestaurantSortOption.rating:
        if (b.restaurant.rating != a.restaurant.rating) {
          return b.restaurant.rating.compareTo(a.restaurant.rating);
        }
        return b.restaurant.reviewCount.compareTo(a.restaurant.reviewCount);
      case RestaurantSortOption.deliveryTime:
        return a.restaurant.deliveryTimeMins
            .compareTo(b.restaurant.deliveryTimeMins);
      case RestaurantSortOption.distance:
        return a.restaurant.distanceKm.compareTo(b.restaurant.distanceKm);
      case RestaurantSortOption.price:
        return a.lowestMatchingPriceLKR.compareTo(b.lowestMatchingPriceLKR);
    }
  });

  return results;
}

/// Calculates unit price for a customized food item
int calculateCustomizedFoodUnitPrice(
  FoodItem foodItem,
  String portion, // 'Regular' | 'Large'
  List<int> addonPricesLKR,
) {
  final base = foodItem.priceLKR +
      (portion == 'Large' ? foodItem.largePriceDeltaLKR : 0);
  final addonsTotal = addonPricesLKR.fold<int>(0, (sum, p) => sum + p);
  return base + addonsTotal;
}

/// Calculates the 10% automatic savings allocation from an eligible net amount.
SavingsAllocationResult calculateSavingsAllocation(num eligibleAmountLKR) {
  final cleanEligible = math.max(0, eligibleAmountLKR.round());
  final savingsCreditLKR = (cleanEligible * 0.1).round();
  final remainingSettlementLKR = cleanEligible - savingsCreditLKR;

  return SavingsAllocationResult(
    eligibleAmountLKR: cleanEligible,
    savingsCreditLKR: savingsCreditLKR,
    remainingSettlementLKR: remainingSettlementLKR,
  );
}

/// Calculates food cart checkout totals
CartTotalsResult calculateCartTotals(
  List<CartItem> cartItems,
  int deliveryFeeLKR, [
  PromotionalOffer? appliedOffer,
]) {
  final foodSubtotalLKR = cartItems.fold<int>(
    0,
    (sum, item) => sum + item.unitTotalLKR * item.quantity,
  );

  if (foodSubtotalLKR == 0) {
    return const CartTotalsResult(
      foodSubtotalLKR: 0,
      discountLKR: 0,
      deliveryFeeLKR: 0,
      finalPayableLKR: 0,
      eligibleForSavingsLKR: 0,
      savingsAllocationLKR: 0,
      netMerchantSettlementLKR: 0,
    );
  }

  int discountLKR = 0;
  if (appliedOffer != null && foodSubtotalLKR >= appliedOffer.minSpendLKR) {
    final regExp = RegExp(r'(\d+)%');
    final match = regExp.firstMatch(appliedOffer.discountLabel);
    if (match != null) {
      final pct = int.parse(match.group(1)!) / 100.0;
      final calcDiscount = (foodSubtotalLKR * pct).round();
      discountLKR = math.min(calcDiscount, appliedOffer.maxDiscountLKR);
    } else {
      discountLKR = math.min(appliedOffer.maxDiscountLKR, foodSubtotalLKR);
    }
  }

  final netFoodAmountLKR = math.max(0, foodSubtotalLKR - discountLKR);
  final finalPayableLKR = netFoodAmountLKR + deliveryFeeLKR;
  final allocation = calculateSavingsAllocation(netFoodAmountLKR);

  return CartTotalsResult(
    foodSubtotalLKR: foodSubtotalLKR,
    discountLKR: discountLKR,
    deliveryFeeLKR: deliveryFeeLKR,
    finalPayableLKR: finalPayableLKR,
    eligibleForSavingsLKR: allocation.eligibleAmountLKR,
    savingsAllocationLKR: allocation.savingsCreditLKR,
    netMerchantSettlementLKR: allocation.remainingSettlementLKR,
  );
}

/// Calculates realistic road distance and travel duration between two Sri Lankan locations
RouteMetricsResult calculateRouteMetrics(
  SriLankaLocation origin,
  SriLankaLocation destination,
) {
  if (origin.id == destination.id) {
    return const RouteMetricsResult(distanceKm: 1.5, estimatedMinutes: 6);
  }

  const r = 6371.0; // Earth radius km
  final dLat = (destination.lat - origin.lat) * math.pi / 180.0;
  final dLng = (destination.lng - origin.lng) * math.pi / 180.0;
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(origin.lat * math.pi / 180.0) *
          math.cos(destination.lat * math.pi / 180.0) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  final straightDistance = r * c;

  // Urban road winding factor 1.32x, minimum 1.8 km
  final rawDistance = math.max(1.8, straightDistance * 1.32);
  final distanceKm = double.parse(rawDistance.toStringAsFixed(1));
  final estimatedMinutes = math.max(5, ((distanceKm / 24.0) * 60 + 4).round());

  return RouteMetricsResult(
    distanceKm: distanceKm,
    estimatedMinutes: estimatedMinutes,
  );
}

/// Calculates point-to-point ride or parcel fare
PointToPointFareResult calculatePointToPointFare(
  VehicleOption vehicle,
  double distanceKm, [
  bool isParcelDelivery = false,
]) {
  final baseFareLKR = vehicle.baseFareLKR;
  final billableKm = math.max(0.0, distanceKm - 1.0);
  final distanceChargeLKR = (billableKm * vehicle.perKmRateLKR).round();
  final parcelHandlingFeeLKR = isParcelDelivery ? 80 : 0;

  final totalFareLKR = baseFareLKR + distanceChargeLKR + parcelHandlingFeeLKR;
  final eligibleBase = baseFareLKR + distanceChargeLKR;
  final allocation = calculateSavingsAllocation(eligibleBase);

  return PointToPointFareResult(
    baseFareLKR: baseFareLKR,
    distanceChargeLKR: distanceChargeLKR,
    parcelHandlingFeeLKR: parcelHandlingFeeLKR,
    totalFareLKR: totalFareLKR,
    savingsAllocationLKR: allocation.savingsCreditLKR,
  );
}

/// Calculates running fare for Mode Two: Flexible Distance-Based Ride
FlexibleRideFareResult calculateFlexibleRideRunningFare(
  VehicleOption vehicle,
  double travelledKm,
  int elapsedSeconds,
) {
  final baseFareLKR = vehicle.baseFareLKR;
  final distanceFareLKR =
      (math.max(0.0, travelledKm) * vehicle.perKmRateLKR).round();
  final elapsedMinutes = elapsedSeconds ~/ 60;
  final timeChargeLKR = elapsedMinutes * vehicle.perMinWaitLKR;
  final runningTotalLKR = baseFareLKR + distanceFareLKR + timeChargeLKR;
  final allocation = calculateSavingsAllocation(runningTotalLKR);

  return FlexibleRideFareResult(
    baseFareLKR: baseFareLKR,
    distanceFareLKR: distanceFareLKR,
    timeChargeLKR: timeChargeLKR,
    runningTotalLKR: runningTotalLKR,
    estimatedSavingsLKR: allocation.savingsCreditLKR,
  );
}

/// Summarizes the customer's savings ledger
SavingsLedgerSummary summarizeSavingsLedger(
  List<SavingsTransaction> transactions, [
  String currentYearMonth = '2026-10',
]) {
  int totalBalanceLKR = 0;
  int currentMonthSavedLKR = 0;
  int totalWithdrawnLKR = 0;
  int totalDonatedLKR = 0;

  for (final tx in transactions) {
    totalBalanceLKR += tx.amountLKR;

    if (tx.type == 'credit_order' || tx.type == 'credit_ride') {
      if (tx.date.startsWith(currentYearMonth)) {
        currentMonthSavedLKR += tx.amountLKR;
      }
    } else if (tx.type == 'withdrawal_bank') {
      totalWithdrawnLKR += tx.amountLKR.abs();
    } else if (tx.type == 'donation_charity') {
      totalDonatedLKR += tx.amountLKR.abs();
    }
  }

  return SavingsLedgerSummary(
    totalBalanceLKR: math.max(0, totalBalanceLKR),
    currentMonthSavedLKR: currentMonthSavedLKR,
    totalWithdrawnLKR: totalWithdrawnLKR,
    totalDonatedLKR: totalDonatedLKR,
  );
}

/// Validates whether a customer can withdraw savings to their bank account
WithdrawalValidationResult validateMonthlyWithdrawal(
  num requestedAmountLKR,
  int availableBalanceLKR,
  String? lastWithdrawalMonth, [
  String currentYearMonth = '2026-10',
]) {
  if (lastWithdrawalMonth == currentYearMonth) {
    return const WithdrawalValidationResult(
      valid: false,
      error:
          'Monthly withdrawal limit reached. GO DUDE allows one bank withdrawal per calendar month. Your next eligible withdrawal opens on the 1st of next month.',
    );
  }

  if (requestedAmountLKR < 200) {
    return const WithdrawalValidationResult(
      valid: false,
      error: 'Minimum bank withdrawal amount is LKR 200.',
    );
  }

  if (requestedAmountLKR > availableBalanceLKR) {
    return WithdrawalValidationResult(
      valid: false,
      error:
          'Requested amount exceeds your available savings balance of LKR ${formatLKR(availableBalanceLKR)}.',
    );
  }

  return const WithdrawalValidationResult(valid: true);
}
