
enum MainTab { home, activity, offers, profile }

enum ActiveServiceView { none, foods, pickdrop, savings }

enum VehicleTypeId { bike, tuktuk, car }

class SriLankaLocation {
  final String id;
  final String name;
  final String area;
  final String city; // 'Colombo' | 'Kandy' | 'Galle' | 'Negombo'
  final String address;
  final double lat;
  final double lng;

  const SriLankaLocation({
    required this.id,
    required this.name,
    required this.area,
    required this.city,
    required this.address,
    required this.lat,
    required this.lng,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'area': area,
        'city': city,
        'address': address,
        'lat': lat,
        'lng': lng,
      };

  factory SriLankaLocation.fromJson(Map<String, dynamic> json) =>
      SriLankaLocation(
        id: json['id'] as String,
        name: json['name'] as String,
        area: json['area'] as String,
        city: json['city'] as String,
        address: json['address'] as String,
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
      );
}

class FoodCustomizationOption {
  final String id;
  final String label;
  final int priceLKR;

  const FoodCustomizationOption({
    required this.id,
    required this.label,
    required this.priceLKR,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'priceLKR': priceLKR,
      };

  factory FoodCustomizationOption.fromJson(Map<String, dynamic> json) =>
      FoodCustomizationOption(
        id: json['id'] as String,
        label: json['label'] as String,
        priceLKR: json['priceLKR'] as int,
      );
}

class FoodItem {
  final String id;
  final String restaurantId;
  final String name;
  final String category; // 'Kottu & Roti' | 'Biriyani & Rice' | etc.
  final String description;
  final int priceLKR;
  final int largePriceDeltaLKR;
  final bool isPopular;
  final bool isSpicy;
  final int prepTimeMins;
  final int calories;
  final String illustrationType;
  final List<FoodCustomizationOption> availableAddons;

