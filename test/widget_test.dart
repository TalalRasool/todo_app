import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talal_todo/utils/time_format.dart';
import 'package:talal_todo/widgets/common_textfield.dart';

void main() {
  test('formatTaskTime uses a 12-hour clock', () {
    expect(formatTaskTime(const TimeOfDay(hour: 14, minute: 5)), '2:05 PM');
    expect(formatTaskTime(const TimeOfDay(hour: 0, minute: 0)), '12:00 AM');
    expect(formatTaskTime(const TimeOfDay(hour: 12, minute: 30)), '12:30 PM');
    expect(formatTaskTime(const TimeOfDay(hour: 9, minute: 7)), '9:07 AM');
  });

  testWidgets('password field toggles visibility', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CommonTextField(
            controller: controller,
            hintText: 'Password',
            isPassword: true,
          ),
        ),
      ),
    );

    TextField field() => tester.widget<TextField>(find.byType(TextField));

    expect(field().obscureText, isTrue);
    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();
    expect(field().obscureText, isFalse);
  });
}
