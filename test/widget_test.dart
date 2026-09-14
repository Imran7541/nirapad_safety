import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nirapad_safety/presentation/widgets/big_sos_button.dart';
import 'package:nirapad_safety/presentation/widgets/fake_call_dialog.dart';

void main() {
  testWidgets('BigSosButton renders and reacts to tap', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BigSosButton(
            onTap: () => tapped = true,
            label: 'টেস্ট SOS',
          ),
        ),
      ),
    );

    expect(find.text('টেস্ট SOS'), findsOneWidget);
    expect(find.text('জরুরি সাহায্য'), findsOneWidget);

    await tester.tap(find.byType(BigSosButton));
    await tester.pump(const Duration(milliseconds: 100));

    expect(tapped, isTrue);
  });

  testWidgets('FakeCallScreen renders and handles answer call flow', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FakeCallScreen(
          callerName: 'আম্মু (Mother)',
        ),
      ),
    );

    expect(find.text('আম্মু (Mother)'), findsOneWidget);
    expect(find.text('ইনকামিং কল...'), findsOneWidget);

    // Tap green call answer floating action button
    await tester.tap(find.byIcon(Icons.call));
    await tester.pump();

    // Call duration timer starts and end call button appears
    expect(find.text('00:00'), findsOneWidget);
    expect(find.byIcon(Icons.call_end), findsOneWidget);
  });
}
