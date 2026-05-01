import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/constants/api_constants.dart';

class ApiProvider {
  static Future<Map<String, dynamic>?> getWeather(
    double lat,
    double lng,
  ) async {
    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lng&current_weather=true',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Respons mentah ExchangeRate-API v4 (base sesuai path, mis. /USD).
  static Future<Map<String, dynamic>?> getCurrencyRates() async {
    try {
      final url = Uri.parse('${ApiConstants.exchangeRateBaseUrl}/USD');
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> askGemini(String promptText) async {
    if (ApiConstants.geminiKey == 'MASUKKAN_GEMINI_API_KEY_ANDA') {
      await Future.delayed(const Duration(seconds: 1));
      return 'Fitur AI belum dikonfigurasi (API Key belum ada). Namun secara dummy, ini adalah balasan dari FootyHub Assistant untuk pertanyaan Anda:\n\n"$promptText"\n\nSilakan masukkan API Key Gemini Anda di api_constants.dart agar saya bisa menjawab sungguhan.';
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: ApiConstants.geminiKey,
      );
      final content = [Content.text(promptText)];
      final response = await model.generateContent(content);
      return response.text;
    } catch (e) {
      return null;
    }
  }
}
