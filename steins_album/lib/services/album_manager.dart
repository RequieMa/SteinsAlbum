import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';
import '../models/album_model.dart';
import '../models/photo_operation.dart';

class AlbumManager extends ChangeNotifier {
  final List<CustomAlbum> _albums = [];
  CustomAlbum? _selectedAlbum;
  final Set<AssetEntity> _selectedPhotos = {};
  final PhotoEditHistory _history = PhotoEditHistory();
  bool _isMultiSelectMode = false;

  List<CustomAlbum> get albums => List.unmodifiable(_albums);
  CustomAlbum? get selectedAlbum => _selectedAlbum;
  Set<AssetEntity> get selectedPhotos => Set.from(_selectedPhotos);
  bool get isMultiSelectMode => _isMultiSelectMode;
  bool get canUndo => _history.canUndo;
  bool get canRedo => _history.canRedo;

  // Multi-select mode
  void toggleMultiSelectMode() {
    _isMultiSelectMode = !_isMultiSelectMode;
    if (!_isMultiSelectMode) {
      _selectedPhotos.clear();
    }
    notifyListeners();
  }

  void togglePhotoSelection(AssetEntity photo) {
    if (_selectedPhotos.contains(photo)) {
      _selectedPhotos.remove(photo);
    } else {
      _selectedPhotos.add(photo);
    }
    notifyListeners();
  }

  void selectAllPhotos(List<AssetEntity> photos) {
    _selectedPhotos.addAll(photos);
    notifyListeners();
  }

  void clearSelection() {
    _selectedPhotos.clear();
    notifyListeners();
  }

  // Create a new album with history
  Future<CustomAlbum> createAlbum({
    required String name,
    String? description,
    required AlbumType type,
    List<AssetEntity>? initialPhotos,
  }) async {
    final album = CustomAlbum(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      type: type,
      photos: initialPhotos,
    );
    
    _albums.add(album);
    
    if (initialPhotos != null && initialPhotos.isNotEmpty) {
      _history.addOperation(PhotoOperation(
        type: OperationType.addToAlbum,
        photos: initialPhotos,
        metadata: {'albumId': album.id},
      ));
    }
    
    notifyListeners();
    return album;
  }

  // Delete an album with history
  void deleteAlbum(CustomAlbum album) {
    final photos = List<AssetEntity>.from(album.photos);
    _albums.remove(album);
    
    if (_selectedAlbum == album) {
      _selectedAlbum = null;
    }

    _history.addOperation(PhotoOperation(
      type: OperationType.delete,
      photos: photos,
      metadata: {
        'albumId': album.id,
        'albumName': album.name,
        'albumType': album.type,
        'sourceAlbums': [album],
      },
    ));
    
    notifyListeners();
  }

  // Bulk operations
  Future<void> bulkAddToAlbums(List<CustomAlbum> targetAlbums) async {
    if (_selectedPhotos.isEmpty) return;

    final photos = List<AssetEntity>.from(_selectedPhotos);
    for (final album in targetAlbums) {
      album.addPhotos(photos);
    }

    _history.addOperation(PhotoOperation(
      type: OperationType.addToAlbum,
      photos: photos,
      metadata: {
        'albumIds': targetAlbums.map((a) => a.id).toList(),
      },
    ));

    _selectedPhotos.clear();
    notifyListeners();
  }

  Future<void> bulkRemoveFromAlbums(List<CustomAlbum> sourceAlbums) async {
    if (_selectedPhotos.isEmpty) return;

    final photos = List<AssetEntity>.from(_selectedPhotos);
    for (final album in sourceAlbums) {
      album.removePhotos(photos);
    }

    _history.addOperation(PhotoOperation(
      type: OperationType.removeFromAlbum,
      photos: photos,
      metadata: {
        'albumIds': sourceAlbums.map((a) => a.id).toList(),
      },
    ));

    _selectedPhotos.clear();
    notifyListeners();
  }

  Future<void> bulkMove(CustomAlbum source, CustomAlbum destination) async {
    if (_selectedPhotos.isEmpty) return;

    final photos = List<AssetEntity>.from(_selectedPhotos);
    source.removePhotos(photos);
    destination.addPhotos(photos);

    _history.addOperation(PhotoOperation(
      type: OperationType.move,
      photos: photos,
      metadata: {
        'sourceAlbum': source.id,
        'destinationAlbum': destination.id,
      },
    ));

    _selectedPhotos.clear();
    notifyListeners();
  }

  // Undo/Redo operations
  Future<void> undo() async {
    final operation = _history.undo();
    if (operation == null) return;

    await _applyOperation(operation);
    notifyListeners();
  }

  Future<void> redo() async {
    final operation = _history.redo();
    if (operation == null) return;

    await _applyOperation(operation);
    notifyListeners();
  }

  Future<void> _applyOperation(PhotoOperation operation) async {
    switch (operation.type) {
      case OperationType.move:
        final sourceAlbum = _findAlbumById(operation.metadata['sourceAlbum']);
        final destAlbum = _findAlbumById(operation.metadata['destinationAlbum']);
        if (sourceAlbum != null && destAlbum != null) {
          sourceAlbum.removePhotos(operation.photos);
          destAlbum.addPhotos(operation.photos);
        }
        break;
      case OperationType.delete:
        final albums = operation.metadata['albums'] as List<CustomAlbum>;
        for (final album in albums) {
          album.removePhotos(operation.photos);
        }
        break;
      case OperationType.addToAlbum:
        final albumIds = operation.metadata['albumIds'] as List<String>;
        for (final id in albumIds) {
          final album = _findAlbumById(id);
          album?.addPhotos(operation.photos);
        }
        break;
      case OperationType.removeFromAlbum:
        final albumIds = operation.metadata['albumIds'] as List<String>;
        for (final id in albumIds) {
          final album = _findAlbumById(id);
          album?.removePhotos(operation.photos);
        }
        break;
      case OperationType.categorize:
        // Handle categorization changes
        break;
    }
  }

  CustomAlbum? _findAlbumById(String id) {
    return _albums.firstWhere((album) => album.id == id);
  }

  // Get operation history for a photo
  List<PhotoOperation> getPhotoHistory(AssetEntity photo) {
    return _history.getHistoryForPhoto(photo);
  }
} 