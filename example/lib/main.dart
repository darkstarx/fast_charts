import 'dart:math';

import 'package:bar_charts/bar_charts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


void main()
{
  runApp(const MyApp());
}


class MyApp extends StatelessWidget
{
  const MyApp({ super.key });

  @override
  Widget build(final BuildContext context)
  {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      routes: {
        '/example': (context) => const ExamplePage(),
      },
      initialRoute: '/example',
    );
  }
}


class ExamplePage extends StatefulWidget
{
  const ExamplePage({ super.key });

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}


class _ExamplePageState extends State<ExamplePage>
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
    'alpha', 'beta', 'gamma', 'theta', 'meta', 'brutto', 'robotics', 'muntaro',
    'slavyanska jidica', 'barsuk', 'barsuchya nora', 'virginia', 'baalbek',
    'motorolla', 'munchausen', 'baron', 'vagon', 'padma', 'padla', 'princess',
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
        data: { d[0]: rndInt, d[1]: rndInt, d[2]: rndInt, d[3]: rndInt, d[4]: rndInt },
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
      appBar: AppBar(title: const Text('Example')),
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
        child: BarChart(
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
