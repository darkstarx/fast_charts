import 'dart:math';

import 'package:bar_charts/bar_charts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class ChartListPage extends StatefulWidget
{
  const ChartListPage({ super.key });

  @override
  State<ChartListPage> createState() => _ChartListPageState();
}


class _ChartListPageState extends State<ChartListPage>
{
  static final random = Random();

  static int generateRndInt({
    final int min = 0,
    final int max = 100,
  }) => min + random.nextInt(max - min + 1);

  static int get rndInt
  {
    final z = random.nextBool();
    if (z) {
      final value = generateRndInt(min: -100, max: -50);
      return value == -50 ? 0 : value;
    } else {
      final value = generateRndInt(min: 50, max: 100);
      return value == 50 ? 0 : value;
    }
  }

  static const names = [
    'alpha', 'beta', 'gamma', 'delta', 'epsilon', 'zeta', 'eta', 'theta',
    'iota', 'kappa', 'lambda', 'mu', 'nu', 'xi', 'omicron', 'pi', 'rho',
    'sigma', 'tau', 'upsilon', 'phi', 'chi', 'psi', 'omega',
  ];

  static double getMeasure(final int value) => value.toDouble();

  static ChartLabel getLabel(final int value, final Color color)
  {
    final brightness = ThemeData.estimateBrightnessForColor(color);
    return ChartLabel('$value',
      style: TextStyle(
        fontSize: 9,
        color: brightness == Brightness.dark
          ? Colors.white
          : Colors.black,
      ),
      position: LabelPosition.inside,
      alignment: Alignment.center,
    );
  }

  List<Series<String, int>> get rndSeries
  {
    const colors = [ Colors.red, Colors.green, Colors.blue, Colors.amber ];
    final n = names.toList();
    final d = List.generate(5, (_) => n.removeAt(random.nextInt(n.length)));
    final result = colors
      .map((color) => Series(
        data: { for (final domain in d) domain: rndInt },
        color: color,
        measureAccessor: getMeasure,
        labelAccessor: (value) => getLabel(value, color),
      ))
      .toList();
    return result;
  }

  @override
  void initState()
  {
    super.initState();
    _data = List.generate(100, (_) => rndSeries);
  }

  @override
  Widget build(final BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(title: const Text('List of bar charts')),
      body: Scrollbar(
        // child: buildFullListView(context),
        child: buildGenerativeListView(context),
      ),
    );
  }

  Widget buildFullListView(final BuildContext context)
  {
    return SingleChildScrollView(child: Column(
      children: List.generate(_data.length, (i) => buildCard(context, i)),
    ));
  }

  Widget buildGenerativeListView(final BuildContext context)
  {
    return ListView.builder(
      itemCount: _data.length,
      itemBuilder: (context, index) => buildCard(context, index),
    );
  }

  Widget buildCard(final BuildContext context, final int index)
  {
    final number = NumberFormat.compact(locale: 'ru');
    return Card(
      child: SizedBox(
        height: 200,
        child: StackedBarChart(
          data: _data[index],
          measureFormatter: number.format,
          valueAxis: Axis.vertical,
          inverted: false,
          // crossAxisLabelsOffset: 4.0,
          // crossAxisWidth: 70,
          // minTickSpacing: 50,
          barPadding: 10,
          barSpacing: 10,
          padding: const EdgeInsets.all(16.0),
          radius: const Radius.circular(6),
        ),
      ),
    );
  }

  late final List<List<Series<String, int>>> _data;
}
