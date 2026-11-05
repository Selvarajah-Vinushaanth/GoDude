import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../types/godude.dart';
import '../theme/app_theme.dart';
import '../utils/calculations.dart';
import '../components/visual_assets.dart';

class PickDropView extends StatefulWidget {
  final String initialMode; // 'p2p' | 'flexible'
  final bool initialIsParcel;
  final List<SriLankaLocation> locations;
  final SriLankaLocation currentLocation;
  final List<VehicleOption> vehicles;
  final Function(
    ActivityBooking booking,
    int savingsCreditLKR,
    int eligibleBaseLKR,
  ) onCompleteRideBooking;
  final VoidCallback onBackHome;
  final VoidCallback onGoToActivity;

  const PickDropView({
    super.key,
    this.initialMode = 'p2p',
    this.initialIsParcel = false,
    required this.locations,
    required this.currentLocation,
    required this.vehicles,
    required this.onCompleteRideBooking,
    required this.onBackHome,
    required this.onGoToActivity,
  });

  @override
  State<PickDropView> createState() => _PickDropViewState();
}

class _PickDropViewState extends State<PickDropView> {
  late String _bookingMode; // 'p2p' | 'flexible'
  late bool _isParcel;
  late String _originId;
  late String _destinationId;
  late VehicleTypeId _selectedVehicleId;
  final TextEditingController _parcelNoteController = TextEditingController(
    text: 'Fragile package · Call recipient upon arrival',
  );
  String _paymentMethod = 'Visa •••• 4242';
  // 'idle' -> 'driver_assigned' -> 'in_progress' -> 'trip_ended_review'
  String _flexStage = 'idle';
  double _flexTravelledKm = 0.0;
  int _flexElapsedSec = 0;
  Timer? _flexTimer;

  bool _isConfirmingPayment = false;
  ActivityBooking? _completedBookingReceipt;

  @override
  void initState() {
    super.initState();
    _bookingMode = widget.initialMode;
    _isParcel = widget.initialIsParcel;
    _originId = widget.currentLocation.id;
    _destinationId = widget.locations
        .firstWhere((l) => l.id != widget.currentLocation.id,
            orElse: () => widget.locations[1])
        .id;
    _selectedVehicleId = VehicleTypeId.bike;
  }

  @override
  void dispose() {
    _flexTimer?.cancel();
    _parcelNoteController.dispose();
    super.dispose();
  }

  SriLankaLocation get _originLoc => widget.locations
      .firstWhere((l) => l.id == _originId, orElse: () => widget.currentLocation);

  SriLankaLocation get _destLoc => widget.locations.firstWhere(
      (l) => l.id == _destinationId,
      orElse: () => widget.locations[1]);

  VehicleOption get _selectedVehicle => widget.vehicles.firstWhere(
      (v) => v.id == _selectedVehicleId,
      orElse: () => widget.vehicles[0]);

  RouteMetricsResult get _routeMetrics =>
      calculateRouteMetrics(_originLoc, _destLoc);

  PointToPointFareResult get _p2pFare => calculatePointToPointFare(
        _selectedVehicle,
        _routeMetrics.distanceKm,
        _isParcel,
      );

  FlexibleRideFareResult get _flexFare => calculateFlexibleRideRunningFare(
        _selectedVehicle,
        _flexTravelledKm,
        _flexElapsedSec,
      );

