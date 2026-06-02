import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/locals/database_helper.dart';
import '../../data/models/football_feed_item.dart';
import '../../data/services/football_api_service.dart';
import '../../core/utils/notification_helper.dart';
import '../../core/utils/sensor_controller.dart';

class NewsState {
  final List<FootballFeedItem> newsList;
  final bool isLoading;
  final String errorMessage;

  NewsState({
    this.newsList = const [],
    this.isLoading = false,
    this.errorMessage = '',
  });

  NewsState copyWith({
    List<FootballFeedItem>? newsList,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NewsState(
      newsList: newsList ?? this.newsList,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class NewsNotifier extends StateNotifier<NewsState> {
  final Ref _ref;
  StreamSubscription? _shakeSubscription;

  NewsNotifier(this._ref) : super(NewsState()) {
    fetchNews();
    _listenToShake();
  }

  void _listenToShake() {
    _shakeSubscription = _ref.read(sensorManagerProvider).onShake.listen((_) {
      fetchNews(isShake: true);
    });
  }

  Future<void> fetchNews({bool isShake = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: '');
    try {
      final fresh = await FootballApiService.fetchFeed();
      if (fresh.isNotEmpty) {
        await DatabaseHelper.instance.upsertNewsItems(fresh);
        state = NewsState(newsList: fresh, isLoading: false);
        _maybeNotifyLive(fresh);
      } else {
        final cached = await DatabaseHelper.instance.getCachedNews();
        if (cached.isNotEmpty) {
          state = NewsState(newsList: cached, isLoading: false);
        } else {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'Tidak ada data. Periksa API key di api_constants.dart.',
          );
        }
      }
    } catch (e) {
      final cached = await DatabaseHelper.instance.getCachedNews();
      state = NewsState(
        newsList: cached,
        isLoading: false,
        errorMessage: cached.isNotEmpty ? '' : 'Gagal memuat berita: $e',
      );
    }
  }

  void _maybeNotifyLive(List<FootballFeedItem> items) {
    final live = items.where((e) => e.statusShort == 'LIVE' || e.statusShort == '1H' || e.statusShort == '2H').length;
    if (live > 0) {
      NotificationHelper.showNotification(
        id: 10,
        title: 'FootyHub — Pertandingan LIVE',
        body: '$live laga sedang berlangsung. Buka aplikasi untuk detail selengkapnya!',
      );
    }
  }

  @override
  void dispose() {
    _shakeSubscription?.cancel();
    super.dispose();
  }
}

final newsProvider = StateNotifierProvider<NewsNotifier, NewsState>((ref) {
  return NewsNotifier(ref);
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredNewsProvider = Provider<List<FootballFeedItem>>((ref) {
  final state = ref.watch(newsProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  
  if (query.isEmpty) return state.newsList;
  
  return state.newsList.where((item) {
    return item.title.toLowerCase().contains(query) ||
           item.leagueName.toLowerCase().contains(query) ||
           item.homeName.toLowerCase().contains(query) ||
           item.awayName.toLowerCase().contains(query);
  }).toList();
});
