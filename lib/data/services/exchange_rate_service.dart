import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

/// Kurs dari base mata uang (mis. IDR) ke USD, EUR, GBP via ExchangeRate-API v4.
class ExchangeRateService {
  static Future<Map<String, double>?> ratesFromUsdBase() async {
    final uri = Uri.parse('${ApiConstants.exchangeRateBaseUrl}/${ApiConstants.exchangeRateApiKey}/latest/USD');
    try {
      final res =
          await http.get(uri).timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final rates = data['conversion_rates'] as Map<String, dynamic>?; // v6 uses conversion_rates
      if (rates == null) return null;
      return rates.map((k, v) => MapEntry(k, (v as num).toDouble()));
    } catch (_) {
      return null;
    }
  }

  /// Mengonversi harga dalam IDR ke mata uang target memakai map rates (base USD).
  /// [usdRates]: nilai seperti respons API — `IDR` = rupiah per 1 USD.
  static double? idrToTarget({
    required double idrAmount,
    required String target, // USD, EUR, GBP
    required Map<String, double> usdRates,
  }) {
    final idrPerUsd = usdRates['IDR'];
    if (idrPerUsd == null || idrPerUsd <= 0) return null;
    final amountUsd = idrAmount / idrPerUsd;
    final targetPerUsd = usdRates[target];
    if (targetPerUsd == null || targetPerUsd <= 0) return null;
    return amountUsd * targetPerUsd;
  }
}
