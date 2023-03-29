import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uno_dots_trace/main.dart';
import 'package:uno_dots_trace/src/model.dart';
import 'package:uno_dots_trace/src/services/figure_service.dart';

class MockFigureService extends Mock implements FigureService {}

final fakeFigure1 =
    Figure(id: '1', title: 'Figure1', points: [Point(Offset.zero, 1)]);
final jsonFigure1 = jsonEncode(fakeFigure1);

final fakeFigure2 =
    Figure(id: '2', title: 'Figure2', points: [Point(const Offset(10, 10), 2)]);
final jsonFigure2 = jsonEncode(fakeFigure2);

void main() {
  testWidgets(
    'desktop editor smoke test',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(minSize);

      final service = MockFigureService();
      when(() => service.load())
          .thenAnswer((invocation) => Future.value([jsonFigure1]));

      final app = MacApp(service);

      await tester.pumpWidget(app);

      expect(find.text('New Page'), findsOneWidget);
      expect(find.text('Figure1'), findsOneWidget);
      expect(find.text('Figure2'), findsOneWidget);
    },
  );
}
