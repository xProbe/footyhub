import 'package:get/get.dart';
import '../../data/services/exchange_rate_service.dart';

class FieldDetailController extends GetxController {
  final name = ''.obs;
  final vicinity = ''.obs;
  final priceIdr = 150000.obs;

  final selectedCurrency = 'USD'.obs;
  final convertedLabel = '—'.obs;
  final rates = <String, double>{}.obs;
  final loadingRates = false.obs;

  @override
  void onInit() {
    super.onInit();
    final a = Get.arguments as Map<String, dynamic>? ?? {};
    name.value = a['name']?.toString() ?? 'Lapangan';
    vicinity.value = a['vicinity']?.toString() ?? '';
    final p = a['priceIdr'];
    if (p is num) priceIdr.value = p.toInt();
    loadRates();
  }

  Future<void> loadRates() async {
    loadingRates.value = true;
    final r = await ExchangeRateService.ratesFromUsdBase();
    if (r != null) rates.assignAll(r);
    loadingRates.value = false;
    convert();
  }

  void onCurrencyChanged(String? v) {
    if (v == null) return;
    selectedCurrency.value = v;
    convert();
  }

  void convert() {
    final r = rates;
    if (r.isEmpty) {
      convertedLabel.value = '—';
      return;
    }
    final v = ExchangeRateService.idrToTarget(
      idrAmount: priceIdr.value.toDouble(),
      target: selectedCurrency.value,
      usdRates: r,
    );
    if (v == null) {
      convertedLabel.value = '—';
      return;
    }
    final sym = switch (selectedCurrency.value) {
      'USD' => '\$',
      'EUR' => '€',
      'GBP' => '£',
      _ => '',
    };
    convertedLabel.value = '$sym ${v.toStringAsFixed(2)}';
  }
}
