import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_app/main.dart';
import 'package:my_first_app/types/godude.dart';
import 'package:my_first_app/components/visual_assets.dart';
import 'package:my_first_app/data/sri_lanka_data.dart';

void main() {
  testWidgets('GoDudeApp smoke test and brand branding verification',
      (WidgetTester tester) async {
    await tester.pumpWidget(const GoDudeApp());
    expect(find.text('GO'), findsWidgets);
    expect(find.text('dUDe'), findsWidgets);
  });

  testWidgets('Homepage renders 4 core services: Food Delivery, Pick & Drop, Ride Booking, Savings & Deals',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const GoDudeApp());
    await tester.pumpAndSettle();

    expect(find.text('Food\nDelivery'), findsWidgets);
    expect(find.text('Pick &\nDrop'), findsWidgets);
    expect(find.text('Ride\nBooking'), findsWidgets);
    expect(find.text('Savings &\nDeals'), findsWidgets);
  });

  testWidgets('LiveRouteMap renders smoothly without errors and contains route and pin details',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LiveRouteMap(
            origin: SRI_LANKA_LOCATIONS[0],
            destination: SRI_LANKA_LOCATIONS[1],
            vehicleType: VehicleTypeId.car,
            distanceKm: 8.5,
            etaMins: 22,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(LiveRouteMap), findsOneWidget);
    expect(find.text('Demo GPS'), findsOneWidget);
    expect(find.text('8.5 km · 22 min'), findsOneWidget);
  });

  testWidgets('Navigating to Pick & Drop displays vehicle options and payment selector',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(500, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const GoDudeApp());
    await tester.pumpAndSettle();

    // Tap Ride Booking service card
    final rideBookingCard = find.text('Ride\nBooking');
    expect(rideBookingCard, findsWidgets);
    await tester.tap(rideBookingCard.first);
    await tester.pumpAndSettle();

    // Verify PickDrop view elements
    expect(find.byType(LiveRouteMap), findsWidgets);
    expect(find.text('Point to Point'), findsWidgets);
    expect(find.text('Flexible Ride'), findsWidgets);

    // Scroll down inside phone frame to view vehicles and payment method
    final phoneScrollable = find.byType(SingleChildScrollView).first;
    await tester.drag(phoneScrollable, const Offset(0, -500));
    await tester.pumpAndSettle();

    // Verify vehicle options
    expect(find.text('Three-Wheeler (Tuk-Tuk)'), findsWidgets);
    expect(find.text('Car (AC Sedan)'), findsWidgets);

    // Verify payment method selector is present and visible
    expect(find.text('Select Payment Method'), findsWidgets);
    expect(find.text('Visa •••• 4242'), findsWidgets);
    expect(find.text('LankaPay QR'), findsWidgets);
  });
}
