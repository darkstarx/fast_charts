import 'package:flutter/material.dart';

import 'pages/bar_single.dart';
import 'pages/pie_list.dart';
import 'pages/pie_single.dart';
import 'pages/radial_stacked_bar_single.dart';
import 'pages/stacked_bar_list.dart';
import 'pages/stacked_bar_single.dart';


void main()
{
  runApp(const MyApp());
}


class MyApp extends StatefulWidget
{
  const MyApp({ super.key });

  @override
  State<MyApp> createState() => _MyAppState();
}


class _MyAppState extends State<MyApp>{
  @override
  Widget build(final BuildContext context)
  {
    return MaterialApp(
      theme: ThemeData.light(useMaterial3: true).copyWith(
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),
      themeMode: _themeMode,
      routes: {
        '/example': (context) => ExamplePage(
          themeMode: _themeMode,
          onThemeModeChanged: (value) => setState(() => _themeMode = value),
        ),
        '/example/grouped/single': (context) => const BarSinglePage(),
        '/example/stacked/single': (context) => const StackedBarSinglePage(),
        '/example/stacked/list': (context) => const StackedBarListPage(),
        '/example/pie/single': (context) => const PieSinglePage(),
        '/example/pie/list': (context) => const PieListPage(),
        '/example/radial/stacked/single': (context) =>
          const RadialStackedBarSinglePage(),
      },
      initialRoute: '/example',
    );
  }

  var _themeMode = ThemeMode.system;
}


class ExamplePage extends StatelessWidget
{
  final ThemeMode? themeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  bool isDark(final BuildContext context)
  {
    switch (themeMode) {
      case null:
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
      case ThemeMode.dark: return true;
      case ThemeMode.light: return false;
    }
  }

  const ExamplePage({
    super.key,
    this.themeMode,
    this.onThemeModeChanged,
  });

  @override
  Widget build(final BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(title: const Text('Example')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          const Spacer(),
          Center(child: SizedBox(
            width: 320,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pushNamed(
                    '/example/grouped/single',
                  ),
                  child: const Text('Single grouped bar chart'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pushNamed(
                    '/example/stacked/single',
                  ),
                  child: const Text('Single stacked bar chart'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pushNamed(
                    '/example/pie/single',
                  ),
                  child: const Text('Single pie chart'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pushNamed(
                    '/example/radial/stacked/single',
                  ),
                  child: const Text('Single radial stacked bar chart'),
                ),
                const Divider(),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pushNamed(
                    '/example/stacked/list',
                  ),
                  child: const Text('List of stacked bar charts'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pushNamed(
                    '/example/pie/list',
                  ),
                  child: const Text('List of pie charts'),
                ),
              ],
            ),
          )),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Dark mode', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 8.0),
              Switch(
                value: isDark(context),
                onChanged: onThemeModeChanged == null
                  ? null
                  : (value) => onThemeModeChanged!(
                      value ? ThemeMode.dark : ThemeMode.light
                    ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
