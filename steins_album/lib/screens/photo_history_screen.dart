import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import '../models/photo_operation.dart';
import '../services/album_manager.dart';

class PhotoHistoryScreen extends StatelessWidget {
  final AssetEntity photo;

  const PhotoHistoryScreen({
    Key? key,
    required this.photo,
  }) : super(key: key);

  String _getOperationDescription(PhotoOperation operation) {
    switch (operation.type) {
      case OperationType.move:
        return 'Moved between albums';
      case OperationType.delete:
        return 'Deleted from albums';
      case OperationType.categorize:
        return 'Recategorized';
      case OperationType.addToAlbum:
        return 'Added to albums';
      case OperationType.removeFromAlbum:
        return 'Removed from albums';
    }
  }

  Widget _buildHistoryTile(PhotoOperation operation) {
    return ListTile(
      leading: Icon(_getOperationIcon(operation.type)),
      title: Text(_getOperationDescription(operation)),
      subtitle: Text(
        '${operation.timestamp.toString().split('.')[0]}\n'
        '${_getOperationDetails(operation)}',
      ),
      isThreeLine: true,
    );
  }

  IconData _getOperationIcon(OperationType type) {
    switch (type) {
      case OperationType.move:
        return Icons.drive_file_move;
      case OperationType.delete:
        return Icons.delete;
      case OperationType.categorize:
        return Icons.category;
      case OperationType.addToAlbum:
        return Icons.add_photo_alternate;
      case OperationType.removeFromAlbum:
        return Icons.remove_circle_outline;
    }
  }

  String _getOperationDetails(PhotoOperation operation) {
    switch (operation.type) {
      case OperationType.move:
        return 'From: ${operation.metadata['sourceAlbum']}\n'
               'To: ${operation.metadata['destinationAlbum']}';
      case OperationType.delete:
        return 'From albums: ${operation.metadata['albumIds']?.join(", ") ?? "Unknown"}';
      case OperationType.categorize:
        return 'From: ${operation.metadata['oldCategory']}\n'
               'To: ${operation.metadata['newCategory']}';
      case OperationType.addToAlbum:
        return 'Added to: ${operation.metadata['albumIds']?.join(", ") ?? "Unknown"}';
      case OperationType.removeFromAlbum:
        return 'Removed from: ${operation.metadata['albumIds']?.join(", ") ?? "Unknown"}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final albumManager = Provider.of<AlbumManager>(context);
    final operations = albumManager.getPhotoHistory(photo);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit History'),
        actions: [
          if (albumManager.canUndo)
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: () => albumManager.undo(),
            ),
          if (albumManager.canRedo)
            IconButton(
              icon: const Icon(Icons.redo),
              onPressed: () => albumManager.redo(),
            ),
        ],
      ),
      body: Column(
        children: [
          // Photo preview
          Container(
            height: 200,
            width: double.infinity,
            color: Colors.black,
            child: AssetEntityImage(
              photo,
              isOriginal: false,
              thumbnailSize: const ThumbnailSize.square(400),
              fit: BoxFit.contain,
            ),
          ),
          // History list
          Expanded(
            child: operations.isEmpty
                ? const Center(
                    child: Text('No edit history'),
                  )
                : ListView.builder(
                    itemCount: operations.length,
                    itemBuilder: (context, index) {
                      // Show most recent first
                      final operation = operations[operations.length - 1 - index];
                      return _buildHistoryTile(operation);
                    },
                  ),
          ),
        ],
      ),
    );
  }
} 