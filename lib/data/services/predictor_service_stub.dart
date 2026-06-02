abstract class PredictorService {
  Future<void> init();
  Future<List<double>> predict({
    required double standingsDiff,
    required double goalsDiff,
    required double homeAdvantage,
    required double homeGoals,
    required double awayGoals,
  });
  bool get isModelActive;
}

PredictorService getPredictorService() => throw UnsupportedError('Cannot create predictor service');
