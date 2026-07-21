import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  // Colones costarricenses: sin decimales (así se manejan los precios
  // en la práctica), símbolo ₡ ANTES del número (₡12.500, no 12.500 ₡),
  // separador de miles al estilo es_CR (punto).
  static final _currency = NumberFormat.currency(
    locale: 'es_CR',
    symbol: '₡',
    decimalDigits: 0,
    customPattern: '¤#,##0',
  );
  static final _shortDate = DateFormat('d MMM', 'es_CR');
  static final _shortDateTime = DateFormat('d MMM · h:mm a', 'es_CR');

  // Para compras a proveedores de China, que cotizan en dólares.
  static final _usd = NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2);

  static String money(num value) => _currency.format(value);

  static String usd(num value) => _usd.format(value);

  // .toLocal(): convierte a la hora del dispositivo (Costa Rica, si el
  // teléfono/PC está en esa zona horaria) — los timestamps de Supabase
  // llegan en UTC.
  static String shortDate(DateTime date) => _shortDate.format(date.toLocal());

  static String shortDateTime(DateTime date) => _shortDateTime.format(date.toLocal());
}