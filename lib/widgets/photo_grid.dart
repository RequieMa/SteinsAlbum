import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class PhotoGrid extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return isReviewMode
        ? _buildReviewMode(context)
        : _buildGridMode(context);
  }

  Widget _buildGridMode(BuildContext context) {
    return MasonryGridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return _PhotoTile(
          photo: photos[index],
          onDelete: onDelete,
        );
      },
    );
  }

  Widget _buildReviewMode(BuildContext context) {
    return PageView.builder(
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return _ReviewCard(
          photo: photos[index],
          onDelete: onDelete,
        );
      },
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final AssetEntity photo;
  final Function(AssetEntity) onDelete;

  const _PhotoTile({
    Key? key,
    required this.photo,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showDeleteDialog(context),
      child: Hero(
        tag: photo.id,
        child: AssetEntityImage(
          photo,
          isOriginal: false,
          thumbnailSize: const ThumbnailSize.square(300),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onDelete(photo);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
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