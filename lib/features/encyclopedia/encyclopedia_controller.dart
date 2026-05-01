import 'package:get/get.dart';
import '../../data/models/species_model.dart';

class EncyclopediaController extends GetxController {
  var isLoading = false.obs;
  var speciesList = <SpeciesModel>[].obs; // Daftar data asli dari API
  var filteredList = <SpeciesModel>[].obs; // Daftar yang tampil di layar

  var selectedCategory = 'All'.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSpeciesData();
  }

  // Ensiklopedia ikan tidak lagi dipakai di FootyHub — pertahankan stub agar build tetap bersih.
  void fetchSpeciesData() async {
    isLoading.value = true;
    speciesList.clear();
    filteredList.clear();
    isLoading.value = false;
  }

  // --- FUNGSI SEARCH & FILTER ---
  void filterData(String query, String category) {
    searchQuery.value = query;
    selectedCategory.value = category;

    var result = speciesList.where((species) {
      final matchName = species.name.toLowerCase().contains(
        query.toLowerCase(),
      );
      // Logika pencocokan kategori (Difficulty)
      final matchCategory = category == 'All' || species.difficulty == category;
      return matchName && matchCategory;
    }).toList();

    filteredList.assignAll(result);
  }

  // --- FUNGSI BOOKMARK ---
  void toggleBookmark(String id) {
    var index = filteredList.indexWhere((s) => s.id == id);
    if (index != -1) {
      filteredList[index].isBookmarked = !filteredList[index].isBookmarked;
      filteredList
          .refresh(); // Memaksa UI untuk me-render ulang ikon hati (love)

      // TODO: Implementasi simpan bookmark ke Hive local storage
    }
  }
}
