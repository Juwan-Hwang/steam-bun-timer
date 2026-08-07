import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:steam_bun_timer/main.dart';

void main() {
  testWidgets('App renders dashboard with empty state', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: SteamBunTimerApp()),
    );

    // 空状态应显示「蒸馒头计时器」标题
    expect(find.text('蒸馒头计时器'), findsOneWidget);
  });
}
