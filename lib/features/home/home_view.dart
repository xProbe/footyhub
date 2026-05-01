import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:footyhub/features/home/home_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeC = Get.find<HomeController>();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () => Text(
                          'Halo, ${homeC.userName.value}',
                          style: GoogleFonts.inter(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      Text(
                        'Berita & jadwal · goyangkan HP untuk refresh',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.tfPlaceholder,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => Get.toNamed(Routes.CONVERSION),
                  icon: const Icon(Icons.calculate),
                  tooltip: 'Konversi Manual',
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: () => Get.toNamed(Routes.GAME),
                  icon: Image.asset('assets/images/logobola.png', width: 24, height: 24),
                  tooltip: 'Mini game',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SearchBar(
              hintText: 'Cari tim atau laga…',
              onChanged: (v) => homeC.searchQuery.value = v,
              leading: const Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              if (homeC.isLoading.value && homeC.newsList.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              final list = homeC.filteredNews;
              if (list.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      homeC.errorMessage.value.isNotEmpty
                          ? homeC.errorMessage.value
                          : 'Belum ada data. Tambal API key atau coba refresh.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(color: AppColors.tfPlaceholder),
                    ),
                  ),
                );
              }
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: homeC.fetchNewsAPI,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final item = list[i];
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => Get.toNamed(Routes.MATCH_DETAIL, arguments: item),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: item.imageUrl.isNotEmpty
                                  ? Image.network(
                                      item.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: AppColors.tfBackground,
                                        child: const Icon(Icons.shield),
                                      ),
                                    )
                                  : Container(
                                      color: AppColors.tfBackground,
                                      child: const Icon(Icons.sports_soccer),
                                    ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item.subtitle,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: AppColors.tfPlaceholder,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
