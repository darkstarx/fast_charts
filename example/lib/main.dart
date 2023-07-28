import 'package:flutter/material.dart';

import 'pages/list.dart';
import 'pages/single.dart';


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
        '/example/single': (context) => const SingleChartPage(),
        '/example/list': (context) => const ChartListPage(),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed('/example/single'),
                child: const Text('Single bar chart'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed('/example/list'),
                child: const Text('List of bar charts'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
