// lib/currency_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  // PENTING: Ganti dengan API key Anda sendiri
  // Dapatkan gratis di: https://www.exchangerate-api.com/
  static const String _apiKey = '37b08bbf3da1e28b12b1eb49';
  static const String _apiBaseUrl = 'https://v6.exchangerate-api.com/v6';

  /// Mengambil nilai tukar mata uang dari [fromCurrency] ke [toCurrency].
  /// Mengembalikan nilai rate atau null jika gagal.
  Future<double?> getExchangeRate(
    String fromCurrency,
    String toCurrency,
  ) async {
    try {
      // Endpoint untuk mendapatkan rate dari currency tertentu
      final url = Uri.parse('$_apiBaseUrl/$_apiKey/pair/$fromCurrency/$toCurrency');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        // Cek apakah request berhasil
        if (jsonResponse['result'] == 'success') {
          return (jsonResponse['conversion_rate'] as num).toDouble();
        } else {
          print('API Error: ${jsonResponse['error-type']}');
          return null;
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching exchange rate: $e');
      return null;
    }
  }

  /// Mengambil semua rate dari base currency (opsional - untuk efisiensi)
  Future<Map<String, double>?> getAllRates(String baseCurrency) async {
    try {
      final url = Uri.parse('$_apiBaseUrl/$_apiKey/latest/$baseCurrency');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        if (jsonResponse['result'] == 'success') {
          final rates = jsonResponse['conversion_rates'] as Map<String, dynamic>;
          return rates.map((key, value) => MapEntry(key, (value as num).toDouble()));
        }
      }
      return null;
    } catch (e) {
      print('Error fetching all rates: $e');
      return null;
    }
  }
}