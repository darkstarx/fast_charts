import 'dart:math';

import 'package:fast_charts/fast_charts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class StackedBarListPage extends StatefulWidget
{
  const StackedBarListPage({ super.key });

  @override
  State<StackedBarListPage> createState() => _StackedBarListPageState();
}


class _StackedBarListPageState extends State<StackedBarListPage>
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

  static List<Series<String, int>> get rndSeries
  {
    const colors = [
      Color(0xFFF48FB1),
      Color(0xFF69F0AE),
      Color(0xFF82B1FF),
      Color(0xFFFFFF00),
    ];
    final n = names.toList();
    final d = List.generate(5, (_) => n.removeAt(random.nextInt(n.length)));
    final result = colors
      .map((color) => Series(
        data: { for (final domain in d) domain: rndInt },
        colorAccessor: (d, v) => color,
        measureAccessor: getMeasure,
        labelAccessor: (domain, value, percent) => getLabel(value, color),
      ))
      .toList();
    return result;
  }

  @override
  void initState()
  {
    super.initState();
    prepare();
  }

  Future<void> prepare() async
  {
    final data = await compute(
      (_) => List.generate(100, (_) => rndSeries),
      null,
    );
    _data = data;
    final body = Scrollbar(
      // child: await buildFullListView(),
      child: buildGenerativeListView(),
    );
    setState(() {
      _body = body;
    });
  }

  @override
  Widget build(final BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(title: const Text('List of stacked bar charts')),
      body: _body ?? const Center(child: CircularProgressIndicator()),
    );
  }

  Future<Widget> buildFullListView() async
  {
    final children = <Widget>[];
    for (var i = 0; i < _data!.length; ++i) {
      children.add(buildCard(i));
      await Future(() {});
    }
    return SingleChildScrollView(child: Column(children: children));
  }

  Widget buildGenerativeListView()
  {
    return ListView.builder(
      itemCount: _data!.length,
      itemBuilder: (context, index) => buildCard(index),
    );
  }

  Widget buildCard(final int index)
  {
    final number = NumberFormat.compact(locale: 'ru');
    return Card(
      child: SizedBox(
        height: 200,
        child: StackedBarChart(
          data: _data![index],
          measureFormatter: number.format,
          valueAxis: Axis.vertical,
          inverted: false,
          barPadding: 10,
          barSpacing: 10,
          padding: const EdgeInsets.all(16.0),
          radius: const Radius.circular(6),
        ),
      ),
    );
  }

  List<List<Series<String, int>>>? _data;
  Widget? _body;
}