  const FoodItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.category,
    required this.description,
    required this.priceLKR,
    required this.largePriceDeltaLKR,
    this.isPopular = false,
    this.isSpicy = false,
    required this.prepTimeMins,
    required this.calories,
    required this.illustrationType,
    required this.availableAddons,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'restaurantId': restaurantId,
        'name': name,
        'category': category,
        'description': description,
        'priceLKR': priceLKR,
        'largePriceDeltaLKR': largePriceDeltaLKR,
        'isPopular': isPopular,
        'isSpicy': isSpicy,
        'prepTimeMins': prepTimeMins,
        'calories': calories,
        'illustrationType': illustrationType,
        'availableAddons': availableAddons.map((a) => a.toJson()).toList(),
      };

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
        id: json['id'] as String,
        restaurantId: json['restaurantId'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        description: json['description'] as String,
        priceLKR: json['priceLKR'] as int,
        largePriceDeltaLKR: json['largePriceDeltaLKR'] as int,
        isPopular: json['isPopular'] as bool? ?? false,
        isSpicy: json['isSpicy'] as bool? ?? false,
        prepTimeMins: json['prepTimeMins'] as int,
        calories: json['calories'] as int,
        illustrationType: json['illustrationType'] as String,
        availableAddons: (json['availableAddons'] as List<dynamic>? ?? [])
            .map((e) =>
                FoodCustomizationOption.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class Restaurant {
  final String id;
  final String name;
  final String tagline;
  final String city;
  final String address;
  final double rating;
  final int reviewCount;
  final int deliveryTimeMins;
  final int deliveryFeeLKR;
  final double distanceKm;
  final bool isOpen;
  final String? featuredPromo;
  final List<String> cuisineTags;
  final String bannerColor;
  final String illustrationType;

  const Restaurant({
    required this.id,
    required this.name,
    required this.tagline,
    required this.city,
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.deliveryTimeMins,
    required this.deliveryFeeLKR,
    required this.distanceKm,
    required this.isOpen,
    this.featuredPromo,
    required this.cuisineTags,
    required this.bannerColor,
    required this.illustrationType,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'tagline': tagline,
        'city': city,
        'address': address,
        'rating': rating,
        'reviewCount': reviewCount,
        'deliveryTimeMins': deliveryTimeMins,
        'deliveryFeeLKR': deliveryFeeLKR,
        'distanceKm': distanceKm,
        'isOpen': isOpen,
        'featuredPromo': featuredPromo,
        'cuisineTags': cuisineTags,
        'bannerColor': bannerColor,
        'illustrationType': illustrationType,
      };

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        id: json['id'] as String,
        name: json['name'] as String,
        tagline: json['tagline'] as String,
        city: json['city'] as String,
        address: json['address'] as String,
        rating: (json['rating'] as num).toDouble(),
        reviewCount: json['reviewCount'] as int,
        deliveryTimeMins: json['deliveryTimeMins'] as int,
        deliveryFeeLKR: json['deliveryFeeLKR'] as int,
        distanceKm: (json['distanceKm'] as num).toDouble(),
        isOpen: json['isOpen'] as bool? ?? true,
        featuredPromo: json['featuredPromo'] as String?,
        cuisineTags: (json['cuisineTags'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        bannerColor: json['bannerColor'] as String? ?? '#0f172a',
        illustrationType: json['illustrationType'] as String? ?? 'kottu',
      );
}

class CartItem {
  final String cartItemId;
  final FoodItem foodItem;
  final String restaurantId;
  final String restaurantName;
  int quantity;
  final String portion; // 'Regular' | 'Large'
  final String spiceLevel; // 'Mild' | 'Medium Spicy' | 'Sri Lankan Fiery'
  final List<FoodCustomizationOption> selectedAddons;
  final String specialInstructions;
  final int unitTotalLKR;

  CartItem({
    required this.cartItemId,
    required this.foodItem,
    required this.restaurantId,
    required this.restaurantName,
    required this.quantity,
    required this.portion,
    required this.spiceLevel,
    required this.selectedAddons,
    required this.specialInstructions,
    required this.unitTotalLKR,
  });

  Map<String, dynamic> toJson() => {
        'cartItemId': cartItemId,
        'foodItem': foodItem.toJson(),
        'restaurantId': restaurantId,
        'restaurantName': restaurantName,
        'quantity': quantity,
        'portion': portion,
        'spiceLevel': spiceLevel,
        'selectedAddons': selectedAddons.map((a) => a.toJson()).toList(),
        'specialInstructions': specialInstructions,
        'unitTotalLKR': unitTotalLKR,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        cartItemId: json['cartItemId'] as String,
        foodItem: FoodItem.fromJson(json['foodItem'] as Map<String, dynamic>),
        restaurantId: json['restaurantId'] as String,
        restaurantName: json['restaurantName'] as String,
        quantity: json['quantity'] as int,
        portion: json['portion'] as String,
        spiceLevel: json['spiceLevel'] as String,
        selectedAddons: (json['selectedAddons'] as List<dynamic>? ?? [])
            .map((e) =>
                FoodCustomizationOption.fromJson(e as Map<String, dynamic>))
            .toList(),
        specialInstructions: json['specialInstructions'] as String? ?? '',
        unitTotalLKR: json['unitTotalLKR'] as int,
      );
}

class VehicleOption {
  final VehicleTypeId id;
  final String name;
  final String sinhalaTamilSub;
  final String description;
  final String capacity;
  final int baseFareLKR;
  final int perKmRateLKR;
  final int perMinWaitLKR;
  final int etaMins;

  const VehicleOption({
    required this.id,
    required this.name,
    required this.sinhalaTamilSub,
    required this.description,
    required this.capacity,
    required this.baseFareLKR,
    required this.perKmRateLKR,
    required this.perMinWaitLKR,
    required this.etaMins,
  });
}

class DriverOrRider {
  final String name;
  final String phone;
  final String vehicleName;
  final String plateNumber;
  final double rating;

  const DriverOrRider({
    required this.name,
    required this.phone,
    required this.vehicleName,
    required this.plateNumber,
    required this.rating,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'vehicleName': vehicleName,
        'plateNumber': plateNumber,
        'rating': rating,
      };

  factory DriverOrRider.fromJson(Map<String, dynamic> json) => DriverOrRider(
        name: json['name'] as String,
        phone: json['phone'] as String,
        vehicleName: json['vehicleName'] as String,
        plateNumber: json['plateNumber'] as String,
        rating: (json['rating'] as num).toDouble(),
      );
}

class ActivityBooking {
  final String id;
  final String serviceType; // 'Food Delivery' | 'Ride Booking' | 'Parcel Delivery' | 'Flexible Ride'
  final String title;
  final String subtitle;
  final String createdAt;
  String status; // 'Confirmed', 'Preparing', 'Rider Assigned', 'On the Way', 'Delivered', 'Completed', 'Cancelled'
  final String paymentMethod;
  String paymentStatus; // 'Paid (Verified)' | 'Settled' | 'Refunded'
  final String pickupAddress;
  final String destinationAddress;
  final int subtotalLKR;
  final int deliveryOrServiceFeeLKR;
  final int discountLKR;
  final int totalPaidLKR;
  final int savingsEarnedLKR;
  int etaMins;
  final double distanceKm;
  final DriverOrRider? driverOrRider;
  final List<String>? itemsSummary;
  int progressStep; // 1 to 5

  ActivityBooking({
    required this.id,
    required this.serviceType,
    required this.title,
    required this.subtitle,
    required this.createdAt,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.subtotalLKR,
    required this.deliveryOrServiceFeeLKR,
    required this.discountLKR,
    required this.totalPaidLKR,
    required this.savingsEarnedLKR,
    required this.etaMins,
    required this.distanceKm,
    this.driverOrRider,
    this.itemsSummary,
    required this.progressStep,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'serviceType': serviceType,
        'title': title,
        'subtitle': subtitle,
        'createdAt': createdAt,
        'status': status,
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentStatus,
        'pickupAddress': pickupAddress,
        'destinationAddress': destinationAddress,
        'subtotalLKR': subtotalLKR,
        'deliveryOrServiceFeeLKR': deliveryOrServiceFeeLKR,
        'discountLKR': discountLKR,
        'totalPaidLKR': totalPaidLKR,
        'savingsEarnedLKR': savingsEarnedLKR,
        'etaMins': etaMins,
        'distanceKm': distanceKm,
        'driverOrRider': driverOrRider?.toJson(),
        'itemsSummary': itemsSummary,
        'progressStep': progressStep,
      };

  factory ActivityBooking.fromJson(Map<String, dynamic> json) => ActivityBooking(
        id: json['id'] as String,
        serviceType: json['serviceType'] as String,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String,
        createdAt: json['createdAt'] as String,
        status: json['status'] as String,
        paymentMethod: json['paymentMethod'] as String,
        paymentStatus: json['paymentStatus'] as String,
        pickupAddress: json['pickupAddress'] as String,
        destinationAddress: json['destinationAddress'] as String,
        subtotalLKR: json['subtotalLKR'] as int,
        deliveryOrServiceFeeLKR: json['deliveryOrServiceFeeLKR'] as int,
        discountLKR: json['discountLKR'] as int,
        totalPaidLKR: json['totalPaidLKR'] as int,
        savingsEarnedLKR: json['savingsEarnedLKR'] as int,
        etaMins: json['etaMins'] as int,
        distanceKm: (json['distanceKm'] as num).toDouble(),
        driverOrRider: json['driverOrRider'] != null
            ? DriverOrRider.fromJson(
                json['driverOrRider'] as Map<String, dynamic>)
            : null,
        itemsSummary: (json['itemsSummary'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
        progressStep: json['progressStep'] as int? ?? 1,
      );
}

class SavingsTransaction {
  final String id;
  final String type; // 'credit_order' | 'credit_ride' | 'withdrawal_bank' | 'donation_charity'
  final String title;
  final String referenceId;
  final String date;
  final int? eligibleBaseAmountLKR;
  final int amountLKR; // positive for credit, negative for withdrawal/donation
  final String status; // 'Completed' | 'Processing' | 'Pending'
  final String? recipientDetails;

  const SavingsTransaction({
    required this.id,
    required this.type,
    required this.title,
    required this.referenceId,
    required this.date,
    this.eligibleBaseAmountLKR,
    required this.amountLKR,
    required this.status,
    this.recipientDetails,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'referenceId': referenceId,
        'date': date,
        'eligibleBaseAmountLKR': eligibleBaseAmountLKR,
        'amountLKR': amountLKR,
        'status': status,
        'recipientDetails': recipientDetails,
      };

  factory SavingsTransaction.fromJson(Map<String, dynamic> json) =>
      SavingsTransaction(
        id: json['id'] as String,
        type: json['type'] as String,
        title: json['title'] as String,
        referenceId: json['referenceId'] as String,
        date: json['date'] as String,
        eligibleBaseAmountLKR: json['eligibleBaseAmountLKR'] as int?,
        amountLKR: json['amountLKR'] as int,
        status: json['status'] as String,
        recipientDetails: json['recipientDetails'] as String?,
      );
}

class CharityOrganization {
  final String id;
  final String name;
  final String category;
  final String registrationNo;
  final String summary;
  final String impactMetric;
  final int totalRaisedOnPlatformLKR;
  final bool verifiedBadge;

  const CharityOrganization({
    required this.id,
    required this.name,
    required this.category,
    required this.registrationNo,
    required this.summary,
    required this.impactMetric,
    required this.totalRaisedOnPlatformLKR,
    required this.verifiedBadge,
  });
}

class PromotionalOffer {
  final String id;
  final String title;
  final String businessName;
  final String category; // 'Restaurants' | 'Hotels & Stays' | 'Local Businesses' | 'Ride Deals'
  final String city; // 'All Sri Lanka' | 'Colombo' | 'Kandy' | 'Galle' | 'Negombo'
  final String discountLabel;
  final String promoCode;
  final String description;
  final int minSpendLKR;
  final int maxDiscountLKR;
  final String validUntil;
  final bool isSponsored;
  final String accentColor;

  const PromotionalOffer({
    required this.id,
    required this.title,
    required this.businessName,
    required this.category,
    required this.city,
    required this.discountLabel,
    required this.promoCode,
    required this.description,
    required this.minSpendLKR,
    required this.maxDiscountLKR,
    required this.validUntil,
    this.isSponsored = false,
    required this.accentColor,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'businessName': businessName,
        'category': category,
        'city': city,
        'discountLabel': discountLabel,
        'promoCode': promoCode,
        'description': description,
        'minSpendLKR': minSpendLKR,
        'maxDiscountLKR': maxDiscountLKR,
        'validUntil': validUntil,
        'isSponsored': isSponsored,
        'accentColor': accentColor,
      };

  factory PromotionalOffer.fromJson(Map<String, dynamic> json) =>
      PromotionalOffer(
        id: json['id'] as String,
        title: json['title'] as String,
        businessName: json['businessName'] as String,
        category: json['category'] as String,
        city: json['city'] as String,
        discountLabel: json['discountLabel'] as String,
        promoCode: json['promoCode'] as String,
        description: json['description'] as String,
        minSpendLKR: json['minSpendLKR'] as int,
        maxDiscountLKR: json['maxDiscountLKR'] as int,
        validUntil: json['validUntil'] as String,
        isSponsored: json['isSponsored'] as bool? ?? false,
        accentColor: json['accentColor'] as String,
      );
}

class BusinessMembershipPlan {
  final String id;
  final String name;
  final int monthlyPriceLKR;
  final int adSlotsPerMonth;
  final String reachEstimate;
  final List<String> features;
  final bool recommended;

  const BusinessMembershipPlan({
    required this.id,
    required this.name,
    required this.monthlyPriceLKR,
    required this.adSlotsPerMonth,
    required this.reachEstimate,
    required this.features,
    this.recommended = false,
  });
}

class SavedAddress {
  final String id;
  final String label; // 'Home' | 'Work' | 'Other'
  final String addressLine;
  final String city;
  final String landmark;

  const SavedAddress({
    required this.id,
    required this.label,
    required this.addressLine,
    required this.city,
    required this.landmark,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'addressLine': addressLine,
        'city': city,
        'landmark': landmark,
      };

  factory SavedAddress.fromJson(Map<String, dynamic> json) => SavedAddress(
        id: json['id'] as String,
        label: json['label'] as String,
        addressLine: json['addressLine'] as String,
        city: json['city'] as String,
        landmark: json['landmark'] as String,
      );
}

class BankAccount {
  final String id;
  final String bankName;
  final String branchName;
  final String accountHolder;
  final String accountNumberMasked;
  final bool isVerified;

  const BankAccount({
    required this.id,
    required this.bankName,
    required this.branchName,
    required this.accountHolder,
    required this.accountNumberMasked,
    this.isVerified = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'bankName': bankName,
        'branchName': branchName,
        'accountHolder': accountHolder,
        'accountNumberMasked': accountNumberMasked,
        'isVerified': isVerified,
      };

  factory BankAccount.fromJson(Map<String, dynamic> json) => BankAccount(
        id: json['id'] as String,
        bankName: json['bankName'] as String,
        branchName: json['branchName'] as String,
        accountHolder: json['accountHolder'] as String,
        accountNumberMasked: json['accountNumberMasked'] as String,
        isVerified: json['isVerified'] as bool? ?? true,
      );
}

class CustomerProfile {
  String accountId;
  String fullName;
  String phone;
  String email;
  String memberSince;
  int monthsActive;
  double rating;
  String selectedLocationId;
  List<SavedAddress> savedAddresses;
  List<BankAccount> bankAccounts;
  String? lastWithdrawalMonth;
  bool notificationsEnabled;
  bool locationConsentEnabled;

  CustomerProfile({
    required this.accountId,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.memberSince,
    required this.monthsActive,
    required this.rating,
    required this.selectedLocationId,
    required this.savedAddresses,
    required this.bankAccounts,
    this.lastWithdrawalMonth,
    this.notificationsEnabled = true,
    this.locationConsentEnabled = true,
  });

  Map<String, dynamic> toJson() => {
        'accountId': accountId,
        'fullName': fullName,
        'phone': phone,
        'email': email,
        'memberSince': memberSince,
        'monthsActive': monthsActive,
        'rating': rating,
        'selectedLocationId': selectedLocationId,
        'savedAddresses': savedAddresses.map((a) => a.toJson()).toList(),
        'bankAccounts': bankAccounts.map((b) => b.toJson()).toList(),
        'lastWithdrawalMonth': lastWithdrawalMonth,
        'notificationsEnabled': notificationsEnabled,
        'locationConsentEnabled': locationConsentEnabled,
      };

  factory CustomerProfile.fromJson(Map<String, dynamic> json) => CustomerProfile(
        accountId: json['accountId'] as String,
        fullName: json['fullName'] as String,
        phone: json['phone'] as String,
        email: json['email'] as String,
        memberSince: json['memberSince'] as String,
        monthsActive: json['monthsActive'] as int,
        rating: (json['rating'] as num).toDouble(),
        selectedLocationId: json['selectedLocationId'] as String,
        savedAddresses: (json['savedAddresses'] as List<dynamic>? ?? [])
            .map((e) => SavedAddress.fromJson(e as Map<String, dynamic>))
            .toList(),
        bankAccounts: (json['bankAccounts'] as List<dynamic>? ?? [])
            .map((e) => BankAccount.fromJson(e as Map<String, dynamic>))
            .toList(),
        lastWithdrawalMonth: json['lastWithdrawalMonth'] as String?,
        notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
        locationConsentEnabled: json['locationConsentEnabled'] as bool? ?? true,
      );
}
