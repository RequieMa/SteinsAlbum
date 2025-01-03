import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';
import '../models/album_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:collection/collection.dart';

enum SuggestionType {
  date,
  location,
  event,
  similar,
  faces
}

class AlbumSuggestion {
  final String title;
  final String description;
  final List<AssetEntity> photos;
  final SuggestionType type;
  final double confidence;
  final Map<String, dynamic>? metadata;

  const AlbumSuggestion({
    required this.title,
    required this.description,
    required this.photos,
    required this.type,
    required this.confidence,
    this.metadata,
  });
}

class AlbumSuggestionService extends ChangeNotifier {
  static const int minPhotosForDateSuggestion = 5;
  static const int minPhotosForLocationSuggestion = 3;
  static const int minPhotosForEventSuggestion = 5;
  static const Duration eventTimeGap = Duration(hours: 2);

  final List<AlbumSuggestion> _suggestions = [];
  bool _isGenerating = false;

  List<AlbumSuggestion> get suggestions => List.unmodifiable(_suggestions);
  bool get isGenerating => _isGenerating;

  Future<void> generateSuggestions(List<AssetEntity> photos) async {
    if (_isGenerating) return;

    _isGenerating = true;
    _suggestions.clear();
    notifyListeners();

    try {
      // Process suggestions in parallel
      final results = await Future.wait([
        _processDateBasedSuggestions(photos),
        _processLocationBasedSuggestions(photos),
        _processEventBasedSuggestions(photos),
      ]);

      // Combine and sort suggestions by confidence
      _suggestions.addAll(results.expand((x) => x));
      _suggestions.sort((a, b) => b.confidence.compareTo(a.confidence));
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  Future<List<AlbumSuggestion>> _processDateBasedSuggestions(
    List<AssetEntity> photos,
  ) async {
    final suggestions = <AlbumSuggestion>[];
    final dateGroups = await _groupPhotosByDate(photos);

    for (final entry in dateGroups.entries) {
      if (entry.value.length >= minPhotosForDateSuggestion) {
        suggestions.add(AlbumSuggestion(
          title: 'Memories from ${_formatDate(entry.key)}',
          description: '${entry.value.length} photos from this day',
          photos: entry.value,
          type: SuggestionType.date,
          confidence: _calculateDateConfidence(entry.value.length),
          metadata: {'date': entry.key.toIso8601String()},
        ));
      }
    }

    return suggestions;
  }

  Future<List<AlbumSuggestion>> _processLocationBasedSuggestions(
    List<AssetEntity> photos,
  ) async {
    final suggestions = <AlbumSuggestion>[];
    final locationGroups = await _groupPhotosByLocation(photos);

    for (final entry in locationGroups.entries) {
      if (entry.value.length >= minPhotosForLocationSuggestion) {
        final location = await _getLocationName(entry.key);
        suggestions.add(AlbumSuggestion(
          title: 'Photos from $location',
          description: '${entry.value.length} photos from this location',
          photos: entry.value,
          type: SuggestionType.location,
          confidence: _calculateLocationConfidence(entry.value.length),
          metadata: {'location': entry.key},
        ));
      }
    }

    return suggestions;
  }

  Future<List<AlbumSuggestion>> _processEventBasedSuggestions(
    List<AssetEntity> photos,
  ) async {
    final suggestions = <AlbumSuggestion>[];
    final events = await _groupPhotosByTimeProximity(photos);

    for (final event in events) {
      if (event.length >= minPhotosForEventSuggestion) {
        final startDate = await event.first.createDateTime;
        suggestions.add(AlbumSuggestion(
          title: 'Event on ${_formatDate(startDate)}',
          description: '${event.length} photos from this event',
          photos: event,
          type: SuggestionType.event,
          confidence: _calculateEventConfidence(event.length),
          metadata: {
            'startDate': startDate.toIso8601String(),
            'endDate': (await event.last.createDateTime).toIso8601String(),
          },
        ));
      }
    }

    return suggestions;
  }

  Future<Map<DateTime, List<AssetEntity>>> _groupPhotosByDate(
    List<AssetEntity> photos,
  ) async {
    final groups = <DateTime, List<AssetEntity>>{};
    
    await Future.forEach(photos, (photo) async {
      final date = await photo.createDateTime;
      final key = DateTime(date.year, date.month, date.day);
      groups.putIfAbsent(key, () => []).add(photo);
    });
    
    return groups;
  }

  Future<Map<String, List<AssetEntity>>> _groupPhotosByLocation(
    List<AssetEntity> photos,
  ) async {
    final groups = <String, List<AssetEntity>>{};
    
    await Future.forEach(photos, (photo) async {
      final latLng = await photo.latlng;
      if (latLng != null) {
        final key = '${latLng.latitude.toStringAsFixed(2)},${latLng.longitude.toStringAsFixed(2)}';
        groups.putIfAbsent(key, () => []).add(photo);
      }
    });
    
    return groups;
  }

  Future<List<List<AssetEntity>>> _groupPhotosByTimeProximity(
    List<AssetEntity> photos,
  ) async {
    final sortedPhotos = await Future.wait(
      photos.map((p) async => MapEntry(await p.createDateTime, p)),
    );
    sortedPhotos.sort((a, b) => a.key.compareTo(b.key));

    final events = <List<AssetEntity>>[];
    var currentEvent = <AssetEntity>[];
    DateTime? lastTimestamp;

    for (final entry in sortedPhotos) {
      if (lastTimestamp != null &&
          entry.key.difference(lastTimestamp) > eventTimeGap) {
        if (currentEvent.length >= minPhotosForEventSuggestion) {
          events.add(List.from(currentEvent));
        }
        currentEvent = [];
      }
      
      currentEvent.add(entry.value);
      lastTimestamp = entry.key;
    }

    if (currentEvent.length >= minPhotosForEventSuggestion) {
      events.add(currentEvent);
    }

    return events;
  }

  double _calculateDateConfidence(int photoCount) =>
      0.5 + (photoCount / 100).clamp(0.0, 0.4);

  double _calculateLocationConfidence(int photoCount) =>
      0.4 + (photoCount / 100).clamp(0.0, 0.5);

  double _calculateEventConfidence(int photoCount) =>
      0.3 + (photoCount / 100).clamp(0.0, 0.6);

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<String> _getLocationName(String coordinates) async {
    // TODO: Implement reverse geocoding
    return 'Location ($coordinates)';
  }

  Future<CustomAlbum> applySuggestion(AlbumSuggestion suggestion) async {
    final album = CustomAlbum(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: suggestion.title,
      description: suggestion.description,
      type: AlbumType.custom,
      photos: suggestion.photos,
    );
    
    _suggestions.remove(suggestion);
    notifyListeners();
    
    return album;
  }

  void clear() {
    _suggestions.clear();
    _isGenerating = false;
    notifyListeners();
  }
} 