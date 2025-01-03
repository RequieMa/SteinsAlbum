import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../lib/services/photo_analysis_service.dart';
import '../mocks/mock_asset_entity.dart';

void main() {
  group('PhotoAnalysisService Tests', () {
    late PhotoAnalysisService analysisService;
    late List<MockAssetEntity> mockPhotos;

    setUp(() {
      analysisService = PhotoAnalysisService();
      
      // Create mock photos with different timestamps
      mockPhotos = List.generate(5, (i) {
        final photo = MockAssetEntity();
        when(photo.id).thenReturn('photo_$i');
        when(photo.createDateTime).thenAnswer(
          (_) async => DateTime(2023, 1, 1, 12, i),
        );
        return photo;
      });
    });

    test('Initial state is empty', () {
      expect(analysisService.photoGroups, isEmpty);
      expect(analysisService.isProcessing, false);
    });

    test('Queuing photos starts processing', () async {
      analysisService.queueForAnalysis([mockPhotos.first]);
      expect(analysisService.isProcessing, true);

      // Wait for processing to complete
      await Future.delayed(const Duration(milliseconds: 200));
      expect(analysisService.isProcessing, false);
    });

    test('Similar photos are grouped by timestamp', () async {
      // Create photos with same timestamp
      final similarPhotos = List.generate(3, (i) {
        final photo = MockAssetEntity();
        when(photo.id).thenReturn('similar_$i');
        when(photo.createDateTime).thenAnswer(
          (_) async => DateTime(2023, 1, 1, 12, 0),
        );
        return photo;
      });

      analysisService.queueForAnalysis(similarPhotos);
      await Future.delayed(const Duration(milliseconds: 200));

      final groups = analysisService.getGroupsForPhoto(
        similarPhotos.first,
        type: 'similar',
      );
      expect(groups.length, 1);
      expect(groups.first.photos.length, 3);
    });

    test('Duplicate photos are grouped by content', () async {
      // Create photos with same content hash
      final duplicatePhotos = List.generate(2, (i) {
        final photo = MockAssetEntity();
        when(photo.id).thenReturn('duplicate_$i');
        when(photo.file).thenAnswer((_) async => null); // Mock file content
        return photo;
      });

      analysisService.queueForAnalysis(duplicatePhotos);
      await Future.delayed(const Duration(milliseconds: 200));

      final groups = analysisService.getGroupsForPhoto(
        duplicatePhotos.first,
        type: 'duplicate',
      );
      expect(groups.length, greaterThanOrEqualTo(1));
    });

    test('Clear removes all groups', () async {
      analysisService.queueForAnalysis(mockPhotos);
      await Future.delayed(const Duration(milliseconds: 200));
      expect(analysisService.photoGroups, isNotEmpty);

      analysisService.clear();
      expect(analysisService.photoGroups, isEmpty);
      expect(analysisService.isProcessing, false);
    });

    test('Multiple photos can belong to different groups', () async {
      // Create photos that should be both similar and duplicates
      final photo1 = MockAssetEntity();
      final photo2 = MockAssetEntity();
      when(photo1.id).thenReturn('multi_1');
      when(photo2.id).thenReturn('multi_2');
      when(photo1.createDateTime).thenAnswer(
        (_) async => DateTime(2023, 1, 1, 12, 0),
      );
      when(photo2.createDateTime).thenAnswer(
        (_) async => DateTime(2023, 1, 1, 12, 0),
      );

      analysisService.queueForAnalysis([photo1, photo2]);
      await Future.delayed(const Duration(milliseconds: 200));

      final groups = analysisService.getGroupsForPhoto(photo1);
      expect(
        groups.where((g) => g.type == 'similar').length,
        greaterThanOrEqualTo(1),
      );
    });
  });
} 