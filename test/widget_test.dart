import 'package:flutter_test/flutter_test.dart';
import 'package:uts_kelompok4/main.dart';

void main() {
  testWidgets('Aplikasi Revalue tampil di Splash', (WidgetTester tester) async {
    await tester.pumpWidget(const RevalueApp());
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}