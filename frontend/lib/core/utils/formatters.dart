import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  // Colones costarricenses: sin decimales (así se manejan los precios
  // en la práctica), símbolo ₡ ANTES del número (₡12.500, no 12.500 ₡),
  // separador de miles al estilo es_CR (punto).
  static final _currency = NumberFormat.currency(
    locale: 'es_CR',
    symbol: ' ₡',
    decimalDigits: 0,
    customPattern: '¤#,##0',
  );
  static final _shortDate = DateFormat('d MMM', 'es_MX');

  static String money(num value) => _currency.format(value);

  static String shortDate(DateTime date) => _shortDate.format(date);
}