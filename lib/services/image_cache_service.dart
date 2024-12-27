import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:async';
import 'package:collection/collection.dart';

/// Manages image caching and progressive loading with memory optimization
class ImageCacheService extends ChangeNotifier {
  static const int maxCacheSize = 200;
  static const int maxMemoryCacheSize = 50;
  static const int thumbnailSize = 256;
  static const int thumbnailQuality = 85;
  static const Duration cacheTimeout = Duration(hours: 24);

  final Map<String, File> _cachedThumbnails = {};
  final Map<String, File> _cachedFullImages = {};
  final Set<String> _loadingImages = {};
  final Map<String, Completer<File?>> _loadingCompleters = {};
  final Queue<String> _lruQueue = Queue<String>();
  final Map<String, DateTime> _lastAccessTimes = {};
  int _currentMemoryUsage = 0;

  bool isLoading(String id) => _loadingImages.contains(id);
  bool isCached(String id) => _cachedThumbnails.containsKey(id);

  /// Gets a cached image, either from memory or disk
  /// 
  /// Parameters:
  /// - [asset]: The photo asset to retrieve
  /// - [thumbnail]: Whether to get thumbnail or full resolution
  Future<File?> getCachedImage(AssetEntity asset, {bool thumbnail = true}) async {
    final id = asset.id;
    
    // Update LRU queue
    _updateLRU(id);
    
    // Check memory cache first
    if (thumbnail && _cachedThumbnails.containsKey(id)) {
      return _cachedThumbnails[id];
    } else if (!thumbnail && _cachedFullImages.containsKey(id)) {
      return _cachedFullImages[id];
    }

    // Check if already loading
    if (_loadingImages.contains(id)) {
      final completer = _loadingCompleters.putIfAbsent(id, () => Completer<File?>());
      return completer.future;
    }

    // Check disk cache
    final file = await _loadFromDiskCache(asset, thumbnail);
    if (file != null) {
      if (thumbnail) {
        await _addToMemoryCache(id, file);
      }
      return file;
    }

    // Load and cache the image
    return loadAndCacheImage(asset, thumbnail: thumbnail);
  }

  /// Loads and caches an image, with memory management
  Future<File?> loadAndCacheImage(AssetEntity asset, {bool thumbnail = true}) async {
    final id = asset.id;
    if (_loadingImages.contains(id)) return null;

    final completer = Completer<File?>();
    _loadingCompleters[id] = completer;
    _loadingImages.add(id);
    notifyListeners();

    try {
      File? file;
      if (thumbnail) {
        file = await _generateAndCacheThumbnail(asset);
        if (file != null) {
          await _addToMemoryCache(id, file);
        }
      } else {
        file = await asset.file;
        if (file != null) {
          _cachedFullImages[id] = file;
        }
      }

      completer.complete(file);
      return file;
    } catch (e) {
      completer.completeError(e);
      return null;
    } finally {
      _loadingImages.remove(id);
      _loadingCompleters.remove(id);
      await _maintainCacheSize();
      notifyListeners();
    }
  }

  /// Updates the LRU queue and access times
  void _updateLRU(String id) {
    _lruQueue.remove(id);
    _lruQueue.addFirst(id);
    _lastAccessTimes[id] = DateTime.now();
  }

  /// Adds a file to the memory cache with size management
  Future<void> _addToMemoryCache(String id, File file) async {
    final fileSize = await file.length();
    
    // Remove old items if needed
    while (_currentMemoryUsage + fileSize > maxMemoryCacheSize * 1024 * 1024 &&
           _lruQueue.isNotEmpty) {
      final oldestId = _lruQueue.last;
      await _removeFromMemoryCache(oldestId);
    }

    // Add to memory cache
    _cachedThumbnails[id] = file;
    _currentMemoryUsage += fileSize;
    _updateLRU(id);
  }

  /// Removes a file from the memory cache
  Future<void> _removeFromMemoryCache(String id) async {
    final file = _cachedThumbnails.remove(id);
    if (file != null) {
      _currentMemoryUsage -= await file.length();
      _lruQueue.remove(id);
    }
  }

  /// Loads an image from disk cache
  Future<File?> _loadFromDiskCache(AssetEntity asset, bool thumbnail) async {
    final cacheDir = await getTemporaryDirectory();
    final cacheFile = File(
      '${cacheDir.path}/${thumbnail ? 'thumb_' : 'full_'}${asset.id}.jpg'
    );

    if (await cacheFile.exists()) {
      final lastModified = await cacheFile.lastModified();
      if (DateTime.now().difference(lastModified) < cacheTimeout) {
        return cacheFile;
      }
      // Delete expired cache
      await cacheFile.delete();
    }
    return null;
  }

  Future<File?> _generateAndCacheThumbnail(AssetEntity asset) async {
    try {
      final thumbnailBytes = await asset.thumbnailDataWithSize(
        const ThumbnailSize(thumbnailSize, thumbnailSize),
        quality: thumbnailQuality,
      );

      if (thumbnailBytes == null) return null;

      final cacheDir = await getTemporaryDirectory();
      final thumbnailFile = File('${cacheDir.path}/thumb_${asset.id}.jpg');
      await thumbnailFile.writeAsBytes(thumbnailBytes);
      return thumbnailFile;
    } catch (e) {
      debugPrint('Error generating thumbnail: $e');
      return null;
    }
  }

  Future<void> preloadImages(List<AssetEntity> assets) async {
    final futures = assets
        .where((asset) => !isCached(asset.id))
        .map((asset) => loadAndCacheImage(asset, thumbnail: true));
    
    await Future.wait(futures);
  }

  Future<void> _maintainCacheSize() async {
    if (_cachedThumbnails.length <= maxCacheSize) return;

    final toRemove = _cachedThumbnails.length - maxCacheSize;
    final oldestEntries = _cachedThumbnails.entries.take(toRemove);
    
    for (final entry in oldestEntries) {
      _cachedThumbnails.remove(entry.key);
      try {
        await entry.value.delete();
      } catch (e) {
        debugPrint('Error deleting cached file: $e');
      }
    }
  }

  Future<void> clearCache() async {
    _cachedThumbnails.clear();
    _cachedFullImages.clear();
    
    try {
      final cacheDir = await getTemporaryDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        await cacheDir.create();
      }
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
    
    notifyListeners();
  }
} 