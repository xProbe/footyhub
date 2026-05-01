import 'dart:async';
import 'package:get/get.dart';
import 'package:light/light.dart';

// Import kedua pondasi yang sudah kita pastikan kokoh tadi
import '../../core/utils/storage_util.dart'; // Sesuaikan path jika berbeda
import '../../data/locals/hive_provider.dart'; // Sesuaikan path jika berbeda

class GameController extends GetxController {
  var score = 0.obs;
  var highScore = 0.obs;
  var hearts = 3.obs;
  var isGameOver = false.obs;

  var luxValue = 0.obs;
  late Light _light;
  StreamSubscription? _subscription;

  String? currentUsername;

  @override
  void onInit() {
    super.onInit();
    startListening();

    // Panggil fungsi untuk mengambil identitas dan skor saat game pertama kali dibuka
    _loadUserAndHighScore();
  }

  // Fungsi baru untuk mengambil data dari core dan data layer
  Future<void> _loadUserAndHighScore() async {
    // 1. Tanya ke StorageUtil: "Siapa yang sedang main sekarang?"
    currentUsername = await StorageUtil.getLoggedInUsername();

    // 2. Jika ada yang login, minta brankas skornya ke HiveProvider
    if (currentUsername != null) {
      highScore.value = HiveProvider.getHighScore(currentUsername!);
    }
  }

  void startListening() {
    _light = Light();
    try {
      _subscription = _light.lightSensorStream.listen((lux) {
        luxValue.value = lux;
      });
    } catch (e) {
      print("Sensor cahaya tidak ditemukan pada perangkat ini");
    }
  }

  double get nightOverlayOpacity {
    if (luxValue.value > 50) return 0.0;
    if (luxValue.value <= 5) return 0.6;
    return (50 - luxValue.value) / 100;
  }

  void increaseScore() {
    if (!isGameOver.value) {
      score.value += 10;

      // Jika pemain memecahkan rekornya sendiri...
      if (score.value > highScore.value) {
        highScore.value = score.value; // Update UI di layar seketika

        // 3. Simpan rekor baru ke HiveProvider agar permanen!
        if (currentUsername != null) {
          HiveProvider.saveHighScore(currentUsername!, score.value);
        }
      }
    }
  }

  void decreaseHeart() {
    if (!isGameOver.value && hearts.value > 0) {
      hearts.value--;
      if (hearts.value == 0) {
        isGameOver.value = true;
      }
    }
  }

  void resetGame() {
    score.value = 0;
    hearts.value = 3;
    isGameOver.value = false;
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
