import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class ScheduleController extends GetxController {
  /// Contoh kickoff pertandingan (UTC).
  final kickoffUtc = DateTime.utc(2026, 5, 2, 17, 30).obs;

  final timeLondon = ''.obs;
  final timeWib = ''.obs;
  final timeWita = ''.obs;
  final timeWit = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _compute();
  }

  void _compute() {
    final utc = kickoffUtc.value;
    final fmt = DateFormat('HH:mm');

    final locLondon = tz.getLocation('Europe/London');
    final locWib = tz.getLocation('Asia/Jakarta');
    final locWita = tz.getLocation('Asia/Makassar');
    final locWit = tz.getLocation('Asia/Jayapura');

    timeLondon.value = fmt.format(tz.TZDateTime.from(utc, locLondon));
    timeWib.value = fmt.format(tz.TZDateTime.from(utc, locWib));
    timeWita.value = fmt.format(tz.TZDateTime.from(utc, locWita));
    timeWit.value = fmt.format(tz.TZDateTime.from(utc, locWit));
  }
}
