import 'dart:async';
import 'package:get/get.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../data/services/football_api_service.dart';
import '../../data/locals/news_database.dart';
import '../../data/models/football_feed_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/storage_util.dart';
import '../../core/utils/notification_helper.dart';

class HomeController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var userName = 'User'.obs;
  var newsList = <FootballFeedItem>[].obs;
  var searchQuery = ''.obs;

  StreamSubscription? _accelerometerSubscription;
  DateTime _lastShakeTime = DateTime.now();

  @override
  void onInit() {
    super.onInit();
    NotificationHelper.requestPermission();
    loadUserName();
    fetchNewsAPI();
    _initShakeSensor();
  }

  Future<void> loadUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString(StorageUtil.keyUserName);
      if (savedName != null && savedName.isNotEmpty) {
        userName.value = savedName.split(' ').first;
      }
    } catch (_) {}
  }

  List<FootballFeedItem> get filteredNews {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return newsList;
    return newsList
        .where((e) => e.title.toLowerCase().contains(q))
        .toList();
  }

  Future<void> fetchNewsAPI() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final fresh = await FootballApiService.fetchFeed();
      if (fresh.isNotEmpty) {
        await NewsDatabase.instance.upsertItems(fresh);
        newsList.assignAll(fresh);
        _maybeNotifyLive(fresh);
      } else {
        final cached = await NewsDatabase.instance.getCached();
        if (cached.isNotEmpty) {
          newsList.assignAll(cached);
        } else {
          errorMessage.value =
              'Tidak ada data. Periksa API key Football di api_constants.dart.';
        }
      }
    } catch (e) {
      errorMessage.value = 'Gagal memuat berita: $e';
      final cached = await NewsDatabase.instance.getCached();
      if (cached.isNotEmpty) newsList.assignAll(cached);
    } finally {
      isLoading.value = false;
    }
  }

  void _maybeNotifyLive(List<FootballFeedItem> items) {
    final live = items.where((e) => e.statusShort == 'LIVE').length;
    if (live > 0) {
      NotificationHelper.showNotification(
        id: 10,
        title: 'FootyHub — pertandingan LIVE',
        body: '$live laga sedang berlangsung. Buka app untuk detail.',
      );
    }
  }

  void _initShakeSensor() {
    try {
      _accelerometerSubscription = accelerometerEventStream().listen(
        (AccelerometerEvent event) {
          double gX = event.x / 9.80665;
          double gY = event.y / 9.80665;
          double gZ = event.z / 9.80665;
          double gForce = (gX * gX + gY * gY + gZ * gZ);

          if (gForce > 2.5) {
            final now = DateTime.now();
            if (now.difference(_lastShakeTime).inSeconds > 5) {
              _lastShakeTime = now;
              Get.snackbar(
                'Memperbarui',
                'Guncangan terdeteksi — memuat ulang feed…',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              );
              fetchNewsAPI();
            }
          }
        },
        onError: (_) {},
      );
    } catch (_) {}
  }

  @override
  void onClose() {
    _accelerometerSubscription?.cancel();
    super.onClose();
  }
}
