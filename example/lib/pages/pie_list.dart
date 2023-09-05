import 'dart:math';

import 'package:fast_charts/fast_charts.dart';
import 'package:flutter/material.dart';


class PieListPage extends StatelessWidget
{
  static final random = Random();

  static int generateRndInt({
    final int min = 0,
    final int max = 100,
  }) => min + random.nextInt(max - min + 1);

  static int get rndInt => generateRndInt(min: 20, max: 100);

  static const names = [
    'alpha', 'beta', 'gamma', 'delta', 'epsilon', 'zeta', 'eta', 'theta',
    'iota', 'kappa', 'lambda', 'mu', 'nu', 'xi', 'omicron', 'pi', 'rho',
    'sigma', 'tau', 'upsilon', 'phi', 'chi', 'psi', 'omega',
  ];

  static double getMeasure(final int value) => value.toDouble();

  static ChartLabel getLabel(final double percent, final Color color)
  {
    final brightness = ThemeData.estimateBrightnessForColor(color);
    return ChartLabel('$percent%',
      style: TextStyle(
        fontSize: 9,
        fontWeight: brightness == Brightness.dark
          ? FontWeight.w700
          : FontWeight.w500,
        color: brightness == Brightness.dark
          ? Colors.white
          : Colors.black,
      ),
      position: LabelPosition.inside,
      alignment: Alignment.bottomLeft,
    );
  }

  static Series<String, ({Color color, int value})> get generateRndSeries
  {
    final length = generateRndInt(min: 3, max: 7);
    final c = Colors.accents.toList();
    final colors = List.generate(length, (_) => c.removeAt(random.nextInt(c.length)));
    final n = PieListPage.names.toList();
    final names = List.generate(length, (_) => n.removeAt(random.nextInt(n.length)));
    return Series(
      data: { for (var i = 0; i < length; ++i)
        names[i]: (color: colors[i], value: rndInt)
      },
      colorAccessor: (d, v) => v.color,
      measureAccessor: (v) => v.value.toDouble(),
      labelAccessor: (d, v, p) => getLabel(p, v.color),
    );
  }

  static final rndSeries = List.generate(100, (i) => generateRndSeries);

  const PieListPage({ super.key });

  @override
  Widget build(final BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(title: const Text('List of pie charts')),
      body: Scrollbar(
        child: GridView.builder(
          primary: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemBuilder: buildItem,
          itemCount: rndSeries.length,
        ),
      ),
    );
  }

  Widget buildItem(final BuildContext context, final int index)
  {
    final theme = Theme.of(context);
    final series = rndSeries[index];
    return Card(
      child: PieChart(
        data: series,
        padding: const EdgeInsets.all(16.0),
        strokes: StrokesConfig(color: theme.colorScheme.surface, inner: true),
      ),
    );
  }
}
