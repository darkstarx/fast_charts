import 'dart:math';

import 'package:bar_charts/bar_charts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class SingleChartPage extends StatefulWidget
{
  const SingleChartPage({ super.key });

  @override
  State<SingleChartPage> createState() => _SingleChartPageState();
}


typedef Data<D, T> = List<Series<D, T>>;

class _SingleChartPageState extends State<SingleChartPage>
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

  static const domains = [ 'alpha', 'beta', 'gamma', 'delta', 'epsilon' ];
  static const colors = [
    Colors.redAccent,
    Colors.greenAccent,
    Colors.blueAccent,
    Colors.amberAccent,
  ];

  static final data1 = colors.map((color) => Series<String, int>(
    data: { for (final d in domains) d: rndInt },
    color: color,
    measureAccessor: getMeasure,
    labelAccessor: (value) => getLabel(value, color),
  )).toList();

  static final data2 = colors.map((color) => Series<String, int>(
    data: { for (final d in domains) d: rndInt },
    color: color,
    measureAccessor: getMeasure,
    labelAccessor: (value) => getLabel(value, color),
  )).toList();

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

  @override
  void initState()
  {
    super.initState();
    _data = data1;
  }

  @override
  Widget build(final BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(title: const Text('Single chart')),
      body: buildCard(context, data1),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() {
          _data = _data == data1 ? data2 : data1;
        }),
        child: const Icon(Icons.published_with_changes),
      ),
    );
  }

  Widget buildCard(final BuildContext context, final Data<String, int> data)
  {
    final number = NumberFormat.compact(locale: 'ru');
    return Card(
      child: SizedBox(
        height: 300,
        child: BarChart(
          data: _data,
          measureFormatter: number.format,
          valueAxis: Axis.vertical,
          inverted: false,
          // crossAxisLabelsOffset: 4.0,
          // crossAxisWidth: 70,
          minTickSpacing: 40,
          barPadding: 10,
          barSpacing: 10,
          padding: const EdgeInsets.all(16.0),
          radius: const Radius.circular(6),
        ),
      ),
    );
  }

  late Data<String, int> _data;
}
