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
  static const colors1 = [
    Color(0xFFF48FB1),
    Color(0xFF69F0AE),
    Color(0xFF82B1FF),
    Color(0xFFFFD740),
  ];
  static const colors2 = [
    Color(0xFFF44336),
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFFFC107),
  ];

  static final data1 = colors1.map((color) => Series<String, int>(
    data: { for (final d in domains) d: rndInt },
    color: color,
    measureAccessor: getMeasure,
    labelAccessor: (value) => getLabel(value, color),
  )).toList();

  static final data2 = data1.indexed.map((r) => Series<String, int>(
    data: r.$2.data.map((key, value) => MapEntry(
      key,
      (value * random.nextDouble()).round(),
      // rndInt,
    )),
    color: colors2[r.$1],
    measureAccessor: getMeasure,
    labelAccessor: (value) => getLabel(value, colors2[r.$1]),
  )).toList();

  // static final data2 = data1.map((s) => Series<String, int>(
  //   data: s.data.map((key, value) => MapEntry(
  //     key,
  //     (value * random.nextDouble()).round(),
  //   )),
  //   color: s.color,
  //   measureAccessor: s.measureAccessor,
  //   labelAccessor: s.labelAccessor,
  // )).toList();

  // static final data2 = colors.followedBy([ Colors.purple ])
  //   .map((color) => Series<String, int>(
  //     data: { for (final d in domains) d: rndInt },
  //     color: color,
  //     measureAccessor: getMeasure,
  //     labelAccessor: (value) => getLabel(value, color),
  //   ))
  //   .toList();

  // static final data2 = colors.followedBy([ Colors.purple ])
  //   .map((color) => Series<String, int>(
  //     data: { for (final d in domains.followedBy([ 'zeta' ])) d: rndInt },
  //     color: color,
  //     measureAccessor: getMeasure,
  //     labelAccessor: (value) => getLabel(value, color),
  //   ))
  //   .toList();

  static double getMeasure(final int value) => value.toDouble();

  static ChartLabel getLabel(final int value, final Color color)
  {
    final brightness = ThemeData.estimateBrightnessForColor(color);
    return ChartLabel('$value',
      style: TextStyle(
        fontSize: 11,
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
          minTickSpacing: 40,
          barPadding: 10,
          barSpacing: 10,
          padding: const EdgeInsets.all(16.0),
          radius: const Radius.circular(16),
          animationDuration: const Duration(milliseconds: 350),
        ),
      ),
    );
  }

  late Data<String, int> _data;
}
