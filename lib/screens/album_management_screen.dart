import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import '../models/album_model.dart';
import '../services/album_manager.dart';

class AlbumManagementScreen extends StatefulWidget {
  const AlbumManagementScreen({Key? key}) : super(key: key);

  @override
  _AlbumManagementScreenState createState() => _AlbumManagementScreenState();
}

class _AlbumManagementScreenState extends State<AlbumManagementScreen> {
  final List<AssetEntity> _selectedPhotos = [];
  bool _isSelectionMode = false;

  void _createNewAlbum() {
    showDialog(
      context: context,
      builder: (context) => _CreateAlbumDialog(),
    );
  }

  void _showBatchOperationsMenu() {
    if (_selectedPhotos.isEmpty) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => _BatchOperationsSheet(
        selectedPhotos: _selectedPhotos,
        onComplete: () {
          setState(() {
            _selectedPhotos.clear();
            _isSelectionMode = false;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final albumManager = Provider.of<AlbumManager>(context);
    final albums = albumManager.albums;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isSelectionMode 
          ? '${_selectedPhotos.length} Selected'
          : 'Albums'
        ),
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: () {
                // TODO: Implement select all
              },
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: _showBatchOperationsMenu,
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.create_new_folder),
              onPressed: _createNewAlbum,
            ),
          ],
        ],
      ),
      body: ReorderableListView.builder(
        itemCount: albums.length,
        onReorder: (oldIndex, newIndex) {
          // Handle album reordering
        },
        itemBuilder: (context, index) {
          final album = albums[index];
          return _AlbumTile(
            key: Key(album.id),
            album: album,
            isSelectionMode: _isSelectionMode,
            onSelectionModeChange: (value) {
              setState(() {
                _isSelectionMode = value;
              });
            },
            onPhotosSelected: (photos) {
              setState(() {
                _selectedPhotos.addAll(photos);
              });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewAlbum,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CreateAlbumDialog extends StatefulWidget {
  @override
  _CreateAlbumDialogState createState() => _CreateAlbumDialogState();
}

class _CreateAlbumDialogState extends State<_CreateAlbumDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  AlbumType _selectedType = AlbumType.custom;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Album'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Album Name',
              hintText: 'Enter album name',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (Optional)',
              hintText: 'Enter description',
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<AlbumType>(
            value: _selectedType,
            decoration: const InputDecoration(
              labelText: 'Album Type',
            ),
            items: AlbumType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.toString().split('.').last),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedType = value!;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              final albumManager = Provider.of<AlbumManager>(context, listen: false);
              albumManager.createAlbum(
                name: _nameController.text,
                description: _descriptionController.text,
                type: _selectedType,
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

class _BatchOperationsSheet extends StatelessWidget {
  final List<AssetEntity> selectedPhotos;
  final VoidCallback onComplete;

  const _BatchOperationsSheet({
    Key? key,
    required this.selectedPhotos,
    required this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final albumManager = Provider.of<AlbumManager>(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.add_to_photos),
            title: const Text('Add to Album'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => _SelectAlbumsDialog(
                  photos: selectedPhotos,
                  onComplete: onComplete,
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Remove from Albums'),
            onTap: () {
              // Show albums containing these photos
              final containingAlbums = albumManager.findAlbumsContainingPhoto(selectedPhotos.first);
              showDialog(
                context: context,
                builder: (context) => _SelectAlbumsDialog(
                  photos: selectedPhotos,
                  albums: containingAlbums,
                  isRemove: true,
                  onComplete: onComplete,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SelectAlbumsDialog extends StatefulWidget {
  final List<AssetEntity> photos;
  final List<CustomAlbum>? albums;
  final bool isRemove;
  final VoidCallback onComplete;

  const _SelectAlbumsDialog({
    Key? key,
    required this.photos,
    this.albums,
    this.isRemove = false,
    required this.onComplete,
  }) : super(key: key);

  @override
  _SelectAlbumsDialogState createState() => _SelectAlbumsDialogState();
}

class _SelectAlbumsDialogState extends State<_SelectAlbumsDialog> {
  final Set<CustomAlbum> _selectedAlbums = {};

  @override
  Widget build(BuildContext context) {
    final albumManager = Provider.of<AlbumManager>(context);
    final albums = widget.albums ?? albumManager.albums;

    return AlertDialog(
      title: Text(widget.isRemove ? 'Remove from Albums' : 'Add to Albums'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: albums.length,
          itemBuilder: (context, index) {
            final album = albums[index];
            return CheckboxListTile(
              title: Text(album.name),
              subtitle: Text('${album.photos.length} photos'),
              value: _selectedAlbums.contains(album),
              onChanged: (selected) {
                setState(() {
                  if (selected!) {
                    _selectedAlbums.add(album);
                  } else {
                    _selectedAlbums.remove(album);
                  }
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_selectedAlbums.isNotEmpty) {
              if (widget.isRemove) {
                albumManager.batchRemoveFromAlbums(
                  widget.photos,
                  _selectedAlbums.toList(),
                );
              } else {
                albumManager.batchAddToAlbums(
                  widget.photos,
                  _selectedAlbums.toList(),
                );
              }
              Navigator.pop(context);
              widget.onComplete();
            }
          },
          child: Text(widget.isRemove ? 'Remove' : 'Add'),
        ),
      ],
    );
  }
}

class _AlbumTile extends StatelessWidget {
  final CustomAlbum album;
  final bool isSelectionMode;
  final ValueChanged<bool> onSelectionModeChange;
  final ValueChanged<List<AssetEntity>> onPhotosSelected;

  const _AlbumTile({
    Key? key,
    required this.album,
    required this.isSelectionMode,
    required this.onSelectionModeChange,
    required this.onPhotosSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: album.photos.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AssetEntityImage(
                  album.photos.first,
                  isOriginal: false,
                  thumbnailSize: const ThumbnailSize.square(56),
                  fit: BoxFit.cover,
                ),
              )
            : const Icon(Icons.photo_album),
      ),
      title: Text(album.name),
      subtitle: Text('${album.photos.length} photos'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelectionMode)
            Checkbox(
              value: false, // TODO: Implement selection state
              onChanged: (value) {
                // TODO: Implement selection
              },
            ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => _AlbumOptionsSheet(album: album),
              );
            },
          ),
        ],
      ),
      onTap: () {
        // Navigate to album details
      },
      onLongPress: () {
        if (!isSelectionMode) {
          onSelectionModeChange(true);
        }
      },
    );
  }
}

class _AlbumOptionsSheet extends StatelessWidget {
  final CustomAlbum album;

  const _AlbumOptionsSheet({
    Key? key,
    required this.album,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final albumManager = Provider.of<AlbumManager>(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Album'),
            onTap: () {
              // TODO: Implement edit album
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete Album'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Album?'),
                  content: Text('Are you sure you want to delete "${album.name}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        albumManager.deleteAlbum(album);
                        Navigator.pop(context);
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
            },
          ),
        ],
      ),
    );
  }
} 