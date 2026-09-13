import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirkula_banksampah/config/app_theme.dart';
import 'package:sirkula_banksampah/widgets/bottom_navbar.dart';

void main() {
  testWidgets('BottomNav renders Nasabah items correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          bottomNavigationBar: BottomNav(0, role: 'NASABAH'),
        ),
      ),
    );

    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });

  testWidgets('BottomNav navigates to /nasabah/profil when Profil is tapped', (WidgetTester tester) async {
    String currentRoute = '/nasabah/home';

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/nasabah/home',
        routes: {
          '/nasabah/home': (context) => const Scaffold(
                body: Text('Home Page'),
                bottomNavigationBar: BottomNav(0, role: 'NASABAH'),
              ),
          '/nasabah/profil': (context) {
            currentRoute = '/nasabah/profil';
            return const Scaffold(
              body: Text('Profile Page'),
              bottomNavigationBar: BottomNav(1, role: 'NASABAH'),
            );
          },
        },
      ),
    );

    expect(find.text('Home Page'), findsOneWidget);

    // Tap Profil tab
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    expect(currentRoute, '/nasabah/profil');
    expect(find.text('Profile Page'), findsOneWidget);
  });

  testWidgets('AppTheme page transitions render smoothly on tab switch', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        initialRoute: '/nasabah/home',
        routes: {
          '/nasabah/home': (context) => const Scaffold(
                body: Text('Beranda Content'),
                bottomNavigationBar: BottomNav(0, role: 'NASABAH'),
              ),
          '/nasabah/profil': (context) => const Scaffold(
                body: Text('Profil Content'),
                bottomNavigationBar: BottomNav(1, role: 'NASABAH'),
              ),
        },
      ),
    );

    expect(find.text('Beranda Content'), findsOneWidget);

    // Tap Profil tab
    await tester.tap(find.text('Profil'));

    // Verify mid-animation state doesn't crash
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.text('Profil Content'), findsOneWidget);
  });
}
