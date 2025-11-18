import 'package:flutter_test/flutter_test.dart';
import 'package:weather_dashboard/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WeatherDashboardApp());

    // Verify that the app loads and shows the title text.
    expect(find.text('Personalized Weather Dashboard'), findsOneWidget);
  });
}
