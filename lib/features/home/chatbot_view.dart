import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/widgets/glass_widgets.dart';
import 'chatbot_provider.dart';

class ChatbotView extends ConsumerStatefulWidget {
  const ChatbotView({super.key});

  @override
  ConsumerState<ChatbotView> createState() => _ChatbotViewState();
}

class _ChatbotViewState extends ConsumerState<ChatbotView> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatbotProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('AI PUNDIT ASSISTANT', style: GoogleFonts.orbitron(letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0A0A0C),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              ref.read(chatbotProvider.notifier).clearChat();
            },
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.white70),
            tooltip: 'Hapus Chat',
          ),
        ],
      ),
      body: Column(
        children: [
          // Message list area
          Expanded(
            child: chatState.messages.isEmpty
                ? _buildEmptyState(colorScheme.primary)
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: chatState.messages.length,
                    itemBuilder: (context, idx) {
                      final msg = chatState.messages[idx];
                      final isUser = msg.role == 'user';

                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isUser ? colorScheme.primary : const Color(0xFF141418),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isUser ? 16 : 0),
                              bottomRight: Radius.circular(isUser ? 0 : 16),
                            ),
                            border: Border.all(
                              color: isUser ? Colors.transparent : Colors.white.withOpacity(0.04),
                            ),
                          ),
                          child: Text(
                            msg.text,
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              color: isUser ? Colors.black : Colors.white70,
                              height: 1.5,
                              fontWeight: isUser ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Loader typing
          if (chatState.isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Asisten sedang mengetik...',
                  style: GoogleFonts.inter(color: colorScheme.primary.withOpacity(0.6), fontSize: 11, fontStyle: FontStyle.italic),
                ),
              ),
            ),
          // Message composer field
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: const BoxDecoration(
              color: Color(0xFF0A0A0C),
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GlassCard(
                    opacity: 0.05,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _msgCtrl,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Tanyakan tentang taktik, pemain, klasemen...',
                        hintStyle: GoogleFonts.inter(color: Colors.white30, fontSize: 13),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) {
                        final text = _msgCtrl.text;
                        ref.read(chatbotProvider.notifier).sendMessage(text);
                        _msgCtrl.clear();
                        _scrollToBottom();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    final text = _msgCtrl.text;
                    ref.read(chatbotProvider.notifier).sendMessage(text);
                    _msgCtrl.clear();
                    _scrollToBottom();
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor.withOpacity(0.3)),
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              color: primaryColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Tanya Apapun tentang Bola',
            style: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Asisten AI kami dapat menjawab taktik, info transfer pemain, statistik klasemen, dan detail laga lainnya.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white38,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
