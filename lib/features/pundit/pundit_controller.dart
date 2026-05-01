import 'package:get/get.dart';
import '../../data/providers/api_provider.dart';

class PunditController extends GetxController {
  var isLoading = false.obs;
  var messages = <Map<String, String>>[].obs;

  Future<void> sendMessage(String text) async {
    final t = text.trim();
    if (t.isEmpty) return;

    messages.add({'role': 'user', 'text': t});
    isLoading.value = true;

    final prompt =
        'Anda adalah pundit sepak bola FootyHub. Jawab singkat, analitis, ramah. Pertanyaan: $t';

    final response = await ApiProvider.askGemini(prompt);

    if (response != null) {
      messages.add({'role': 'ai', 'text': response});
    } else {
      messages.add({
        'role': 'ai',
        'text': 'Maaf, layanan AI sedang sulit dijangkau. Cek kunci Gemini.',
      });
    }

    isLoading.value = false;
  }
}
