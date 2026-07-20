import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _currency = NumberFormat.currency(locale: 'es_MX', symbol: r'$');
  static final _shortDate = DateFormat('d MMM', 'es_MX');

  static String money(num value) => _currency.format(value);

  static String shortDate(DateTime date) => _shortDate.format(date);
}
