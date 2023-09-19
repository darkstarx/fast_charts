import 'dart:math';

import 'package:fast_charts/fast_charts.dart';
import 'package:flutter/material.dart';


class RadialStackedBarSinglePage extends StatefulWidget
{
  const RadialStackedBarSinglePage({ super.key });

  @override
  State<RadialStackedBarSinglePage> createState()
    => _RadialStackedBarSinglePageState();
}


typedef Data<D, T> = List<Series<D, T>>;

class _RadialStackedBarSinglePageState extends State<RadialStackedBarSinglePage>
{
  static const lblWidth = 58.0;
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
    Color(0xFFFFFF00),
  ];
  static const colors2 = [
    Color(0xFFF44336),
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFFFC107),
  ];

  static final data1 = colors1.map((color) => Series<String, int>(
    data: { for (final d in domains) d: rndInt },
    colorAccessor: (d, v) => color,
    measureAccessor: getMeasure,
    labelAccessor: (domain, value, percent) => getLabel(value, color),
  )).toList();

  static final data2 = data1.indexed.map((r) => Series<String, int>(
    data: r.$2.data.map((key, value) => MapEntry(
      key,
      value < 0 ? (value * random.nextDouble() / 2).round() : value,
      // random.nextDouble() > 0.7 ? 0 : value,
      // rndInt,
    )),
    colorAccessor: (d, v) => colors2[r.$1],
    measureAccessor: getMeasure,
    labelAccessor: (domain, value, percent) => getLabel(value, colors2[r.$1]),
  )).toList();

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
    _angle = -pi / 2;
    _holeSize = 96.0;
    _arcSpacing = 8.0;
    _roundStart = false;
    _roundEnd = true;
  }

  @override
  Widget build(final BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(title: const Text('Single radial stacked bar chart')),
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() {
          _data = _data == data1 ? data2 : data1;
        }),
        child: const Icon(Icons.published_with_changes),
      ),
    );
  }

  Widget get body
  {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [ controls, card ],
      ),
    );
  }

  Widget get controls
  {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text('Arcs', style: titleStyle),
          arcsControls,
          const Divider(height: 0.0),
          Text('Other', style: titleStyle),
          otherControls,
          const Divider(height: 0.0),
        ],
      ),
    );
  }

  Widget get arcsControls
  {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CheckboxListTile(
          title: const Text('Round start'),
          value: _roundStart,
          onChanged: (value) {
            if (value == null) return;
            setState(() => _roundStart = value);
          },
        ),
        CheckboxListTile(
          title: const Text('Round end'),
          value: _roundEnd,
          onChanged: (value) {
            if (value == null) return;
            setState(() => _roundEnd = value);
          },
        ),
        Row(children: [
          const SizedBox(width: lblWidth, child: Text('Spacing')),
          Expanded(child: Slider(
            min: 0.0,
            max: 16.0,
            value: _arcSpacing,
            onChanged: (value) => setState(() {
              _arcSpacing = value;
            }),
          )),
        ]),
      ],
    );
  }

  Widget get otherControls
  {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          const SizedBox(width: lblWidth, child: Text('Hole')),
          Expanded(child: Slider(
            min: 0.0,
            max: 128.0,
            value: _holeSize,
            onChanged: (value) => setState(() {
              _holeSize = value;
            }),
          )),
        ]),
      ],
    );
  }

  Widget get card
  {
    final theme = Theme.of(context);
    return Card(
      child: SizedBox(
        height: 300,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            final center = Offset(size.width / 2, size.height / 2);
            return GestureDetector(
              onPanStart: (details) {
                _panStartAngle = (details.localPosition - center).direction
                  - _angle;
              },
              onPanUpdate: (details) {
                final panAngle = (details.localPosition - center).direction;
                setState(() => _angle = panAngle - _panStartAngle);
              },
              child: RadialStackedBarChart(
                data: _data,
                angle: _angle,
                backgroundColor: theme.colorScheme.background,
                padding: const EdgeInsets.all(16.0),
                holeSize: _holeSize,
                arcSpacing: _arcSpacing,
                roundStart: _roundStart,
                roundEnd: _roundEnd,
                animationDuration: const Duration(milliseconds: 350),
              ),
            );
          }
        ),
      ),
    );
  }

  late Data<String, int> _data;
  late double _angle;
  late double _holeSize;
  late double _arcSpacing;
  late bool _roundStart;
  late bool _roundEnd;

  double _panStartAngle = 0.0;
}
