import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../ai_assistant_controller.dart'; 

class AiAssistantSheet extends StatelessWidget {
  const AiAssistantSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final AiAssistantController aiC = Get.put(AiAssistantController());

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.tfBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Species Assistant',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          'Ask about fish care, compatibility & more',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.tfPlaceholder,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.tfBackground,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.tfBorder),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.tfPlaceholder,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 24),

            Expanded(
              child: Obx(() {
                if (aiC.messages.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: aiC.messages.length,
                  itemBuilder: (_, i) {
                    final msg = aiC.messages[i];
                    final isUser = msg['role'] == 'user';

                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.72,
                        ),
                        decoration: BoxDecoration(
                          color: isUser
                              ? AppColors.primary
                              : AppColors.tfBackground,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(14),
                            topRight: const Radius.circular(14),
                            bottomLeft: Radius.circular(isUser ? 14 : 0),
                            bottomRight: Radius.circular(isUser ? 0 : 14),
                          ),
                        ),
                        child: Text(
                          msg['text']!,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: isUser
                                ? AppColors.pureWhite
                                : AppColors.textDark,
                            height: 1.5,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            Obx(
              () => aiC.isLoading.value
                  ? const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'AI is typing...',
                          style: TextStyle(
                            color: AppColors.tfPlaceholder,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              decoration: const BoxDecoration(
                color: AppColors.pureWhite,
                border: Border(top: BorderSide(color: AppColors.tfBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.tfBackground,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.tfBorder),
                      ),
                      child: TextField(
                        controller: aiC.chatController,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textDark,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Ask about fish species...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.tfPlaceholder,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => aiC.sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => aiC.sendMessage(),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AppColors.seaGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: AppColors.pureWhite,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: AppColors.seaGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.chat_bubble_outline_rounded,
            color: AppColors.pureWhite,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Ask me anything about fish',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Get expert advice on species care, tank\ncompatibility, or water parameters',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.tfPlaceholder,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
