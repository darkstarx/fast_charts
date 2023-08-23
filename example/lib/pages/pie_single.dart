import 'dart:math';

import 'package:fast_charts/fast_charts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';


class PieSinglePage extends StatefulWidget
{
  const PieSinglePage({ super.key });

  @override
  State<PieSinglePage> createState() => _PieSinglePageState();
}


class _PieSinglePageState extends State<PieSinglePage>
{
  static final random = Random();

  static const domains = {
    'alpha': 0,
    'beta': 1,
    'gamma': 2,
    'delta': 3,
    'epsilon': 4,
  };
  static const colors1 = [
    Color(0xFFF48FB1),
    Color(0xFF69F0AE),
    Color(0xFF82B1FF),
    Color(0xFFFFFF00),
    Color(0xFFE040FB),
  ];
  static const colors2 = [
    Color(0xFFF44336),
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFFFC107),
    Color(0xFF9C27B0),
  ];
  static final data1 = { for (final d in domains.keys) d: rndInt };
  static final data2 = { for (final d in domains.keys) d: rndInt };

  static int get rndInt => generateRndInt(min: 300, max: 3000);

  static int generateRndInt({ final int min = 0, final int max = 100 })
    => min + random.nextInt(max - min + 1);

  static double getMeasure(final int value) => value.toDouble();

  @override
  void initState()
  {
    super.initState();
    _series = series1;
    _angle = 0.0;
  }

  @override
  Widget build(final BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(title: const Text('Single pie chart')),
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() {
          _series = _series.data == data1 ? series2 : series1;
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
          Text('Labels', style: titleStyle),
          labelControls,
          const Divider(height: 0.0),
          const SizedBox(height: 8.0),
          Text('Strokes', style: titleStyle),
          strokesControls,
          const Divider(height: 0.0),
        ],
      ),
    );
  }

  Widget get labelControls
  {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          Text('Visible', style: titleStyle),
          const Spacer(),
          Switch(
            value: _labelsVisible,
            onChanged: (value) => setState(() {
              _labelsVisible = value;
              _series = _series.copyWith();
            }),
          ),
        ]),
        Row(children: [
          Expanded(
            child: RadioListTile<LabelPosition>(
              title: const Text('Inside'),
              value: LabelPosition.inside,
              groupValue: _labelsPosition,
              onChanged: _labelsVisible ? setLabelPosition : null,
            ),
          ),
          Expanded(
            child: RadioListTile<LabelPosition>(
              title: const Text('Outside'),
              value: LabelPosition.outside,
              groupValue: _labelsPosition,
              onChanged: _labelsVisible ? setLabelPosition : null,
            ),
          ),
        ]),
        Row(children: [
          const SizedBox(width: 52.0, child: Text('Depth')),
          if (_labelsPosition == LabelPosition.inside) Expanded(child: Slider(
            min: -1.0,
            max: 1.0,
            value: _labelsAlignment.y,
            onChanged: _labelsVisible ? setDepth : null,
          )),
          if (_labelsPosition == LabelPosition.outside) Expanded(child: Slider(
            min: 0.0,
            max: 24.0,
            value: _labelsOffset,
            onChanged: _labelsVisible ? setlabelsOffset : null,
          )),
        ]),
        Row(children: [
          const SizedBox(width: 52.0, child: Text('Pitch')),
          Expanded(child: Slider(
            min: -1.0,
            max: 1.0,
            value: _labelsAlignment.x,
            onChanged: _labelsVisible ? setPitch : null,
          )),
        ]),
      ],
    );
  }

  Widget get strokesControls
  {
    final theme = Theme.of(context);
    final defaultColor = theme.colorScheme.surface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          Expanded(
            child: CheckboxListTile(
              title: const Text('Inner'),
              value: _strokes?.inner ?? false,
              onChanged: (value) => setState(() {
                final strokes = _strokes ?? StrokesConfig(
                  color: defaultColor,
                );
                _strokes = strokes.copyWith(
                  inner: value,
                );
              }),
            ),
          ),
          Expanded(
            child: CheckboxListTile(
              title: const Text('Outer'),
              value: _strokes?.outer ?? false,
              onChanged: (value) => setState(() {
                final strokes = _strokes ?? StrokesConfig(
                  color: defaultColor,
                );
                _strokes = strokes.copyWith(
                  outer: value,
                );
              }),
            ),
          ),
        ]),
        Row(children: [
          const SizedBox(width: 52.0, child: Text('Width')),
          Expanded(child: Slider(
            min: 0.5,
            max: 5.0,
            value: _strokes?.width ?? 1.0,
            onChanged: _strokes?.effective ?? false
              ? (value) => setState(() {
                  final strokes = _strokes ?? StrokesConfig(
                    color: defaultColor,
                  );
                  _strokes = strokes.copyWith(
                    width: value,
                  );
                })
              : null,
          )),
        ]),
        Row(children: [
          const SizedBox(width: 52.0, child: Text('Color')),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: Material(
                color: _strokes?.color ?? defaultColor,
                child: InkWell(
                  onTap: () async {
                    final strokes = _strokes ?? StrokesConfig(
                      color: defaultColor,
                    );
                    final color = await pickColor(strokes.color);
                    if (color == null) return;
                    setState(() => _strokes = strokes.copyWith(
                      color: color,
                    ));
                  },
                  child: Container(
                    height: 32.0,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 2.0,
                      )
                    ),
                  )
                ),
              ),
            ),
          ),
        ]),
      ],
    );
  }

  Widget get card
  {
    return Card(
      child: SizedBox(
        height: 348,
        child: LayoutBuilder(builder: (context, constraints) {
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
            child: PieChart(
              data: _series,
              angle: _angle,
              labelsOffset: _labelsOffset,
              padding: _labelsVisible && _labelsPosition == LabelPosition.outside
                ? const EdgeInsets.all(42.0)
                : const EdgeInsets.all(8.0),
              strokes: _strokes,
              animationDuration: const Duration(milliseconds: 350),
            ),
          );
        }),
      ),
    );
  }

  Series<String, int> get series1 => Series<String, int>(
    data: data1,
    colorAccessor: (domain, value) => colors1[domains[domain]!],
    measureAccessor: getMeasure,
    labelAccessor: (domain, value, percent) => getLabel(
      value, percent, colors1[domains[domain]!]
    ),
  );

  Series<String, int> get series2 => Series<String, int>(
    data: data2,
    colorAccessor: (domain, value) => colors2[domains[domain]!],
    measureAccessor: getMeasure,
    labelAccessor: (domain, value, percent) => getLabel(
      value, percent, colors2[domains[domain]!]
    ),
  );

  ChartLabel? getLabel(final int value, final double percent, final Color color)
  {
    if (!_labelsVisible) return null;
    final brightness = _labelsPosition == LabelPosition.outside
      ? Theme.of(context).brightness
      : ThemeData.estimateBrightnessForColor(color);
    return ChartLabel('$value',
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: brightness == Brightness.dark
          ? Colors.white
          : Colors.black,
      ),
      position: _labelsPosition,
      alignment: _labelsAlignment,
    );
  }

  Future<Color?> pickColor(final Color value) async
  {
    Color? result;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: value,
            onColorChanged: (value) => result = value,
          ),
          // Use Material color picker:
          //
          // child: MaterialPicker(
          //   pickerColor: pickerColor,
          //   onColorChanged: changeColor,
          //   showLabel: true, // only on portrait mode
          // ),
          //
          // Use Block color picker:
          //
          // child: BlockPicker(
          //   pickerColor: currentColor,
          //   onColorChanged: changeColor,
          // ),
          //
          // child: MultipleChoiceBlockPicker(
          //   pickerColors: currentColors,
          //   onColorsChanged: changeColors,
          // ),
        ),
        actions: [
          ElevatedButton(
            child: const Text('Got it'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
    return result;
  }

  void setLabelPosition(final LabelPosition? value)
  {
    if (value == null) return;
    setState(() {
      _labelsPosition = value;
      _series = _series.copyWith();
    });
  }

  void setDepth(final double value)
  {
    setState(() {
      _labelsAlignment = Alignment(
        _labelsAlignment.x,
        value,
      );
      _series = _series.copyWith();
    });
  }

  void setlabelsOffset(final double value)
  {
    setState(() {
      _labelsOffset = value;
    });
  }

  void setPitch(final double value)
  {
    setState(() {
      _labelsAlignment = Alignment(
        value,
        _labelsAlignment.y,
      );
      _series = _series.copyWith();
    });
  }

  late Series<String, int> _series;
  late double _angle;

  bool _labelsVisible = true;
  LabelPosition _labelsPosition = LabelPosition.outside;
  Alignment _labelsAlignment = Alignment.center;
  double _labelsOffset = 4.0;
  double _panStartAngle = 0.0;
  StrokesConfig? _strokes;
}
