import 'package:flutter/material.dart';

import 'pages/bar_single.dart';
import 'pages/stacked_bar_list.dart';
import 'pages/stacked_bar_single.dart';


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
        '/example/bar/single': (context) => const BarSinglePage(),
        '/example/stacked/single': (context) => const StackedBarSinglePage(),
        '/example/stacked/list': (context) => const StackedBarListPage(),
      },
      initialRoute: '/example',
    );
  }
}


class ExamplePage extends StatelessWidget
{
  const ExamplePage({ super.key });

  @override
  Widget build(final BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(title: const Text('Example')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: SizedBox(
            width: 320,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pushNamed(
                    '/example/bar/single',
                  ),
                  child: const Text('Single bar chart'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pushNamed(
                    '/example/stacked/single',
                  ),
                  child: const Text('Single stacked bar chart'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pushNamed(
                    '/example/stacked/list',
                  ),
                  child: const Text('List of stacked bar charts'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
