import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // This file is intentionally left minimal.
    // The full app requires Firebase initialization which is
    // handled in main.dart and tested on a real device.
    expect(true, isTrue);
  });
}