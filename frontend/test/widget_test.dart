import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('Misinformation Dashboard app loads login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MisinformationDashboardApp());
    expect(find.byType(MisinformationDashboardApp), findsOneWidget);
  });
}
