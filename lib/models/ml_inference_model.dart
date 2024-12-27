import 'package:flutter/services.dart';

enum ModelType {
  scene,
  selfie,
  content
}

class MLInferenceResult {
  final String label;
  final double confidence;

  MLInferenceResult({
    required this.label,
    required this.confidence,
  });

  factory MLInferenceResult.fromMap(Map<String, dynamic> map) {
    return MLInferenceResult(
      label: map['label'] as String,
      confidence: map['confidence'] as double,
    );
  }
}

class MLInferenceModel {
  static const _channel = MethodChannel('steins_album/ml_inference');

  Future<MLInferenceResult> classifyImage({
    required String imagePath,
    required ModelType modelType,
  }) async {
    try {
      final result = await _channel.invokeMethod('classifyImage', {
        'imagePath': imagePath,
        'modelType': modelType.toString().split('.').last,
      });

      return MLInferenceResult.fromMap(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      throw Exception('Failed to classify image: ${e.message}');
    }
  }

  Future<bool> isSelfie(String imagePath) async {
    final result = await classifyImage(
      imagePath: imagePath,
      modelType: ModelType.selfie,
    );
    return result.label == 'selfie' && result.confidence > 0.7;
  }

  Future<String> getSceneCategory(String imagePath) async {
    final result = await classifyImage(
      imagePath: imagePath,
      modelType: ModelType.scene,
    );
    return result.label;
  }

  Future<bool> isInappropriateContent(String imagePath) async {
    final result = await classifyImage(
      imagePath: imagePath,
      modelType: ModelType.content,
    );
    return result.label == '18+' && result.confidence > 0.8;
  }
} 