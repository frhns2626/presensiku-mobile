import 'package:flutter_test/flutter_test.dart';
import 'package:presensi_absen/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PresensiApp());
    expect(find.text('PresensiKu'), findsWidgets);
    // Majukan waktu melewati splash screen
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 200));
  });
}
