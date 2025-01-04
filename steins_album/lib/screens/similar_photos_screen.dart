import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

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
  Set<AssetEntity> _selectedPhotos = {};
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Similar Photos'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
        ),
        itemCount: widget.photos.length,
        itemBuilder: (context, index) {
          final photo = widget.photos[index];
          return _SimilarPhotoTile(
            photo: photo,
            isSelected: _selectedPhotos.contains(photo),
            onTap: () {
              setState(() {
                if (_selectedPhotos.contains(photo)) {
                  _selectedPhotos.remove(photo);
                } else {
                  _selectedPhotos.add(photo);
                }
              });
            },
            onDragStarted: () => setState(() => _isDragging = true),
            onDragEnded: () => setState(() => _isDragging = false),
            onDelete: widget.onDelete,
          );
        },
      ),
    );
  }
}

class _SimilarPhotoTile extends StatelessWidget {
  final AssetEntity photo;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnded;
  final Function(AssetEntity) onDelete;

  const _SimilarPhotoTile({
    Key? key,
    required this.photo,
    required this.isSelected,
    required this.onTap,
    required this.onDragStarted,
    required this.onDragEnded,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<AssetEntity>(
      data: photo,
      onDragStarted: onDragStarted,
      onDragEnd: (_) => onDragEnded(),
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
        child: Image(
          image: AssetEntityImageProvider(
            photo,
            isOriginal: false,
            thumbnailSize: const ThumbnailSize.square(300),
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            Hero(
              tag: photo.id,
              child: Image(
                image: AssetEntityImageProvider(
                  photo,
                  isOriginal: false,
                  thumbnailSize: const ThumbnailSize.square(300),
                ),
                fit: BoxFit.cover,
              ),
            ),
            if (isSelected)
              Positioned.fill(
                child: Container(
                  color: Colors.blue.withOpacity(0.3),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 32.0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 