  void _startFlexTimer() {
    _flexTimer?.cancel();
    _flexTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _flexElapsedSec += 4;
        _flexTravelledKm = double.parse((_flexTravelledKm + 0.12).toStringAsFixed(2));
      });
    });
  }

  void _handleConfirmPointToPointBooking() {
    setState(() {
      _isConfirmingPayment = true;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      final bookingNum = math.Random().nextInt(8999) + 1000;
      final booking = ActivityBooking(
        id: _isParcel ? 'PAR-GD-$bookingNum' : 'RID-GD-$bookingNum',
        serviceType: _isParcel ? 'Parcel Delivery' : 'Ride Booking',
        title: _isParcel
            ? 'Courier · ${_selectedVehicle.name}'
            : 'Ride · ${_selectedVehicle.name}',
        subtitle: '${_originLoc.name.split('·')[0].trim()} → ${_destLoc.name.split('·')[0].trim()}',
        createdAt: 'Just now',
        status: 'Rider Assigned',
        paymentMethod: _paymentMethod,
        paymentStatus: 'Paid (Verified)',
        pickupAddress: _originLoc.address,
        destinationAddress: _destLoc.address,
        subtotalLKR: _p2pFare.baseFareLKR + _p2pFare.distanceChargeLKR,
        deliveryOrServiceFeeLKR: _p2pFare.parcelHandlingFeeLKR,
        discountLKR: 0,
        totalPaidLKR: _p2pFare.totalFareLKR,
        savingsEarnedLKR: _p2pFare.savingsAllocationLKR,
        etaMins: _routeMetrics.estimatedMinutes,
        distanceKm: _routeMetrics.distanceKm,
        driverOrRider: const DriverOrRider(
          name: 'Nuwan Kumara',
          phone: '+94 71 629 1184',
          vehicleName: 'Bajaj RE Tuk-Tuk',
          plateNumber: 'WP AAA-4912',
          rating: 4.92,
        ),
        itemsSummary: [
          'Mode: Point-to-Point (${_routeMetrics.distanceKm} km, ~${_routeMetrics.estimatedMinutes} mins)',
          if (_isParcel) 'Parcel Note: ${_parcelNoteController.text.trim()}',
        ],
        progressStep: 3,
      );

      widget.onCompleteRideBooking(
        booking,
        _p2pFare.savingsAllocationLKR,
        _p2pFare.baseFareLKR + _p2pFare.distanceChargeLKR,
      );

      setState(() {
        _isConfirmingPayment = false;
        _completedBookingReceipt = booking;
      });
    });
  }

  void _handleCompleteFlexibleRide() {
    _flexTimer?.cancel();
    setState(() {
      _isConfirmingPayment = true;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      final bookingNum = math.Random().nextInt(8999) + 1000;
      final booking = ActivityBooking(
        id: 'FLX-GD-$bookingNum',
        serviceType: 'Flexible Ride',
        title: 'Flexible Ride · ${_selectedVehicle.name}',
        subtitle: '${_originLoc.name.split('·')[0].trim()} · $_flexTravelledKm km (${_flexElapsedSec ~/ 60}m)',
        createdAt: 'Just now',
        status: 'Completed',
        paymentMethod: _paymentMethod,
        paymentStatus: 'Paid (Verified)',
        pickupAddress: _originLoc.address,
        destinationAddress: 'Flexible Open Destination',
        subtotalLKR: _flexFare.runningTotalLKR,
        deliveryOrServiceFeeLKR: 0,
        discountLKR: 0,
        totalPaidLKR: _flexFare.runningTotalLKR,
        savingsEarnedLKR: _flexFare.estimatedSavingsLKR,
        etaMins: 0,
        distanceKm: _flexTravelledKm,
        driverOrRider: const DriverOrRider(
          name: 'Nuwan Kumara',
          phone: '+94 71 629 1184',
          vehicleName: 'Bajaj RE Tuk-Tuk',
          plateNumber: 'WP AAA-4912',
          rating: 4.92,
        ),
        itemsSummary: [
          'Flexible distance-based trip completed',
          'Distance: $_flexTravelledKm km',
          'Elapsed: ${_flexElapsedSec ~/ 60} mins',
        ],
        progressStep: 5,
      );

      widget.onCompleteRideBooking(
        booking,
        _flexFare.estimatedSavingsLKR,
        _flexFare.runningTotalLKR,
      );

      setState(() {
        _isConfirmingPayment = false;
        _flexStage = 'idle';
        _flexTravelledKm = 0.0;
        _flexElapsedSec = 0;
        _completedBookingReceipt = booking;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HEADER (BLUE FROSTED)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                decoration: const BoxDecoration(
                  color: AppTheme.darkNavy,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: widget.onBackHome,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.arrow_back,
                                      size: 16, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'Home',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'GO DUDE Pick & Drop',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppTheme.skyBlue,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  'Ride-Hailing & Logistics',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Color(0xFFBAE6FD),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Segmented Mode Switcher (P2P vs Flexible Ride)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildModeTab(
                                id: 'p2p',
                                title: 'Point to Point',
                                sub: 'Fixed Drop Location',
                              ),
                            ),
                            Expanded(
                              child: _buildModeTab(
                                id: 'flexible',
                                title: 'Flexible Ride',
                                sub: 'Metered · Open Destination',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // MAIN CONTENT
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sub-switch for P2P: Passenger Ride vs Courier Parcel
                    if (_bookingMode == 'p2p') ...[
                      Row(
                        children: [
                          Expanded(
                            child: _buildP2PSubTab(
                              isParcel: false,
                              title: 'Passenger Ride',
                              icon: Icons.person,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildP2PSubTab(
                              isParcel: true,
                              title: 'Courier / Parcel',
                              icon: Icons.local_shipping,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Route Input Box (Origin & Destination)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.slate200),
                      ),
                      child: Column(
                        children: [
                          // Pickup Row
                          Row(
                            children: [
                              const Icon(Icons.circle,
                                  size: 12, color: AppTheme.deepSky),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Pickup Location',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: AppTheme.slate500)),
                                    DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _originId,
                                        isDense: true,
                                        isExpanded: true,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.slate900,
                                        ),
                                        items: widget.locations.map((loc) {
                                          return DropdownMenuItem<String>(
                                            value: loc.id,
                                            child: Text(
                                              '${loc.name} (${loc.city})',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() {
                                              _originId = val;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          if (_bookingMode == 'p2p') ...[
                            const Divider(height: 18),
                            // Destination Row
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 16, color: AppTheme.savingsOrange),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Destination',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: AppTheme.slate500)),
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _destinationId,
                                          isDense: true,
                                          isExpanded: true,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.slate900,
                                          ),
                                          items: widget.locations.map((loc) {
                                            return DropdownMenuItem<String>(
                                              value: loc.id,
                                              child: Text(
                                                '${loc.name} (${loc.city})',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              setState(() {
                                                _destinationId = val;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Parcel Note input if parcel
                    if (_bookingMode == 'p2p' && _isParcel) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _parcelNoteController,
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          labelText: 'Parcel Delivery Instructions',
                          labelStyle: const TextStyle(fontSize: 11),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    // LIVE ROUTE MAP
                    LiveRouteMap(
                      origin: _originLoc,
                      destination: _bookingMode == 'p2p' ? _destLoc : null,
                      vehicleType: _selectedVehicleId,
                      distanceKm: _bookingMode == 'p2p'
                          ? _routeMetrics.distanceKm
                          : (_flexStage == 'in_progress'
                              ? _flexTravelledKm
                              : 0.0),
                      etaMins: _bookingMode == 'p2p'
                          ? _routeMetrics.estimatedMinutes
                          : (_flexElapsedSec ~/ 60),
                      isFlexibleMode: _bookingMode == 'flexible',
                      isTripActive: _flexStage == 'in_progress',
                    ),

                    const SizedBox(height: 16),

                    // VEHICLE OPTIONS SELECTOR
                    const Text(
                      'Select Vehicle Type',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.slate900,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Column(
                      children: widget.vehicles.map((v) {
                        final isSel = _selectedVehicleId == v.id;
                        final fare = _bookingMode == 'p2p'
                            ? calculatePointToPointFare(
                                v, _routeMetrics.distanceKm, _isParcel)
                            : null;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedVehicleId = v.id;
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? const Color(0xFFEFF6FF)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSel
                                    ? AppTheme.primaryBlue
                                    : AppTheme.slate200,
                                width: isSel ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                VehicleIllustration(
                                    type: v.id, width: 44, height: 32),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              v.name,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.slate900,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '(${v.etaMins}m away)',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.foodGreen,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        v.sinhalaTamilSub,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppTheme.slate500,
                                        ),
                                      ),
                                      Text(
                                        v.capacity,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppTheme.slate600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (_bookingMode == 'p2p') ...[
                                      Text(
                                        'LKR ${formatLKR(fare!.totalFareLKR)}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.primaryBlue,
                                        ),
                                      ),
                                      Text(
                                        '+LKR ${fare.savingsAllocationLKR} Saved',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.savingsOrange,
                                        ),
                                      ),
                                    ] else ...[
                                      Text(
                                        'LKR ${v.baseFareLKR}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.primaryBlue,
                                        ),
                                      ),
                                      Text(
                                        '+LKR ${v.perKmRateLKR}/km',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppTheme.slate600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 14),

                    // MODE SPECIFIC ACTION DECK
                    if (_bookingMode == 'p2p') ...[
                      // P2P FARE SUMMARY & CONFIRMATION
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Flexible(
                                  child: Text('Total Estimated Fare',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 8),
                                Text('LKR ${formatLKR(_p2pFare.totalFareLKR)}',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.primaryBlue)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '+10% Savings: LKR ${_p2pFare.savingsAllocationLKR} will be credited to your 10% Savings Wallet.',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF7C2D12),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Select Payment Method',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.slate800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                'Visa •••• 4242',
                                'LankaPay QR',
                                'Genie Wallet',
                              ].map((pm) {
                                final isSel = _paymentMethod == pm;
                                return Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _paymentMethod = pm;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 2),
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSel ? const Color(0xFFEFF6FF) : Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isSel ? AppTheme.primaryBlue : AppTheme.slate200,
                                          width: isSel ? 1.5 : 1,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        pm,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isSel ? AppTheme.primaryBlue : AppTheme.slate700,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton(
                              onPressed: _isConfirmingPayment
                                  ? null
                                  : _handleConfirmPointToPointBooking,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryBlue,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isConfirmingPayment
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2),
                                    )
                                  : Text(
                                      _isParcel
                                          ? 'Book Courier (LKR ${formatLKR(_p2pFare.totalFareLKR)})'
                                          : 'Book Ride (LKR ${formatLKR(_p2pFare.totalFareLKR)})',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // FLEXIBLE RIDE LIFECYCLE CONTROLS
                      _buildFlexibleRideDeck(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        // RECEIPT MODAL
        if (_completedBookingReceipt != null) _buildReceiptModal(),
      ],
    );
  }

  Widget _buildModeTab({
    required String id,
    required String title,
    required String sub,
  }) {
    final isSel = _bookingMode == id;
    return InkWell(
      onTap: () {
        setState(() {
          _bookingMode = id;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? AppTheme.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSel ? Colors.white : AppTheme.slate300,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              sub,
              style: TextStyle(
                color: isSel ? Colors.white70 : AppTheme.slate400,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildP2PSubTab({
    required bool isParcel,
    required String title,
    required IconData icon,
  }) {
    final isSel = _isParcel == isParcel;
    return InkWell(
      onTap: () {
        setState(() {
          _isParcel = isParcel;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSel ? AppTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSel ? AppTheme.primaryBlue : AppTheme.slate200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16, color: isSel ? Colors.white : AppTheme.slate700),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSel ? Colors.white : AppTheme.slate800,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlexibleRideDeck() {
    if (_flexStage == 'idle') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.slate200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Mode Two: Flexible Distance-Based Ride',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.slate900),
            ),
            const SizedBox(height: 4),
            const Text(
              'No need to set destination upfront. Meter starts when you board. Hop on, tell the driver where to go, and stop anytime!',
              style: TextStyle(fontSize: 11, color: AppTheme.slate600),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _flexStage = 'driver_assigned';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Book Flexible Open Ride',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      );
    }

    if (_flexStage == 'driver_assigned') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.slate200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: AppTheme.foodGreen),
                const SizedBox(width: 8),
                const Text(
                  'Driver Assigned & En Route!',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Driver: Nuwan Kumara · Bajaj RE Tuk-Tuk (WP AAA-4912) · 4.92 ★',
              style: TextStyle(fontSize: 12, color: AppTheme.slate700),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _flexStage = 'in_progress';
                });
                _startFlexTimer();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.foodGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Start Trip (Board Vehicle)'),
            ),
          ],
        ),
      );
    }

    if (_flexStage == 'in_progress') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.darkNavy,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.trip_origin, size: 14, color: Color(0xFF4ADE80)),
                    SizedBox(width: 6),
                    Text(
                      'Trip In Progress',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${(_flexElapsedSec ~/ 60).toString().padLeft(2, '0')}:${(_flexElapsedSec % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: AppTheme.foodYellow,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Distance Travelled',
                        style: TextStyle(color: Colors.white70, fontSize: 11)),
                    Text(
                      '$_flexTravelledKm km',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Live Running Fare',
                        style: TextStyle(color: Colors.white70, fontSize: 11)),
                    Text(
                      'LKR ${formatLKR(_flexFare.runningTotalLKR)}',
                      style: const TextStyle(
                        color: AppTheme.skyBlue,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () {
                _flexTimer?.cancel();
                setState(() {
                  _flexStage = 'trip_ended_review';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('End Trip & Review Fare'),
            ),
          ],
        ),
      );
    }

    // trip_ended_review
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Trip Complete · Review & Pay',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: AppTheme.slate900),
          ),
          const SizedBox(height: 10),
          Text('Total Distance: $_flexTravelledKm km'),
          Text('Duration: ${_flexElapsedSec ~/ 60} mins'),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Final Fare',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text('LKR ${formatLKR(_flexFare.runningTotalLKR)}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryBlue)),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '+10% Savings: LKR ${_flexFare.estimatedSavingsLKR} added to your Savings Balance.',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF7C2D12),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Confirm Online Payment Method',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.slate800,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              'Visa •••• 4242',
              'LankaPay QR',
              'Genie Wallet',
            ].map((pm) {
              final isSel = _paymentMethod == pm;
              return Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _paymentMethod = pm;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFFEFF6FF) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSel ? AppTheme.primaryBlue : AppTheme.slate200,
                        width: isSel ? 1.5 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      pm,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSel ? AppTheme.primaryBlue : AppTheme.slate700,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: _isConfirmingPayment ? null : _handleCompleteFlexibleRide,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isConfirmingPayment
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Pay & Settle Ride'),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptModal() {
    final b = _completedBookingReceipt!;
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(20),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: SingleChildScrollView(
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
                      'Booking Confirmed!',
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
                      _completedBookingReceipt = null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('ID: ${b.id}',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue)),
            Text('Service: ${b.title}',
                style: const TextStyle(fontSize: 12, color: AppTheme.slate800)),
            Text('Route: ${b.subtitle}',
                style: const TextStyle(fontSize: 11, color: AppTheme.slate500)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+LKR ${b.savingsEarnedLKR} 10% Savings Credited',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.foodGreen,
                ),
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _completedBookingReceipt = null;
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
      ),
    );
  }
}
