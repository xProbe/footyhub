import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import 'tools_controller.dart';

class ToolsView extends StatelessWidget {
  const ToolsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi Controller
    final ToolsController controller = Get.put(ToolsController());

    return Scaffold(
      backgroundColor:
          AppColors.pureWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // - Header -
              Text(
                'Tools',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Convert currency and time',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.tfPlaceholder,
                ),
              ),
              const SizedBox(height: 32),

              // - Currency -
              _buildCurrencyCard(controller),

              const SizedBox(height: 24),

              // - Clock -
              _buildWorldClockCard(controller),

              const SizedBox(
                height: 80,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // widget kurs
  Widget _buildCurrencyCard(ToolsController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tfBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // - Header -
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.seaGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.calculate_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Currency Converter',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Convert prices when buying aquarium equipment from international suppliers',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.tfPlaceholder,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.tfBorder),

          // - Body -
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputLabel('Amount'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.tfBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.tfBorder),
                  ),
                  child: TextField(
                    controller:
                        controller.amountController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppColors.textDark,
                    ),
                    decoration: const InputDecoration(
                      hintText: '0.00',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel('From'),
                          _buildRealDropdown(
                            controller,
                            true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel('To'),
                          _buildRealDropdown(
                            controller,
                            false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Button convert
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                      controller.convertCurrency(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'CONVERT',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Hasil convert
                Center(
                  child: Obx(
                    () => Text(
                      controller.conversionResult.value,
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.seaGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Fyi box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.seaGreen.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.lightbulb,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Common Equipment Prices',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildPriceRow('Heater (100W)', '\$25 - \$45'),
                      const SizedBox(height: 8),
                      _buildPriceRow('Filter (External)', '\$60 - \$120'),
                      const SizedBox(height: 8),
                      _buildPriceRow('LED Light', '\$35 - \$80'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget dropdown
  Widget _buildRealDropdown(ToolsController controller, bool isFrom) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.tfBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.tfBorder),
      ),
      child: Obx(
        () => DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: isFrom
                ? controller.selectedFrom.value
                : controller.selectedTo.value,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.tfPlaceholder,
            ),
            items: controller.currencies.map((String currency) {
              return DropdownMenuItem<String>(
                value: currency,
                child: Text(
                  currency,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                if (isFrom) {
                  controller.selectedFrom.value = newValue;
                } else {
                  controller.selectedTo.value = newValue;
                }
              }
            },
          ),
        ),
      ),
    );
  }

  // Widget clock
  Widget _buildWorldClockCard(ToolsController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tfBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.access_time,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'World Clock',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Coordinate with fish breeders and suppliers across different time zones',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.tfPlaceholder,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // lsit clock
          Obx(
            () => Column(
              children: [
                _buildTimeItem(
                  '🇬🇧',
                  'London, UK',
                  'Discus Farms',
                  controller.timeLondon.value,
                ),
                _buildTimeItem(
                  '🇮🇩',
                  'Jakarta (WIB)',
                  'Local Breeders',
                  controller.timeWIB.value,
                ),
                _buildTimeItem(
                  '🇮🇩',
                  'Makassar (WITA)',
                  'Shrimp Suppliers',
                  controller.timeWITA.value,
                ),
                _buildTimeItem(
                  '🇮🇩',
                  'Jayapura (WIT)',
                  'Coral Farms',
                  controller.timeWIT.value,
                ), 
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget helper
  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 12, color: AppColors.tfPlaceholder),
      ),
    );
  }
  
  Widget _buildPriceRow(String item, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          item,
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary),
        ),
        Text(
          price,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeItem(
    String flag,
    String title,
    String subtitle,
    String time,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.tfBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.tfBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.tfPlaceholder,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            time.isNotEmpty
                ? time.substring(0, 5)
                : '--:--', // Mengambil HH:mm saja dari HH:mm:ss
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w300,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
