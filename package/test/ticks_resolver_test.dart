import 'package:flutter_test/flutter_test.dart';
import 'package:fast_charts/src/ticks_resolver.dart';

void main() {
  group('SimpleTicksResolver', () {
    test('returns sorted bounds when both are positive', () {
      final resolver = SimpleTicksResolver();

      final result = resolver.getTickValues(
        minValue: 0,
        maxValue: 10,
        axisSize: 100,
      );

      expect(result, equals([0, 10]));
    });

    test('inserts zero when range crosses zero', () {
      final resolver = SimpleTicksResolver();

      final result = resolver.getTickValues(
        minValue: -5,
        maxValue: 5,
        axisSize: 200,
      );

      expect(result, equals([-5, 0, 5]));
    });

    test('sorts descending inputs', () {
      final resolver = SimpleTicksResolver();

      final result = resolver.getTickValues(
        minValue: 8,
        maxValue: 2,
        axisSize: 50,
      );

      expect(result, equals([2, 8]));
    });

    test('does not insert zero when range stays negative', () {
      final resolver = SimpleTicksResolver();

      final result = resolver.getTickValues(
        minValue: -12,
        maxValue: -1,
        axisSize: 75,
      );

      expect(result, equals([-12, -1]));
    });

    test('preserves NaN inputs without throwing', () {
      final resolver = SimpleTicksResolver();

      final result = resolver.getTickValues(
        minValue: double.nan,
        maxValue: 5,
        axisSize: 10,
      );

      expect(result.length, 2);
      expect(result.any((v) => v.isNaN), isTrue);
      expect(result.contains(5), isTrue);
    });

    test('handles negative infinity crossing zero', () {
      final resolver = SimpleTicksResolver();

      final result = resolver.getTickValues(
        minValue: double.negativeInfinity,
        maxValue: 5,
        axisSize: 10,
      );

      expect(result, equals([double.negativeInfinity, 0.0, 5]));
    });

    test('handles positive infinity crossing zero', () {
      final resolver = SimpleTicksResolver();

      final result = resolver.getTickValues(
        minValue: -5,
        maxValue: double.infinity,
        axisSize: 10,
      );

      expect(result, equals([-5, 0.0, double.infinity]));
    });

    test('ignores axisSize when it is NaN', () {
      final resolver = SimpleTicksResolver();

      final result = resolver.getTickValues(
        minValue: 1,
        maxValue: 2,
        axisSize: double.nan,
      );

      expect(result, equals([1, 2]));
    });

    test('ignores axisSize when it is infinite', () {
      final resolver = SimpleTicksResolver();

      final result = resolver.getTickValues(
        minValue: -1,
        maxValue: 1,
        axisSize: double.infinity,
      );

      expect(result, equals([-1, 0.0, 1]));
    });
  });
}

