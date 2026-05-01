import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import 'pundit_controller.dart';

class PunditView extends StatefulWidget {
  const PunditView({super.key});

  @override
  State<PunditView> createState() => _PunditViewState();
}

class _PunditViewState extends State<PunditView> {
  final _field = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _field.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send(PunditController c) {
    final text = _field.text;
    if (text.trim().isEmpty) return;
    c.sendMessage(text);
    _field.clear();
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final PunditController c = Get.find<PunditController>();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.smart_toy_outlined, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pundit AI',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Gemini · tanya taktik, pemain, atau liga',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.tfPlaceholder,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(
              () => ListView.builder(
                controller: _scroll,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: c.messages.length,
                itemBuilder: (_, i) {
                  final m = c.messages[i];
                  final isUser = m['role'] == 'user';
                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * 0.82,
                      ),
                      decoration: BoxDecoration(
                        color: isUser
                            ? AppColors.seaGreen.withValues(alpha: 0.25)
                            : AppColors.tfBackground,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(14),
                          topRight: const Radius.circular(14),
                          bottomLeft: Radius.circular(isUser ? 14 : 4),
                          bottomRight: Radius.circular(isUser ? 4 : 14),
                        ),
                        border: Border.all(color: AppColors.tfBorder),
                      ),
                      child: Text(
                        m['text'] ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          height: 1.35,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Obx(
            () => c.isLoading.value
                ? const LinearProgressIndicator(minHeight: 2)
                : const SizedBox(height: 2),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _field,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Tulis pertanyaan…',
                      filled: true,
                      fillColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                    ),
                    onSubmitted: (_) => _send(c),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () => _send(c),
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
