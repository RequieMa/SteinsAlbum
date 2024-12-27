import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../screens/similar_photos_screen.dart';

class PhotoGrid extends StatefulWidget {
  final List<AssetEntity> photos;
  final bool isReviewMode;
  final Function(AssetEntity) onDelete;

  const PhotoGrid({
    Key? key,
    required this.photos,
    required this.isReviewMode,
    required this.onDelete,
  }) : super(key: key);

  @override
  _PhotoGridState createState() => _PhotoGridState();
}

class _PhotoGridState extends State<PhotoGrid> {
  final GlobalKey _dragTargetKey = GlobalKey();
  bool _isDragging = false;
  
  // Mock similar photos grouping - In real app, use ML to group similar photos
  Map<String, List<AssetEntity>> _groupSimilarPhotos() {
    Map<String, List<AssetEntity>> groups = {};
    for (var photo in widget.photos) {
      // Mock grouping logic - replace with actual similarity detection
      String groupKey = photo.createDateTime.toString().split(' ')[0];
      groups.putIfAbsent(groupKey, () => []).add(photo);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isReviewMode) {
      return _buildReviewMode();
    }
    
    final photoGroups = _groupSimilarPhotos();
    final representatives = photoGroups.entries.map((e) => e.value.first).toList();

    return Stack(
      children: [
        MasonryGridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
          itemCount: representatives.length,
          itemBuilder: (context, index) {
            final photo = representatives[index];
            final similarCount = photoGroups[photo.createDateTime.toString().split(' ')[0]]!.length;
            return _PhotoTile(
              photo: photo,
              similarCount: similarCount > 1 ? similarCount : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SimilarPhotosScreen(
                      photos: photoGroups[photo.createDateTime.toString().split(' ')[0]]!,
                      onDelete: widget.onDelete,
                    ),
                  ),
                );
              },
              onDragStarted: () => setState(() => _isDragging = true),
              onDragEnded: () => setState(() => _isDragging = false),
              onDelete: widget.onDelete,
            );
          },
        ),
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
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewMode() {
    return PageView.builder(
      itemCount: widget.photos.length,
      itemBuilder: (context, index) {
        return _ReviewCard(
          photo: widget.photos[index],
          onDelete: widget.onDelete,
        );
      },
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final AssetEntity photo;
  final int? similarCount;
  final VoidCallback onTap;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnded;
  final Function(AssetEntity) onDelete;

  const _PhotoTile({
    Key? key,
    required this.photo,
    this.similarCount,
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
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            Hero(
              tag: photo.id,
              child: AssetEntityImage(
                photo,
                isOriginal: false,
                thumbnailSize: const ThumbnailSize.square(300),
                fit: BoxFit.cover,
              ),
            ),
            if (similarCount != null)
              Positioned(
                top: 8.0,
                right: 8.0,
                child: Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$similarCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
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

class _ReviewCard extends StatelessWidget {
  final AssetEntity photo;
  final Function(AssetEntity) onDelete;

  const _ReviewCard({
    Key? key,
    required this.photo,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(photo.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 32.0,
        ),
      ),
      secondaryBackground: Container(
        color: Colors.green,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(
          Icons.check,
          color: Colors.white,
          size: 32.0,
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onDelete(photo);
          return true;
        }
        return false;
      },
      child: Center(
        child: Hero(
          tag: photo.id,
          child: AssetEntityImage(
            photo,
            isOriginal: true,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
} 