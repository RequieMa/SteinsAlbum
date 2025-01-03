import 'package:mockito/mockito.dart';
import 'package:photo_manager/photo_manager.dart';

class MockAssetEntity extends Mock implements AssetEntity {
  @override
  String get id => 'mock_asset_1';

  @override
  Future<DateTime> get createDateTime async => DateTime(2023, 1, 1);

  @override
  Future<LatLng?> get latlng async => const LatLng(37.7749, -122.4194);
} 