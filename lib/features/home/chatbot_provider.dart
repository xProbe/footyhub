import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/api_provider.dart';

class ChatMessage {
  final String role; // 'user' or 'assistant'
  final String text;

  ChatMessage({required this.role, required this.text});
}

class ChatbotState {
  final List<ChatMessage> messages;
  final bool isLoading;

  ChatbotState({
    this.messages = const [],
    this.isLoading = false,
  });

  ChatbotState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
  }) {
    return ChatbotState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChatbotNotifier extends StateNotifier<ChatbotState> {
  ChatbotNotifier() : super(ChatbotState());

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(role: 'user', text: text.trim());
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    try {
      final prompt = "Anda adalah asisten pundit sepak bola ahli bernama FootyHub AI. Jawablah pertanyaan berikut dengan singkat, ramah, analitis, dan informatif: $text";
      final responseText = await ApiProvider.askGemini(prompt);
      
      final assistantMessage = ChatMessage(
        role: 'assistant',
        text: responseText ?? 'Maaf, saya sedang mengalami gangguan koneksi. Bisa diulangi?',
      );

      state = state.copyWith(
        messages: [...state.messages, assistantMessage],
        isLoading: false,
      );
    } catch (e) {
      final errorMessage = ChatMessage(
        role: 'assistant',
        text: 'Terjadi kesalahan sistem: $e',
      );
      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isLoading: false,
      );
    }
  }

  void clearChat() {
    state = ChatbotState();
  }
}

final chatbotProvider = StateNotifierProvider<ChatbotNotifier, ChatbotState>((ref) {
  return ChatbotNotifier();
});
