import 'package:flutter/foundation.dart';
import 'package:flutter_litert/flutter_litert.dart';
import 'predictor_service_stub.dart';
export 'predictor_service_stub.dart';

class MobilePredictorService implements PredictorService {
  Interpreter? _interpreter;
  bool _isLoaded = false;

  @override
  bool get isModelActive => _isLoaded;

  @override
  Future<void> init() async {
    try {
      _interpreter = await Interpreter.fromAsset('model/match_predictor.tflite');
      _isLoaded = true;
    } catch (e) {
      _isLoaded = false;
      debugPrint("TFLite failed to load asset model on mobile: $e");
    }
  }

  @override
  Future<List<double>> predict({
    required double standingsDiff,
    required double goalsDiff,
    required double homeAdvantage,
    required double homeGoals,
    required double awayGoals,
  }) async {
    if (_isLoaded && _interpreter != null) {
      try {
        final input = [
          [standingsDiff, goalsDiff, homeAdvantage, homeGoals / 5.0, awayGoals / 5.0]
        ];
        final output = List<double>.filled(3, 0.0).reshape([1, 3]);
        _interpreter!.run(input, output);
        final res = output[0] as List<dynamic>;
        return [res[0] as double, res[1] as double, res[2] as double];
      } catch (e) {
        debugPrint("TFLite mobile inference failed: $e");
      }
    }

    return _calculateFallback(standingsDiff, goalsDiff, homeAdvantage);
  }

  List<double> _calculateFallback(double standingsDiff, double goalsDiff, double homeAdvantage) {
    double scoreFactor = (-standingsDiff) * 2.5 + (goalsDiff) * 4.0 + (homeAdvantage == 1.0 ? 8.0 : 0.0);
    double win = (45.0 + scoreFactor).clamp(10.0, 90.0);
    double loss = (100.0 - win - 20.0).clamp(5.0, 90.0);
    double draw = 100.0 - win - loss;
    return [win / 100.0, draw / 100.0, loss / 100.0];
  }
}

PredictorService getPredictorService() => MobilePredictorService();
