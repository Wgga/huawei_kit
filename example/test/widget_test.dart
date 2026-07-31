import 'package:flutter_test/flutter_test.dart';
import 'package:huawei_kit_example/main.dart';

void main() {
  testWidgets('renders the Huawei authorization action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const HuaweiKitExampleApp());

    expect(find.text('Huawei Account Kit'), findsOneWidget);
    expect(find.text('Authorize'), findsOneWidget);
    expect(find.text('Not authorized'), findsOneWidget);
  });
}
