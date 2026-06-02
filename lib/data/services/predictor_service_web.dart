import 'predictor_service_stub.dart';
export 'predictor_service_stub.dart';

class WebPredictorService implements PredictorService {
  @override
  bool get isModelActive => false;

  @override
  Future<void> init() async {
    // No-op for web
  }

  @override
  Future<List<double>> predict({
    required double standingsDiff,
    required double goalsDiff,
    required double homeAdvantage,
    required double homeGoals,
    required double awayGoals,
  }) async {
    // Web fallback high fidelity calculations
    double scoreFactor = (-standingsDiff) * 2.5 + (goalsDiff) * 4.0 + (homeAdvantage == 1.0 ? 8.0 : 0.0);
    double win = (45.0 + scoreFactor).clamp(10.0, 90.0);
    double loss = (100.0 - win - 20.0).clamp(5.0, 90.0);
    double draw = 100.0 - win - loss;
    return [win / 100.0, draw / 100.0, loss / 100.0];
  }
}

PredictorService getPredictorService() => WebPredictorService();
