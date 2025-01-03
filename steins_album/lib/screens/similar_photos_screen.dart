import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class SimilarPhotosScreen extends StatefulWidget {
  final List<AssetEntity> photos;
  final Function(AssetEntity) onDelete;

  const SimilarPhotosScreen({
    Key? key,
    required this.photos,
    required this.onDelete,
  }) : super(key: key);

  @override
  _SimilarPhotosScreenState createState() => _SimilarPhotosScreenState();
}

class _SimilarPhotosScreenState extends State<SimilarPhotosScreen> {
  final GlobalKey _dragTargetKey = GlobalKey();
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Similar Photos (${widget.photos.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.select_all),
            onPressed: () {
              // TODO: Implement multi-select
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
            ),
            itemCount: widget.photos.length,
            itemBuilder: (context, index) {
              final photo = widget.photos[index];
              return _SimilarPhotoTile(
                photo: photo,
                onDragStarted: () => setState(() => _isDragging = true),
                onDragEnded: () => setState(() => _isDragging = false),
                onDelete: widget.onDelete,
              );
            },
          ),
          // Delete target area
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedOpacity(
              opacity: _isDragging ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                height: 100,
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: DragTarget<AssetEntity>(
                  key: _dragTargetKey,
                  builder: (context, candidateData, rejectedData) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: candidateData.isNotEmpty ? 36.0 : 32.0,
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Drop to Delete',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: candidateData.isNotEmpty ? 16.0 : 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  onAccept: (photo) {
                    widget.onDelete(photo);
                    if (widget.photos.length <= 1) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SimilarPhotoTile extends StatelessWidget {
  final AssetEntity photo;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnded;
  final Function(AssetEntity) onDelete;

  const _SimilarPhotoTile({
    Key? key,
    required this.photo,
    required this.onDragStarted,
    required this.onDragEnded,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<AssetEntity>(
      data: photo,
      onDragStarted: onDragStarted,
      onDragEnd: (_) => onDragEnded,
      feedback: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8.0,
              spreadRadius: 2.0,
            ),
          ],
        ),
        child: AssetEntityImage(
          photo,
          isOriginal: false,
          thumbnailSize: const ThumbnailSize.square(300),
          fit: BoxFit.cover,
        ),
      ),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: AssetEntityImage(
                photo,
                isOriginal: false,
                thumbnailSize: const ThumbnailSize.square(300),
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              right: 8.0,
              bottom: 8.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  photo.createDateTime.toString().split(' ')[1],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 