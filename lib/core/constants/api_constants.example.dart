/// Salin file ini jadi `api_constants.dart` dan isi nilai nyata.
class ApiConstants {
  static const String authBaseUrl = 'http://10.0.2.2:3000/api';

  /// API-Sports / api-football (https://www.api-football.com)
  static const String footballBaseUrl = 'https://v3.football.api-sports.io';
  static const String footballApiKey = 'KUNCI_API_FOOTBALL';

  /// Google Gemini (chatbot pundit)
  static const String geminiKey = 'KUNCI_GOOGLE_GEMINI';

  /// Google Maps SDK + Places (Nearby Search)
  static const String googleMapsKey = 'KUNCI_GOOGLE_MAPS';

    /// ExchangeRate-API v6
  static const String exchangeRateBaseUrl = 
      'https://v6.exchangerate-api.com/v6';
  static const String exchangeRateApiKey = 'KUNCI_EXCHANGE_RATE';

  static bool isPlaceholder(String key) {
    final k = key.trim().toUpperCase();
    return k.isEmpty ||
        k.contains('MASUKKAN') ||
        k.contains('KUNCI') ||
        k.contains('PLACEHOLDER') ||
        k.contains('YOUR_API_KEY');
  }
}
