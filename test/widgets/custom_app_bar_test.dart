import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flerta_ai/apresentacao/widgets/custom_app_bar.dart';
import 'package:flerta_ai/core/constants/app_strings.dart';

void main() {
  group('CustomAppBar Tests', () {
    testWidgets('should display app name correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const CustomAppBar(),
          ),
        ),
      );

      expect(find.text(AppStrings.appName), findsOneWidget);
    });

    testWidgets('should have menu button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const CustomAppBar(),
          ),
        ),
      );

      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    testWidgets('should call onMenuPressed when menu button is tapped', (WidgetTester tester) async {
      bool menuPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CustomAppBar(
              onMenuPressed: () {
                menuPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pump();

      expect(menuPressed, isTrue);
    });

    testWidgets('should have correct height', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const CustomAppBar(),
          ),
        ),
      );

      final CustomAppBar customAppBar = tester.widget(find.byType(CustomAppBar));
      expect(customAppBar.preferredSize.height, equals(kToolbarHeight));
    });

    testWidgets('should contain app name text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const CustomAppBar(),
          ),
        ),
      );

      expect(find.text(AppStrings.appName), findsOneWidget);
    });
  });
}
