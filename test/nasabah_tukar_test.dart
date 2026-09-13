// test/nasabah_tukar_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sirkula_banksampah/views/nasabah_riwayat_screen.dart';
import 'package:sirkula_banksampah/views/nasabah_tukar_screen.dart';

void main() {
  testWidgets('NasabahTukarScreen renders tabs and points header',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NasabahTukarScreen(),
      ),
    );

    await tester.pump();

    // Verify AppBar title and tabs
    expect(find.text('Tukar Hadiah & Poin'), findsOneWidget);
    expect(find.text('Katalog Hadiah'), findsOneWidget);
    expect(find.textContaining('Riwayat Saya'), findsOneWidget);
  });

  testWidgets('NasabahRiwayatScreen renders tabs properly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NasabahRiwayatScreen(),
      ),
    );

    await tester.pump();

    // Verify AppBar title and tabs
    expect(find.text('Riwayat Transaksi'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Setor Sampah'), findsOneWidget);
    expect(find.text('Tukar Poin'), findsOneWidget);
  });

  testWidgets('Navigating to /nasabah/tukar via named route succeeds without error',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/nasabah/tukar',
        routes: {
          '/nasabah/tukar': (context) => const NasabahTukarScreen(),
          '/nasabah/riwayat': (context) => const NasabahRiwayatScreen(),
        },
      ),
    );

    await tester.pump();
    expect(find.text('Tukar Hadiah & Poin'), findsOneWidget);
  });
}
