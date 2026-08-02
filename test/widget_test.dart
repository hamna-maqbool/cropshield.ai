import 'package:crop_shield_ai/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Home screen shows app title and input options', (tester) async {
    await tester.pumpWidget(const CropShieldApp());
    await tester.pumpAndSettle();

    expect(find.text('Crop Shield AI'), findsOneWidget);
    expect(find.text('Camera'), findsOneWidget);
    expect(find.text('Image Upload'), findsOneWidget);
    expect(find.text('Text Input'), findsOneWidget);
    expect(find.text('Voice Input'), findsOneWidget);
  });
}
