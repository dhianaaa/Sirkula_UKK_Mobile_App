import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirkula_banksampah/config/app_theme.dart';
import 'package:sirkula_banksampah/views/nasabah_dashboard_screen.dart';

void main() {
  testWidgets('NasabahHomeScreen renders all reference components properly',
      (WidgetTester tester) async {
    // Set typical mobile phone screen size (390 x 844)
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const NasabahHomeScreen(),
      ),
    );

    // Initial build
    await tester.pump();

    // Verify key sections from the real screen are present
    expect(find.textContaining('Halo,'), findsOneWidget);
    expect(find.text('TOTAL SALDO POIN'), findsOneWidget);
    expect(find.text('Setor'), findsOneWidget);
    expect(find.text('Tukar'), findsWidgets);
    expect(find.text('Tarik'), findsOneWidget);
    expect(find.textContaining('CO₂'), findsWidgets);
    expect(find.text('Berhasil Dicegah'), findsOneWidget);
    expect(find.textContaining('Pohon'), findsWidgets);
    expect(find.text('Diselamatkan'), findsOneWidget);
    expect(find.text('Harga Sampah Hari Ini'), findsOneWidget);

    // Scroll down to reveal lower sections
    await tester.drag(
        find.byKey(const Key('nasabah_main_scroll')), const Offset(0, -500));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Tips Sirkuler'), findsOneWidget);
    expect(find.text('Pilah Bersih, Poin Berlebih!'), findsOneWidget);
    expect(find.text('Aktivitas Terakhir'), findsOneWidget);
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Riwayat'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });
}
