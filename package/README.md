# Fast Charts library
This is a set of widgets to render different customizable charts quickly. You can render tens of diagrams per frame with no janks. Charts can also animate changes in compatible data series.

## Features
- Provides fast rendering of
<table>
  <tr>
    <th>Grouped bar charts</th>
    <th>Stacked bar charts</th>
    <th>Radial stacked bar charts</th>
    <th>Pie charts</th>
  </tr>
  <tr>
    <td><img width="250" alt="grouped" src="https://raw.githubusercontent.com/darkstarx/fast_charts/main/media/grouped.png"></td>
    <td><img width="250" alt="stacked" src="https://raw.githubusercontent.com/darkstarx/fast_charts/main/media/stacked.png"></td>
    <td><img width="250" alt="radial" src="https://raw.githubusercontent.com/darkstarx/fast_charts/main/media/radial.png"></td>
    <td><img width="250" alt="pie" src="https://raw.githubusercontent.com/darkstarx/fast_charts/main/media/pie.png"></td>
  </tr>
</table>

- Horizontal and vertical orientations of bar charts.
- Autofit or scrolling bar charts.
- Inverting the main scale of bar charts.
- Animation of changes in compatible data series.
<table>
  <tr>
    <th>Grouped bar charts</th>
    <th>Stacked bar charts</th>
    <th>Radial stacked bar charts</th>
    <th>Pie charts</th>
  </tr>
  <tr>
    <td><img width="250" alt="grouped" src="https://raw.githubusercontent.com/darkstarx/fast_charts/main/media/anim/grouped.gif"></td>
    <td><img width="250" alt="stacked" src="https://raw.githubusercontent.com/darkstarx/fast_charts/main/media/anim/stacked.gif"></td>
    <td><img width="250" alt="radial" src="https://raw.githubusercontent.com/darkstarx/fast_charts/main/media/anim/radial.gif"></td>
    <td><img width="250" alt="pie" src="https://raw.githubusercontent.com/darkstarx/fast_charts/main/media/anim/pie.gif"></td>
  </tr>
</table>

- Different customization including colors, shapes and labels.

<img width="250" alt="grouped" src="https://raw.githubusercontent.com/darkstarx/fast_charts/main/media/customization.gif">


## Getting started

Import the following package:
```dart
import 'package:fast_charts/fast_charts.dart';
```
Prepare the data and pass it to the chart widget:
```dart
final data = Series(
  data: { 'alpha': 11, 'beta': 17, 'gamma': 41 },
  colorAccessor: (domain, value) => colors[domain],
  measureAccessor: (value) => value.toDouble(),
  labelAccessor: (domain, value, percent) => ChartLabel('${percent}%',
    style: TextStyle(fontSize: 10),
  ),
);
return PieChart(data: data);
```

## Preparing the data

Pie charts require a single series wheras bar charts can be provided with several series of data. Each series represents a set of values, each value corresponds to the specivic domain (usually X-axis) and represents some measure (usually Y-axis).
```dart
final data = {
  DateTime(2023, 1): (income: 47300, expense: 15000),
  DateTime(2023, 2): (income: 81000, expense: 14500),
  DateTime(2023, 3): (income: 32050, expense: 37400),
};
final expenses = Series(
  data: data,
  measureAccessor: (value) => value.expense.toDouble(),
  colorAccessor: (domain, value) => Colors.red,
);
final incomes = Series(
  data: data,
  measureAccessor: (value) => value.income.toDouble(),
  colorAccessor: (domain, value) => Colors.green,
);
```

## Customizing a series

You can choose the color of each value in series depending on domain or value or both of them. E.g. for pie chart you'll probably need to chose divverent colors for every value, whereas for stacked bar chart you'll prefer choose the color for each series. Anyway, you have to make choice every time the series asks you the color in the special functor `colorAccessor`.
```dart
final incomes = Series(
  data: data,
  measureAccessor: (value) => value.income.toDouble(),
  colorAccessor: (domain, value) => value.income < value.expense ? Colors.amber : Colors.green,
);
```

You may also specify the style of labels. If you don't do that, there won't be any labels on the diagram, but if you provide the series with the `labelAccessor` functor, you can choose label position, style and text. The `labelAccessor` provide you with domain, value and percent of total sum of values among the series (can be useful in pie charts).
```dart
final data = {
  DateTime(2023, 1): (income: 47300, expense: 15000, color: Colors.redAccent),
  DateTime(2023, 2): (income: 81000, expense: 14500, color: Colors.greenAccent),
  DateTime(2023, 3): (income: 32050, expense: 37400, color: Colors.blueAccent),
};
final expenses = Series(
  data: data,
  measureAccessor: (value) => value.expense.toDouble(),
  colorAccessor: (domain, value) => value.color,
  labelAccessor: (domain, value, percent) => ChartLabel('$percent%',
    style: TextStyle(
      fontSize: 11,
      color: ThemeData.estimateBrightnessForColor(value.color) == Brightness.dark
        ? Colors.white
        : Colors.black,
    ),
    position: LabelPosition.inside,
    alignment: Alignment.center,
  ),
);
```

You can find other customizations in the `/example` folder.
