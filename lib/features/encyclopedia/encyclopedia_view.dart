import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/species_model.dart';
import 'encyclopedia_controller.dart';
// Import bottom sheets (Kita akan buat filenya di langkah selanjutnya)
import 'widgets/species_detail_sheet.dart';
import 'widgets/ai_assistant_sheet.dart';

class EncyclopediaView extends StatelessWidget {
  const EncyclopediaView({super.key});

  @override
  Widget build(BuildContext context) {
    // Memanggil Controller yang sudah terkoneksi dengan API
    final EncyclopediaController controller = Get.put(EncyclopediaController());

    return SafeArea(
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Encyclopedia',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Discover marine species',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AppColors.tfPlaceholder,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.tfBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.tfBorder),
                        ),
                        child: TextField(
                          onChanged: (val) => controller.filterData(
                            val,
                            controller.selectedCategory.value,
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textDark,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search species...',
                            hintStyle: GoogleFonts.inter(
                              color: AppColors.tfPlaceholder,
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: AppColors.tfPlaceholder,
                              size: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Obx(
                          () => Row(
                            children:
                                [
                                      'All',
                                      'Least Concern',
                                      'Vulnerable',
                                      'Endangered',
                                      'Near Threatened',
                                    ]
                                    .map(
                                      (category) => _buildFilterChip(
                                        category,
                                        controller,
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              Obx(() {
                if (controller.isLoading.value) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }

                if (controller.filteredList.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: AppColors.tfPlaceholder,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No species found',
                            style: GoogleFonts.inter(
                              color: AppColors.tfPlaceholder,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _SpeciesCard(
                          species: controller.filteredList[index],
                          controller: controller,
                        ),
                      ),
                      childCount: controller.filteredList.length,
                    ),
                  ),
                );
              }),
            ],
          ),

          Positioned(
            right: 24,
            bottom: 24,
            child: GestureDetector(
              onTap: () {
                Get.bottomSheet(
                  const AiAssistantSheet(),
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                );
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.seaGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.pureWhite,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, EncyclopediaController controller) {
    final bool isSelected = controller.selectedCategory.value == label;
    return GestureDetector(
      onTap: () => controller.filterData(controller.searchQuery.value, label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.pureWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.tfBorder,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppColors.pureWhite : AppColors.tfPlaceholder,
          ),
        ),
      ),
    );
  }
}

class _SpeciesCard extends StatelessWidget {
  final SpeciesModel species;
  final EncyclopediaController controller;

  const _SpeciesCard({required this.species, required this.controller});

  Color get _levelColor {
    switch (species.difficulty) {
      case 'Endangered':
      case 'Critically Endangered':
        return AppColors.dangerRed;
      case 'Vulnerable':
      case 'Near Threatened':
        return AppColors.coralOrange;
      case 'Least Concern':
        return AppColors.seaGreen;
      default:
        return AppColors
            .primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.bottomSheet(
          SpeciesDetailSheet(species: species),
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.tfBorder),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: Image.network(
                    species.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.aquaMist,
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: AppColors.tfPlaceholder,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
                // Badge level
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      species.difficulty.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _levelColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () => controller.toggleBookmark(species.id),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                      ),
                      child: Obx(() {
                        var currentSpecies = controller.filteredList.firstWhere(
                          (s) => s.id == species.id,
                        );
                        return Icon(
                          currentSpecies.isBookmarked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: currentSpecies.isBookmarked
                              ? AppColors.dangerRed
                              : AppColors.pureWhite,
                          size: 18,
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    species.name,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    species.family,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: AppColors.tfPlaceholder,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    species.description,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textDark.withValues(alpha: 0.75),
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
