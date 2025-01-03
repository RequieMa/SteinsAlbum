import 'package:photo_manager/photo_manager.dart';

class CustomAlbum {
  String id;
  String name;
  String? description;
  DateTime createdAt;
  DateTime modifiedAt;
  List<AssetEntity> photos;
  AlbumType type;

  CustomAlbum({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    List<AssetEntity>? photos,
  }) : 
    photos = photos ?? [],
    createdAt = DateTime.now(),
    modifiedAt = DateTime.now();

  void addPhotos(List<AssetEntity> newPhotos) {
    photos.addAll(newPhotos);
    modifiedAt = DateTime.now();
  }

  void removePhotos(List<AssetEntity> photosToRemove) {
    photos.removeWhere((photo) => photosToRemove.contains(photo));
    modifiedAt = DateTime.now();
  }

  void reorderPhotos(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = photos.removeAt(oldIndex);
    photos.insert(newIndex, item);
    modifiedAt = DateTime.now();
  }
}

enum AlbumType {
  custom,
  scenes,
  selfies,
  memes,
  screenshots,
  favorites
} 