import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:path_provider/path_provider.dart';
import '../../lib/services/image_cache_service.dart';
import '../mocks/mock_asset_entity.dart';

@GenerateMocks([File, Directory])
void main() {
  group('ImageCacheService Tests', () {
    late ImageCacheService cacheService;
    late MockAssetEntity mockAsset;
    late Directory tempDir;

    setUp(() async {
      cacheService = ImageCacheService();
      mockAsset = MockAssetEntity();
      tempDir = await Directory.systemTemp.createTemp();

      // Mock getTemporaryDirectory
      getTemporaryDirectory = () async => tempDir;
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('Initial state is empty', () {
      expect(cacheService.isCached(mockAsset.id), false);
      expect(cacheService.isLoading(mockAsset.id), false);
    });

    test('Loading image sets loading state', () async {
      final future = cacheService.loadAndCacheImage(mockAsset);
      expect(cacheService.isLoading(mockAsset.id), true);
      await future;
      expect(cacheService.isLoading(mockAsset.id), false);
    });

    test('Concurrent loads return same future', () async {
      final future1 = cacheService.getCachedImage(mockAsset);
      final future2 = cacheService.getCachedImage(mockAsset);
      expect(future1, same(future2));
    });

    test('Cache size is maintained', () async {
      // Create more assets than cache size
      final assets = List.generate(
        ImageCacheService.maxCacheSize + 10,
        (i) => MockAssetEntity()..id = 'asset_$i',
      );

      // Cache all assets
      for (final asset in assets) {
        await cacheService.loadAndCacheImage(asset);
      }

      // Check that cache size is not exceeded
      final cacheDir = await getTemporaryDirectory();
      final files = cacheDir.listSync();
      expect(files.length, lessThanOrEqualTo(ImageCacheService.maxCacheSize));
    });

    test('Clear cache works', () async {
      // Cache some images
      await cacheService.loadAndCacheImage(mockAsset);
      expect(cacheService.isCached(mockAsset.id), true);

      // Clear cache
      await cacheService.clearCache();
      expect(cacheService.isCached(mockAsset.id), false);

      // Check that cache directory is empty
      final cacheDir = await getTemporaryDirectory();
      final files = cacheDir.listSync();
      expect(files, isEmpty);
    });

    test('Memory cache respects size limits', () async {
      // Create assets that would exceed memory cache size
      final assets = List.generate(
        ImageCacheService.maxMemoryCacheSize + 5,
        (i) => MockAssetEntity()..id = 'asset_$i',
      );

      // Cache all assets
      for (final asset in assets) {
        await cacheService.loadAndCacheImage(asset);
      }

      // Check that least recently used items are removed
      expect(cacheService.isCached(assets.first.id), false);
      expect(cacheService.isCached(assets.last.id), true);
    });

    test('Preload images works', () async {
      final assets = List.generate(
        5,
        (i) => MockAssetEntity()..id = 'asset_$i',
      );

      await cacheService.preloadImages(assets);

      for (final asset in assets) {
        expect(cacheService.isCached(asset.id), true);
      }
    });
  });
} 