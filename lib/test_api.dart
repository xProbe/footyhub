import 'package:flutter/material.dart';
import 'data/providers/api_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('=============================================');
  print('PENGUJIAN API FOOTYHUB');
  print('=============================================\n');

  print('[1] Open-Meteo...');
  var weather = await ApiProvider.getWeather(-8.023, 110.334);
  if (weather != null && weather['current_weather'] != null) {
    print(
      'OK. Suhu: ${weather['current_weather']['temperature']} °C',
    );
  } else {
    print('Gagal.');
  }

  print('\n[2] ExchangeRate-API (base USD)...');
  var rates = await ApiProvider.getCurrencyRates();
  if (rates != null && rates['rates'] != null) {
    final idr = rates['rates']['IDR'];
    print('OK. 1 USD ≈ $idr IDR');
  } else {
    print('Gagal.');
  }

  print('\n[3] Gemini...');
  var aiResponse = await ApiProvider.askGemini(
    'Sebutkan satu klub EPL dalam satu kalimat.',
  );
  if (aiResponse != null) {
    print('OK. $aiResponse');
  } else {
    print('Gagal — periksa geminiKey.');
  }

  print('\nSelesai.');
}
