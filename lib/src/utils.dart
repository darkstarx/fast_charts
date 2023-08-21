import 'dart:math';


class Optional<T>
{
  T? get value => _value;

  bool get isEmpty => value == null;

  bool get isNotEmpty => value != null;

  Optional([ this._value ]);

  final T? _value;
}


/// Calculates percentage of [values] so the summ of the result values is always
/// exactly equal to 100.
///
/// If [values] is empty, it returns the empty list.
///
/// If some of [values] are negative, they are trated as positive values in the
/// calculation process. It means that negative values make a positive
/// contribution in the total summ of values, but the resulting percents for
/// them will be negative. E.g. the values of `[10, 0, -10]` will be converted
/// into the `[50.0%, 0.0%, -50.0%]`.
///
/// If the total summ of [values] is zero, it returns list of zeroes.
///
/// The accuracy of the result values is up to a tenth.
List<double> calcPercents(final List<double> values)
{
  if (values.isEmpty) return const [];
  final total = values.fold(0.0, (sum, val) => sum + val.abs());
  if (total == 0.0) return List.filled(values.length, 0.0);
  final per = values.map((e) => (e * 1000 / total).floor());
  final sum = per.fold(0, (sum, val) => sum + val.abs());
  var remaind = 1000 - sum;
  if (remaind != 0) {
    final nonZero = values.where((e) => e != 0.0).length;
    final piece = max(remaind.abs() ~/ nonZero, 1) * remaind.sign;
    final res = List<double>.filled(values.length, 0.0);
    var i = 0;
    for (var p in per) {
      if (values[i] != 0.0) {
        if (remaind != 0) {
          res[i] = (p + piece * p.sign) / 10;
          remaind -= piece;
        } else {
          res[i] = p / 10;
        }
      }
      ++i;
    }
    return res;
  }
  return per.map((e) => e / 10).toList(growable: false);
}


/// Calculates the percent of [value] of [total] with accuracy up to a tenth.
double calcPercent(final double value, final double total)
{
  return (value * 1000 / total).floorToDouble() / 10;
}
