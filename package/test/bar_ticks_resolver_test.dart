import 'package:flutter_test/flutter_test.dart';
import 'package:fast_charts/src/bar_chart/ticks_resolver.dart';

enum ValueState { normal, nan, posInf, negInf }
enum Param { minValue, maxValue, axisSize, minSpacing }

void main() {
  group('BarTicksResolver', () {
    const normalMin = -10.0;
    const normalMax = 20.0;
    const normalAxis = 200.0;
    const normalSpacing = 52.0;

    double valueFor(final ValueState state, {required final Param param})
      => switch (state) {
        ValueState.normal => switch (param) {
          Param.minValue =>  normalMin,
          Param.maxValue =>  normalMax,
          Param.axisSize =>  normalAxis,
          Param.minSpacing =>  normalSpacing,
        },
        ValueState.nan => double.nan,
        ValueState.posInf => double.infinity,
        ValueState.negInf => double.negativeInfinity,
      };

    void assertTickClassifications({
      required final List<double> ticks,
      required final double minValue,
      required final double maxValue,
    }) {
      expect(ticks.length, greaterThanOrEqualTo(2));
      // Non-decreasing
      for (var i = 1; i < ticks.length; ++i) {
        expect(ticks[i] >= ticks[i - 1], isTrue);
      }

      final first = ticks.first;
      final last = ticks.last;
      expect(first <= minValue, isTrue);
      expect(last >= maxValue, isTrue);

      final containsZero = ticks.contains(0.0);

      final length = ticks.length;
      final isTwoOrMoreNoZero = length >= 2 && !containsZero;
      final isThreeOrMoreWithZero = length >= 3 && containsZero;

      expect(
        isTwoOrMoreNoZero || isThreeOrMoreWithZero,
        isTrue,
      );
    }

    test('all combinations with finite min/max succeed and are classified', () {
      const states = ValueState.values;

      for (final axisState in states) {
        for (final spacingState in states) {
          final minValue = valueFor(ValueState.normal, param: Param.minValue);
          final maxValue = valueFor(ValueState.normal, param: Param.maxValue);
          final axisSize = valueFor(axisState, param: Param.axisSize);
          final minSpacing = valueFor(spacingState, param: Param.minSpacing);

          final resolver = BarTicksResolver(minSpacing: minSpacing);
          final ticks = resolver.getTickValues(
            minValue: minValue,
            maxValue: maxValue,
            axisSize: axisSize,
          );

          assertTickClassifications(
            ticks: ticks,
            minValue: minValue,
            maxValue: maxValue,
          );
        }
      }
    });

    test('all combinations where min/max are non-finite throw', () {
      const states = ValueState.values;

      for (final minState in states) {
        for (final maxState in states) {
          if (minState == ValueState.normal && maxState == ValueState.normal) {
            continue; // covered in finite test above
          }

          final minValue = valueFor(minState, param: Param.minValue);
          final maxValue = valueFor(maxState, param: Param.maxValue);
          final axisSize = valueFor(ValueState.normal, param: Param.axisSize);
          final minSpacing = valueFor(ValueState.normal, param: Param.minSpacing);

          final resolver = BarTicksResolver(minSpacing: minSpacing);

          expect(
            () => resolver.getTickValues(
              minValue: minValue,
              maxValue: maxValue,
              axisSize: axisSize,
            ),
            throwsA(isA<UnsupportedError>()),
          );
        }
      }
    });

  });
}

