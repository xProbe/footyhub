import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import 'field_detail_controller.dart';

class FieldDetailView extends StatelessWidget {
  const FieldDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final FieldDetailController c = Get.find<FieldDetailController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail lapangan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 180,
                width: double.infinity,
                color: AppColors.tfBackground,
                child: const Icon(Icons.stadium_outlined, size: 72),
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => Text(
                c.name.value,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            Obx(
              () => Text(
                c.vicinity.value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.tfPlaceholder,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Fasilitas',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Rumput vinyl, loker, mushola, parkir motor, minimarket kecil.',
              style: GoogleFonts.inter(fontSize: 14, height: 1.45),
            ),
            const SizedBox(height: 24),
            Text(
              'Kalkulator sewa (per jam)',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => Text(
                'Harga dasar: Rp ${c.priceIdr.value}',
                style: GoogleFonts.inter(fontSize: 15),
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => DropdownButtonFormField<String>(
                value: c.selectedCurrency.value,
                decoration: const InputDecoration(
                  labelText: 'Konversi ke',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'USD', child: Text('USD')),
                  DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                  DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                ],
                onChanged: c.onCurrencyChanged,
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => c.loadingRates.value
                  ? const Center(child: CircularProgressIndicator())
                  : Text(
                      'Nilai tersedia: ${c.convertedLabel.value}',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.seaGreen,
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kurs dari ExchangeRate-API (base USD).',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.tfPlaceholder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
