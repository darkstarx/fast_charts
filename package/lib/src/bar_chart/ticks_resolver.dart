import 'dart:math';

import '../ticks_resolver.dart';
import '../types.dart';


class BarTicksResolver implements TicksResolver
{
  /// The minimal distance between next ticks in pixels.
  final double minSpacing;

  const BarTicksResolver({
    this.minSpacing = 52.0,
  });

  @override
  List<double> getTickValues({
    required final double minValue,
    required final double maxValue,
    required final double axisSize,
  })
  {
    final minTickCount = minValue < 0 && maxValue > 0 ? 3 : 2;
    final floatTickCount = axisSize / minSpacing;
    final maxTickCount = floatTickCount.isFinite
      ? max(minTickCount, floatTickCount.floor() + 1)
      : minTickCount;

    var tickValues = <double>[];
    var foundPreferredTicks = false;
    var selectedTicksRange = double.maxFinite;

    for (var tickCount = maxTickCount; tickCount >= minTickCount; --tickCount) {
      final stepInfo = _getStepsForTickCount(
        tickCount: tickCount,
        high: maxValue,
        low: minValue,
      );
      final firstTick = stepInfo.tickStart;
      final lastTick = stepInfo.tickStart + stepInfo.stepSize * (tickCount - 1);
      final range = lastTick - firstTick;
      // Calculate ticks if it is a better range or if preferred ticks have not
      // been found yet.
      if (range < selectedTicksRange || !foundPreferredTicks) {
        tickValues = _generateTickValues(
          stepInfo.tickStart, stepInfo.stepSize, tickCount
        );
        final ticksCollide = _ticksCollide(
          tickValues.map((e) => axisSize * e / range)
        );
        // Don't choose colliding ticks unless it was our last resort.
        if (ticksCollide && tickCount > minTickCount) {
          continue;
        }
        foundPreferredTicks = true;
        selectedTicksRange = range;
      }
    }
    return tickValues;
  }

  bool _ticksCollide(final Iterable<double> scaledTicks)
  {
    double? prevTick;
    for (final tick in scaledTicks) {
      if (prevTick == null) {
        prevTick = tick;
      } else {
        if ((tick - prevTick).abs() < minSpacing) return true;
      }
    }
    return false;
  }

  /// Given [tickCount] and the domain range, finds the smallest tick increment,
  /// chosen from power of 10 multiples of allowed steps, that covers the whole
  /// data range.
  static ({
    double stepSize,
    double tickStart,
  }) _getStepsForTickCount({
    required final int tickCount,
    required final num high,
    required final num low,
    final bool dataIsInWholeNumbers = true,
  })
  {
    // A region is the space between ticks.
    final regionCount = tickCount - 1;

    // If the range contains zero, ensure that zero is a tick.
    if (high >= 0 && low <= 0) {
      // Determine the ratio of regions that are above the zero axis.
      final posRegionRatio = high > 0 ? min(1.0, high / (high - low)) : 0.0;
      var positiveRegionCount = max(1, (regionCount * posRegionRatio).round());
      var negativeRegionCount = regionCount - positiveRegionCount;
      // Ensure that negative regions are not excluded, unless there are no
      // regions to spare.
      if (negativeRegionCount == 0 && low < 0 && regionCount > 1) {
        --positiveRegionCount;
        ++negativeRegionCount;
      }

      // If we have positive and negative values, ensure that we have ticks in
      // both regions.
      assert(
        !(
          low < 0
          && high > 0
          && (negativeRegionCount == 0 || positiveRegionCount == 0)
        ),
        'Numeric tick provider cannot generate $tickCount ticks when the axis '
        'range contains both positive and negative values. A minimum of three '
        'ticks are required to include zero.'
      );

      // Determine the "favored" axis direction (the one which will control the
      // ticks based on having a greater value / regions).
      //
      // Example: 13 / 3 (4.33 per tick) vs -5 / 1 (5 per tick)
      // making -5 the favored number.  A step size that includes this number
      // ensures the other is also includes in the opposite direction.
      final favorPositive = (high > 0 ? high / positiveRegionCount : 0).abs() >
        (low < 0 ? low / negativeRegionCount : 0).abs();
      final favoredNum = (favorPositive ? high : low).abs();
      final favoredRegionCount = favorPositive
        ? positiveRegionCount
        : negativeRegionCount;
      final favoredTensBase = _getEnclosingPowerOfTen(favoredNum).abs();

      // Check each step size and see if it would contain the "favored" value
      for (final step in _defaultSteps) {
        final tmpStepSize = (step * favoredTensBase).smooth;

        // If prefer whole number, then don't allow a step that isn't one.
        if (dataIsInWholeNumbers && tmpStepSize.round() != tmpStepSize) {
          continue;
        }

        if (tmpStepSize * favoredRegionCount >= favoredNum) {
          final stepStart = negativeRegionCount > 0
            ? (-1 * tmpStepSize * negativeRegionCount)
            : 0.0;
          return (stepSize: tmpStepSize, tickStart: stepStart);
        }
      }
    } else {
      // Find the range base to calculate step sizes.
      final diffTensBase = _getEnclosingPowerOfTen(high - low);
      // Walk the step sizes calculating a starting point and seeing if the high
      // end is included in the range given that step size.
      for (final step in _defaultSteps) {
        final tmpStepSize = (step * diffTensBase).smooth;

        // If prefer whole number, then don't allow a step that isn't one.
        if (dataIsInWholeNumbers && tmpStepSize.round() != tmpStepSize) {
          continue;
        }

        final tmpStepStart = _getStepLessThan(low.toDouble(), tmpStepSize);
        if (tmpStepStart + (tmpStepSize * regionCount) >= high) {
          return (stepSize: tmpStepSize, tickStart: tmpStepStart);
        }
      }
    }

    return (stepSize: 1.0, tickStart: low.floorToDouble());
  }

  static double _getEnclosingPowerOfTen(final num number)
  {
    if (number == 0) {
      return 1.0;
    }
    return pow(10, (log10e * log(number.abs())).ceil())
      .toDouble() * (number < 0.0 ? -1.0 : 1.0);
  }

  /// Returns the step numerically less than the number by step increments.
  static double _getStepLessThan(final double number, final double stepSize)
  {
    if (number == 0.0 || stepSize == 0.0) {
      return 0.0;
    }
    return stepSize * (
      stepSize > 0.0
        ? (number / stepSize).floor()
        : (number / stepSize).ceil()
    );
  }

  static List<double> _generateTickValues(
    final double tickStart,
    final double stepSize,
    final int tickCount,
  ) => List.generate(tickCount, (i) => (tickStart + (i * stepSize)).smooth);

  /// Potential steps available to the baseTen value of the data.
  static const _defaultSteps = [
    0.01,
    0.02,
    0.025,
    0.03,
    0.04,
    0.05,
    0.06,
    0.07,
    0.08,
    0.09,
    0.1,
    0.15,
    0.2,
    0.25,
    0.3,
    0.4,
    0.5,
    0.6,
    0.7,
    0.8,
    0.9,
    1.0,
    2.0,
    2.50,
    3.0,
    4.0,
    5.0,
    6.0,
    7.0,
    8.0,
    9.0
  ];
}
