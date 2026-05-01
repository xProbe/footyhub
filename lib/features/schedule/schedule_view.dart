import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import 'schedule_controller.dart';

class ScheduleView extends StatelessWidget {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    final ScheduleController c = Get.find<ScheduleController>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jadwal & zona waktu',
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Contoh laga: Arsenal vs Chelsea — kickoff dalam empat zona.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.tfPlaceholder,
              ),
            ),
            const SizedBox(height: 24),
            Obx(
              () => Table(
                border: TableBorder.all(color: AppColors.tfBorder),
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: AppColors.tfBackground),
                    children: [
                      _th('Laga'),
                      _th('London'),
                      _th('WIB'),
                      _th('WITA'),
                      _th('WIT'),
                    ],
                  ),
                  TableRow(
                    children: [
                      _td(
                        'Arsenal vs Chelsea\n${DateFormat('yyyy-MM-dd').format(c.kickoffUtc.value)}',
                      ),
                      _td(c.timeLondon.value),
                      _td(c.timeWib.value),
                      _td(c.timeWita.value),
                      _td(c.timeWit.value),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Kickoff (RFC3339 UTC): ${c.kickoffUtc.value.toIso8601String()}',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.softGray),
            ),
          ],
        ),
      ),
    );
  }

  Widget _th(String t) => Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          t,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: AppColors.primary,
          ),
        ),
      );

  Widget _td(String t) => Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          t,
          style: GoogleFonts.inter(fontSize: 13),
        ),
      );
}
