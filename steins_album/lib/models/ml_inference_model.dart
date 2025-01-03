import 'package:flutter/services.dart';

enum ModelType {
  scene,
  selfie,
  content
}

enum ContentCategory {
  meme,
  screenshot,
  artwork,
  other
}

class MLInferenceResult {
  final String label;
  final double confidence;
  final ContentCategory? contentCategory;

  MLInferenceResult({
    required this.label,
    required this.confidence,
    this.contentCategory,
  });

  factory MLInferenceResult.fromMap(Map<String, dynamic> map) {
    return MLInferenceResult(
      label: map['label'] as String,
      confidence: map['confidence'] as double,
      contentCategory: map['contentCategory'] != null 
          ? ContentCategory.values.firstWhere(
              (e) => e.toString() == 'ContentCategory.${map['contentCategory']}',
              orElse: () => ContentCategory.other,
            )
          : null,
    );
  }
}

class MLInferenceModel {
  // Mock implementation for Windows testing
  Future<MLInferenceResult> classifyImage({
    required String imagePath,
    required ModelType modelType,
  }) async {
    // Simulate processing delay
    await Future.delayed(const Duration(milliseconds: 500));

    switch (modelType) {
      case ModelType.scene:
        return MLInferenceResult(
          label: 'nature',
          confidence: 0.95,
        );
      case ModelType.selfie:
        return MLInferenceResult(
          label: 'selfie',
          confidence: 0.8,
        );
      case ModelType.content:
        return MLInferenceResult(
          label: 'meme',
          confidence: 0.9,
          contentCategory: ContentCategory.meme,
        );
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

  Future<ContentCategory> getContentCategory(String imagePath) async {
    final result = await classifyImage(
      imagePath: imagePath,
      modelType: ModelType.content,
    );
    return result.contentCategory ?? ContentCategory.other;
  }
} 