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

  List<Series<String, int>> get rndSeries
  {
    final n = names.toList();
    final d = List.generate(5, (_) => n.removeAt(random.nextInt(n.length)));
    final result = [
      Series(
        data: { d[0]: rndInt, d[1]: rndInt, d[2]: rndInt, d[3]: rndInt, d[4]: rndInt },
        color: Colors.red,
        measureAccessor: (value) => value.toDouble(),
      ),
      Series(
        data: { d[0]: rndInt, d[1]: rndInt, d[2]: rndInt, d[3]: rndInt, d[4]: rndInt },
        color: Colors.green,
        measureAccessor: (value) => value.toDouble(),
      ),
      Series(
        data: { d[0]: rndInt, d[1]: rndInt, d[2]: rndInt, d[3]: rndInt, d[4]: rndInt },
        color: Colors.blue,
        measureAccessor: (value) => value.toDouble(),
      ),
      Series(
        data: { d[0]: rndInt, d[1]: rndInt, d[2]: rndInt, d[3]: rndInt, d[4]: rndInt },
        color: Colors.amber,
        measureAccessor: (value) => value.toDouble(),
      ),
    ];
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
    final series = [
      Series(
        data: { 'alpha': -300, 'beta': -10, 'gamma': 1, 'theta\nmeta\nbarbuletta': 76 },
        color: Colors.amber.withOpacity(0.5),
        measureAccessor: (value) => value.toDouble(),
      ),
    ];
    final number = NumberFormat.compact(locale: 'ru');
    return Scaffold(
      appBar: AppBar(title: const Text('Example')),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            children: List.generate(100, (i) => Card(
              child: SizedBox(
                height: 250,
                child: BarChart(
                  data: _data[i],
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
            )),
          ),
        ),
      ),
    );
  }

  late final List<List<Series<String, int>>> _data;
}
