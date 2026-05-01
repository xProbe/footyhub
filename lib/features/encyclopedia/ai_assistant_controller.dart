import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/providers/api_provider.dart';

class AiAssistantController extends GetxController {
  var isLoading = false.obs;
  var messages = <Map<String, String>>[].obs; // Menyimpan riwayat chat
  final TextEditingController chatController = TextEditingController();

  void sendMessage() async {
    String text = chatController.text.trim();
    if (text.isEmpty) return;

    // 1. Tambahkan pesan user ke daftar
    messages.add({"role": "user", "text": text});
    chatController.clear();
    isLoading.value = true;

    // 2. Panggil Gemini AI
    String prompt =
        "Anda adalah asisten ahli akuarium AquaSmart. Jawablah pertanyaan berikut dengan singkat, ramah, dan informatif: $text";

    var response = await ApiProvider.askGemini(prompt);

    // 3. Masukkan jawaban AI
    if (response != null) {
      messages.add({"role": "ai", "text": response});
    } else {
      messages.add({
        "role": "ai",
        "text": "Maaf, saya sedang mengalami gangguan koneksi. Bisa diulangi?",
      });
    }

    isLoading.value = false;
  }
}
