import 'package:camera_flutter_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('example app builds and shows its title', (tester) async {
    await tester.pumpWidget(const ExampleApp());
    expect(find.text('camera_flutter example'), findsOneWidget);
  });
}
