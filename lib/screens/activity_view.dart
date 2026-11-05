import 'package:flutter/material.dart';
import '../types/godude.dart';
import '../theme/app_theme.dart';
import '../utils/calculations.dart';
import '../components/visual_assets.dart';

class ActivityView extends StatefulWidget {
  final List<ActivityBooking> bookings;
  final SriLankaLocation currentLocation;
  final ValueChanged<String> onAdvanceBookingStatus;
  final ValueChanged<String> onCancelBooking;
  final Function(ActiveServiceView service) onBookNewService;

  const ActivityView({
    super.key,
    required this.bookings,
    required this.currentLocation,
    required this.onAdvanceBookingStatus,
    required this.onCancelBooking,
    required this.onBookNewService,
  });

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  String _filter = 'all'; // 'all' | 'active' | 'completed' | 'cancelled'
  String? _contactToast;

  bool _isBookingActive(ActivityBooking b) {
    return b.status != 'Delivered' &&
        b.status != 'Completed' &&
        b.status != 'Cancelled';
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = widget.bookings.where(_isBookingActive).length;

    final filtered = widget.bookings.where((b) {
      if (_filter == 'active') return _isBookingActive(b);
      if (_filter == 'completed') {
        return b.status == 'Delivered' || b.status == 'Completed';
      }
      if (_filter == 'cancelled') return b.status == 'Cancelled';
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // HEADER (BLUE FROSTED)
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Activity Hub',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Live food deliveries, passenger rides & courier parcels',
                            style: TextStyle(
                              color: AppTheme.skyBlue,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFACC15).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFFFACC15).withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          '$activeCount Active',
                          style: const TextStyle(
                            color: AppTheme.foodYellow,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Filter Chips
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        _buildFilterTab('all', 'All (${widget.bookings.length})'),
                        _buildFilterTab('active', 'Active ($activeCount)'),
                        _buildFilterTab('completed', 'Done'),
                        _buildFilterTab('cancelled', 'Cancelled'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_contactToast != null)
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.darkNavy,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.skyBlue),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_contactToast!,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.close, size: 16, color: Colors.white70),
                    onPressed: () {
                      setState(() {
                        _contactToast = null;
                      });
                    },
                  ),
                ],
              ),
            ),

          // BOOKINGS LIST
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (filtered.isEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.slate200),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Icon(Icons.assignment_outlined,
                            size: 40, color: AppTheme.slate400),
                        const SizedBox(height: 10),
                        const Text(
                          'No bookings found under this filter',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.slate800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Your live ride and food delivery history will appear here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 11, color: AppTheme.slate500),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () => widget
                                  .onBookNewService(ActiveServiceView.foods),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.foodGreen,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Order Food'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () => widget
                                  .onBookNewService(ActiveServiceView.pickdrop),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryBlue,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Book Ride'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, idx) {
                      final b = filtered[idx];
                      final isActive = _isBookingActive(b);

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isActive
                                ? AppTheme.primaryBlue.withValues(alpha: 0.5)
                                : AppTheme.slate200,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x06000000),
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header row: Service type badge, ID, Status
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    _buildServiceBadge(b.serviceType),
                                    const SizedBox(width: 8),
                                    Text(
                                      b.id,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.slate500,
                                      ),
                                    ),
                                  ],
                                ),
                                _buildStatusBadge(b.status),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Text(
                              b.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.slate900,
                              ),
                            ),
                            Text(
                              b.subtitle,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.slate600,
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Addresses
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.slate50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.circle,
                                          size: 10, color: AppTheme.deepSky),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          b.pickupAddress,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.slate700),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.location_on,
                                          size: 12,
                                          color: AppTheme.savingsOrange),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          b.destinationAddress,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.slate700),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Active live tracking map & stepper
                            if (isActive) ...[
                              const SizedBox(height: 12),
                              LiveRouteMap(
                                origin: widget.currentLocation,
                                vehicleType: VehicleTypeId.tuktuk,
                                distanceKm: b.distanceKm,
                                etaMins: b.etaMins,
                                progressPercent: (b.progressStep / 5.0) * 100.0,
                              ),
                              const SizedBox(height: 12),
                              _buildStepProgress(b.progressStep),
                              const SizedBox(height: 12),

                              // Driver card
                              if (b.driverOrRider != null)
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(0xFFBFDBFE)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            b.driverOrRider!.name,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            '${b.driverOrRider!.vehicleName} · ${b.driverOrRider!.plateNumber}',
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: AppTheme.slate600),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.phone,
                                            size: 18,
                                            color: AppTheme.primaryBlue),
                                        onPressed: () {
                                          setState(() {
                                            _contactToast =
                                                'Calling ${b.driverOrRider!.name} (${b.driverOrRider!.phone})...';
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                              const SizedBox(height: 12),

                              // Action controls: Advance step & Cancel
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => widget
                                          .onAdvanceBookingStatus(b.id),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryBlue,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      icon: const Icon(Icons.fast_forward,
                                          size: 16),
                                      label: const Text(
                                        'Advance Step (+1)',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    onPressed: () =>
                                        widget.onCancelBooking(b.id),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('Cancel & Refund',
                                        style: TextStyle(fontSize: 11)),
                                  ),
                                ],
                              ),
                            ],

                            const SizedBox(height: 10),

                            // Footer: Total Paid and Savings badge
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Paid: LKR ${formatLKR(b.totalPaidLKR)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.slate900,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF7ED),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '+LKR ${b.savingsEarnedLKR} Saved',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.savingsOrange,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String id, String label) {
    final isSel = _filter == id;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _filter = id;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSel ? AppTheme.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSel ? Colors.white : AppTheme.slate300,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceBadge(String serviceType) {
    Color bg = const Color(0xFFDCFCE7);
    Color fg = const Color(0xFF166534);

    if (serviceType == 'Ride Booking' || serviceType == 'Flexible Ride') {
      bg = const Color(0xFFDBEAFE);
      fg = const Color(0xFF1E40AF);
    } else if (serviceType == 'Parcel Delivery') {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFF92400E);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        serviceType,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = const Color(0xFFFEF3C7);
    Color fg = const Color(0xFFB45309);

    if (status == 'Delivered' || status == 'Completed') {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF15803D);
    } else if (status == 'Cancelled') {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFB91C1C);
    } else if (status == 'On the Way') {
      bg = const Color(0xFFDBEAFE);
      fg = const Color(0xFF1D4ED8);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  Widget _buildStepProgress(int step) {
    final stepLabels = [
      'Confirmed',
      'Preparing',
      'Rider Assigned',
      'On the Way',
      'Done'
    ];

    return Row(
      children: List.generate(5, (idx) {
        final isPassed = (idx + 1) <= step;
        return Expanded(
          child: Column(
            children: [
              Container(
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isPassed ? AppTheme.primaryBlue : AppTheme.slate200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stepLabels[idx],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: isPassed ? FontWeight.bold : FontWeight.normal,
                  color: isPassed ? AppTheme.primaryBlue : AppTheme.slate400,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
