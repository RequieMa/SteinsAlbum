import 'package:photo_manager/photo_manager.dart';
import 'album_model.dart';

enum OperationType {
  move,
  delete,
  categorize,
  addToAlbum,
  removeFromAlbum,
}

class PhotoOperation {
  final OperationType type;
  final List<AssetEntity> photos;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  PhotoOperation({
    required this.type,
    required this.photos,
    required this.metadata,
  }) : timestamp = DateTime.now();

  // Create inverse operation for undo
  PhotoOperation createUndoOperation() {
    switch (type) {
      case OperationType.move:
        return PhotoOperation(
          type: OperationType.move,
          photos: photos,
          metadata: {
            'sourceAlbum': metadata['destinationAlbum'],
            'destinationAlbum': metadata['sourceAlbum'],
          },
        );
      case OperationType.delete:
        return PhotoOperation(
          type: OperationType.addToAlbum,
          photos: photos,
          metadata: {
            'albums': metadata['sourceAlbums'],
          },
        );
      case OperationType.categorize:
        return PhotoOperation(
          type: OperationType.categorize,
          photos: photos,
          metadata: {
            'oldCategory': metadata['newCategory'],
            'newCategory': metadata['oldCategory'],
          },
        );
      case OperationType.addToAlbum:
        return PhotoOperation(
          type: OperationType.removeFromAlbum,
          photos: photos,
          metadata: metadata,
        );
      case OperationType.removeFromAlbum:
        return PhotoOperation(
          type: OperationType.addToAlbum,
          photos: photos,
          metadata: metadata,
        );
    }
  }
}

class PhotoEditHistory {
  final List<PhotoOperation> _operations = [];
  final List<PhotoOperation> _undoneOperations = [];
  final int maxHistorySize;

  PhotoEditHistory({this.maxHistorySize = 50});

  bool get canUndo => _operations.isNotEmpty;
  bool get canRedo => _undoneOperations.isNotEmpty;
  
  List<PhotoOperation> get operations => List.unmodifiable(_operations);

  void addOperation(PhotoOperation operation) {
    _operations.add(operation);
    _undoneOperations.clear(); // Clear redo stack when new operation is added
    
    // Maintain history size limit
    if (_operations.length > maxHistorySize) {
      _operations.removeAt(0);
    }
  }

  PhotoOperation? undo() {
    if (!canUndo) return null;
    
    final operation = _operations.removeLast();
    final undoOperation = operation.createUndoOperation();
    _undoneOperations.add(operation);
    return undoOperation;
  }

  PhotoOperation? redo() {
    if (!canRedo) return null;
    
    final operation = _undoneOperations.removeLast();
    _operations.add(operation);
    return operation;
  }

  List<PhotoOperation> getHistoryForPhoto(AssetEntity photo) {
    return _operations.where((op) => op.photos.contains(photo)).toList();
  }

  void clear() {
    _operations.clear();
    _undoneOperations.clear();
  }
} 