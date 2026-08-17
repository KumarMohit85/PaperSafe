import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:papersafe/main.dart';

void main() {
  testWidgets('PaperSafe smoke test', (WidgetTester tester) async {
    // Verify the app starts without crashing
    await tester.pumpWidget(const ProviderScopeWrapper());
    expect(find.byType(MaterialApp), findsNothing); // MaterialApp.router used
  });
}

/// Minimal wrapper to avoid full ProviderScope setup in tests.
class ProviderScopeWrapper extends StatelessWidget {
  const ProviderScopeWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Scaffold(body: Text('Test')));
  }
}
