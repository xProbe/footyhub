import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/providers/api_provider.dart';

class ToolsController extends GetxController {
  var timeWIB = ''.obs;
  var timeWITA = ''.obs;
  var timeWIT = ''.obs;
  var timeLondon = ''.obs;

  Timer? _timer;

  var isLoadingCurrency = false.obs;
  var usdToIdr = 0.0.obs;
  var eurToIdr = 0.0.obs;
  var gbpToIdr = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _startTicking();
    fetchCurrencyRates();
  }

  void _startTicking() {
    _calculateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateTime();
    });
  }

  void _calculateTime() {
    DateTime nowUtc = DateTime.now().toUtc();
    timeWIB.value = DateFormat(
      'HH:mm:ss',
    ).format(nowUtc.add(const Duration(hours: 7)));
    timeWITA.value = DateFormat(
      'HH:mm:ss',
    ).format(nowUtc.add(const Duration(hours: 8)));
    timeWIT.value = DateFormat(
      'HH:mm:ss',
    ).format(nowUtc.add(const Duration(hours: 9)));
    timeLondon.value = DateFormat('HH:mm:ss').format(nowUtc);
  }

  Future<void> fetchCurrencyRates() async {
    isLoadingCurrency.value = true;
    var data = await ApiProvider.getCurrencyRates();

    if (data != null && data['rates'] != null) {
      final rates = Map<String, dynamic>.from(data['rates'] as Map);
      usdToIdr.value = (rates['IDR'] as num?)?.toDouble() ?? 0;
      final eurPerUsd = (rates['EUR'] as num?)?.toDouble();
      final gbpPerUsd = (rates['GBP'] as num?)?.toDouble();
      if (eurPerUsd != null && eurPerUsd > 0) {
        eurToIdr.value = usdToIdr.value / eurPerUsd;
      }
      if (gbpPerUsd != null && gbpPerUsd > 0) {
        gbpToIdr.value = usdToIdr.value / gbpPerUsd;
      }
    } else {
      Future.delayed(const Duration(milliseconds: 200), () {
        Get.snackbar('Error', 'Gagal memuat kurs');
      });
    }

    isLoadingCurrency.value = false;
  }

  final TextEditingController amountController = TextEditingController();
  var selectedFrom = 'USD'.obs;
  var selectedTo = 'IDR'.obs;
  var conversionResult = '0.00'.obs;

  final List<String> currencies = ['USD', 'EUR', 'GBP', 'IDR'];

  void convertCurrency() {
    double amount = double.tryParse(amountController.text) ?? 0.0;

    if (amount == 0.0) {
      conversionResult.value = '0.00';
      return;
    }

    double amountInIdr = 0.0;
    if (selectedFrom.value == 'USD') {
      amountInIdr = amount * usdToIdr.value;
    } else if (selectedFrom.value == 'EUR') {
      amountInIdr = amount * eurToIdr.value;
    } else if (selectedFrom.value == 'GBP') {
      amountInIdr = amount * gbpToIdr.value;
    } else {
      amountInIdr = amount;
    }

    double result = 0.0;
    if (selectedTo.value == 'USD') {
      result = amountInIdr / usdToIdr.value;
    } else if (selectedTo.value == 'EUR') {
      result = amountInIdr / eurToIdr.value;
    } else if (selectedTo.value == 'GBP') {
      result = amountInIdr / gbpToIdr.value;
    } else {
      result = amountInIdr;
    }

    String symbol = '';
    if (selectedTo.value == 'IDR') {
      symbol = 'Rp ';
    } else if (selectedTo.value == 'EUR') {
      symbol = '€';
    } else if (selectedTo.value == 'GBP') {
      symbol = '£';
    } else {
      symbol = '\$';
    }

    conversionResult.value = NumberFormat.currency(
      locale: selectedTo.value == 'IDR' ? 'id_ID' : 'en_US',
      symbol: symbol,
      decimalDigits: 2,
    ).format(result);
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
