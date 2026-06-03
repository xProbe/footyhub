import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final apiKey = 'e6d93cf7e0b13a701dff24f044b120d2';
  final baseUrl = 'https://v3.football.api-sports.io';
  
  print('--- Testing Standings for Season 2025 ---');
  try {
    final uri = Uri.parse('$baseUrl/standings?league=39&season=2025');
    final res = await http.get(uri, headers: {'x-apisports-key': apiKey});
    print('Status: ${res.statusCode}');
    final data = jsonDecode(res.body);
    final responseList = data['response'] as List?;
    print('Response size (2025): ${responseList?.length}');
    if (data['errors'] != null) {
      print('Errors (2025): ${data['errors']}');
    }
  } catch (e) {
    print('Error (2025): $e');
  }

  print('\n--- Testing Standings for Season 2024 ---');
  try {
    final uri = Uri.parse('$baseUrl/standings?league=39&season=2024');
    final res = await http.get(uri, headers: {'x-apisports-key': apiKey});
    print('Status: ${res.statusCode}');
    final data = jsonDecode(res.body);
    final responseList = data['response'] as List?;
    print('Response size (2024): ${responseList?.length}');
    if (data['errors'] != null) {
      print('Errors (2024): ${data['errors']}');
    }
  } catch (e) {
    print('Error (2024): $e');
  }

  print('\n--- Testing Fixtures for Season 2025 ---');
  try {
    final uri = Uri.parse('$baseUrl/fixtures?league=39&season=2025');
    final res = await http.get(uri, headers: {'x-apisports-key': apiKey});
    print('Status: ${res.statusCode}');
    final data = jsonDecode(res.body);
    final responseList = data['response'] as List?;
    print('Response size (2025): ${responseList?.length}');
  } catch (e) {
    print('Error (2025): $e');
  }
}
