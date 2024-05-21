import 'dart:convert';
import 'package:http/http.dart' as http;

class ExchangeService {
  static const String apiUrl = 'https://api.frankfurter.app/latest';

  Future<double> getExchangeRate(String from, String to) async {
    final response = await http.get(Uri.parse('$apiUrl?from=$from&to=$to'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['rates'][to];
    } else {
      throw Exception('Failed to load exchange rate');
    }
  }
}
