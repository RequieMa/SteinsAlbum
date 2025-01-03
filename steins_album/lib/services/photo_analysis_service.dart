import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:collection';
import 'package:image/image.dart' as img;

class PhotoGroup {
  final String id;
  final List<AssetEntity> photos;
  final String type; // 'similar' or 'duplicate'
  final double similarity;

  PhotoGroup({
    required this.id,
    required this.photos,
    required this.type,
    required this.similarity,
  });
}

class PhotoAnalysisService extends ChangeNotifier {
  final Map<String, PhotoGroup> _photoGroups = {};
  final Queue<AssetEntity> _analysisQueue = Queue<AssetEntity>();
  bool _isProcessing = false;

  List<PhotoGroup> get photoGroups => _photoGroups.values.toList();
  bool get isProcessing => _isProcessing;

  // Get groups for a specific photo
  List<PhotoGroup> getGroupsForPhoto(AssetEntity photo, {String? type}) {
    return _photoGroups.values
        .where((group) => 
            group.photos.contains(photo) && 
            (type == null || group.type == type))
        .toList();
  }

  // Queue photos for analysis
  void queueForAnalysis(List<AssetEntity> photos) {
    for (final photo in photos) {
      if (!_analysisQueue.contains(photo)) {
        _analysisQueue.add(photo);
      }
    }
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isProcessing || _analysisQueue.isEmpty) return;

    _isProcessing = true;
    notifyListeners();

    try {
      while (_analysisQueue.isNotEmpty) {
        final photo = _analysisQueue.removeFirst();
        await Future.wait([
          _detectSimilarPhotos(photo),
          _detectDuplicates(photo),
        ]);
      }
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> _detectSimilarPhotos(AssetEntity photo) async {
    final timestamp = await photo.createDateTime;
    final key = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
      timestamp.hour,
      timestamp.minute,
    ).toString();

    if (!_photoGroups.containsKey('similar_$key')) {
      _photoGroups['similar_$key'] = PhotoGroup(
        id: 'similar_$key',
        photos: [photo],
        type: 'similar',
        similarity: 1.0,
      );
    } else {
      _photoGroups['similar_$key']!.photos.add(photo);
    }
  }

  Future<void> _detectDuplicates(AssetEntity photo) async {
    final file = await photo.file;
    if (file == null) return;

    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) return;

    // Calculate simple image hash
    final hash = await compute(_calculateImageHash, image);
    final key = 'duplicate_$hash';

    if (!_photoGroups.containsKey(key)) {
      _photoGroups[key] = PhotoGroup(
        id: key,
        photos: [photo],
        type: 'duplicate',
        similarity: 1.0,
      );
    } else {
      _photoGroups[key]!.photos.add(photo);
    }
  }

  static String _calculateImageHash(img.Image image) {
    // Resize image to 8x8 for comparison
    final smallImage = img.copyResize(image, width: 8, height: 8);
    
    // Convert to grayscale and calculate average
    int total = 0;
    final pixels = List<int>.filled(64, 0);
    
    for (int y = 0; y < 8; y++) {
      for (int x = 0; x < 8; x++) {
        final pixel = smallImage.getPixel(x, y);
        final gray = ((pixel >> 16) & 0xFF) * 0.299 +
                    ((pixel >> 8) & 0xFF) * 0.587 +
                    (pixel & 0xFF) * 0.114;
        pixels[y * 8 + x] = gray.round();
        total += gray.round();
      }
    }

    // Calculate hash based on whether pixel is above average
    final average = total / 64;
    final bits = pixels.map((p) => p > average ? '1' : '0').join();
    return bits;
  }

  void clear() {
    _photoGroups.clear();
    _analysisQueue.clear();
    _isProcessing = false;
    notifyListeners();
  }
} 