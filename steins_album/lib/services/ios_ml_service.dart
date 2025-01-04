import 'package:flutter/services.dart';
import '../models/ml_inference_model.dart';

class IOSMLService {
  static const platform = MethodChannel('com.steinsalbum.ml');
  
  Future<MLInferenceResult> classifyImage(String imagePath, ModelType type) async {
    try {
      final result = await platform.invokeMethod('classifyImage', {
        'imagePath': imagePath,
        'modelType': type.toString(),
      });
      
      return MLInferenceResult.fromMap(Map<String, dynamic>.from(result));
    } catch (e) {
      print('Error using Core ML: $e');
      // Fallback to mock results if Core ML fails
      return MLInferenceResult(
        label: 'unknown',
        confidence: 0.0,
      );
    }
  }
} 