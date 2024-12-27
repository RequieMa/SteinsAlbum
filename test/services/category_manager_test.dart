import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../mocks/mock_asset_entity.dart';
import '../../lib/services/category_manager.dart';

@GenerateMocks([AssetEntity])
void main() {
  group('CategoryManager Tests', () {
    late CategoryManager manager;
    late MockAssetEntity mockPhoto;

    setUp(() {
      manager = CategoryManager();
      mockPhoto = MockAssetEntity();
    });

    test('Initial categories are correctly set up', () {
      expect(manager.categories.length, 5);
      expect(manager.categories['landscape']?.name, 'Landscape');
      expect(manager.categories['selfie']?.name, 'Selfie');
    });

    test('Adding new category works', () {
      final newCategory = CategoryInfo(
        name: 'Test',
        color: Colors.pink,
        icon: Icons.star,
      );

      manager.addCategory('test', newCategory);

      expect(manager.categories.length, 6);
      expect(manager.categories['test'], newCategory);
    });

    test('Updating photo count works', () {
      manager.updatePhotoCount('landscape', 2);
      expect(manager.categories['landscape']?.photoCount, 2);

      manager.updatePhotoCount('landscape', -1);
      expect(manager.categories['landscape']?.photoCount, 1);
    });

    test('Categorizing photo updates counts correctly', () async {
      await manager.categorizePhoto(mockPhoto, {'landscape', 'selfie'});
      
      expect(manager.categories['landscape']?.photoCount, 1);
      expect(manager.categories['selfie']?.photoCount, 1);
      expect(manager.getCategoriesForPhoto(mockPhoto), {'landscape', 'selfie'});
    });

    test('Recategorizing photo updates counts correctly', () async {
      await manager.categorizePhoto(mockPhoto, {'landscape', 'selfie'});
      await manager.categorizePhoto(mockPhoto, {'portrait'});

      expect(manager.categories['landscape']?.photoCount, 0);
      expect(manager.categories['selfie']?.photoCount, 0);
      expect(manager.categories['portrait']?.photoCount, 1);
      expect(manager.getCategoriesForPhoto(mockPhoto), {'portrait'});
    });

    test('Clear removes all categorizations', () async {
      await manager.categorizePhoto(mockPhoto, {'landscape', 'selfie'});
      manager.clear();

      expect(manager.categories['landscape']?.photoCount, 0);
      expect(manager.categories['selfie']?.photoCount, 0);
      expect(manager.getCategoriesForPhoto(mockPhoto), isEmpty);
    });

    test('Queue processing works correctly', () async {
      manager.queueForCategorization(mockPhoto);
      expect(manager.isProcessing, true);

      // Wait for processing to complete
      await Future.delayed(const Duration(milliseconds: 200));
      expect(manager.isProcessing, false);
    });
  });
} 