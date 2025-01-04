import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import '../models/ml_inference_model.dart';
import '../widgets/photo_grid.dart';
import '../widgets/map_view.dart';

class CategoryViewScreen extends StatefulWidget {
  final String title;
  final List<AssetPathEntity> albums;
  final ModelType? modelType;
  final MLInferenceModel mlModel;

  const CategoryViewScreen({
    Key? key,
    required this.title,
    required this.albums,
    required this.modelType,
    required this.mlModel,
  }) : super(key: key);

  @override
  _CategoryViewScreenState createState() => _CategoryViewScreenState();
}

class _CategoryViewScreenState extends State<CategoryViewScreen> {
  bool _isReviewMode = false;
  bool _isLoading = true;
  List<AssetEntity> _photos = [];
  final Map<String, List<maps.Marker>> _locationMarkers = {};

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() => _isLoading = true);
    
    List<AssetEntity> allPhotos = [];
    for (final album in widget.albums) {
      final photos = await album.getAssetListRange(start: 0, end: 1000);
      allPhotos.addAll(photos);
    }

    if (widget.modelType != null) {
      // Filter photos based on model type
      List<AssetEntity> filteredPhotos = [];
      for (final photo in allPhotos) {
        final file = await photo.file;
        if (file != null) {
          final result = await widget.mlModel.classifyImage(
            imagePath: file.path,
            modelType: widget.modelType!,
          );
          
          bool shouldInclude = false;
          switch (widget.modelType) {
            case ModelType.selfie:
              shouldInclude = result.label == 'selfie' && result.confidence > 0.7;
              break;
            case ModelType.scene:
              shouldInclude = result.confidence > 0.5;
              break;
            case ModelType.content:
              shouldInclude = true; // Show all content for manual review
              break;
            default:
              shouldInclude = true;
          }
          
          if (shouldInclude) {
            filteredPhotos.add(photo);
          }
        }
      }
      allPhotos = filteredPhotos;
    }

    if (mounted) {
      setState(() {
        _photos = allPhotos;
        _isLoading = false;
      });
    }

    if (widget.title == 'Map View') {
      await _loadLocationMarkers();
    }
  }

  Future<void> _loadLocationMarkers() async {
    for (final photo in _photos) {
      final location = await photo.latlngAsync();
      if (location != null) {
        final file = await photo.file;
        if (file != null) {
          final result = await widget.mlModel.classifyImage(
            imagePath: file.path,
            modelType: ModelType.scene,
          );
          
          final markers = _locationMarkers[result.label] ?? [];
          markers.add(
            maps.Marker(
              markerId: maps.MarkerId(photo.id),
              position: maps.LatLng(
                location.latitude ?? 0.0,
                location.longitude ?? 0.0
              ),
              infoWindow: maps.InfoWindow(title: result.label),
            ),
          );
          _locationMarkers[result.label] = markers;
        }
      }
    }
    setState(() {});
  }

  Future<void> _deletePhoto(AssetEntity photo) async {
    final result = await PhotoManager.editor.deleteWithIds([photo.id]);
    if (result.isNotEmpty && mounted) {
      setState(() {
        _photos.remove(photo);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (widget.title != 'Map View')
            IconButton(
              icon: Icon(_isReviewMode ? Icons.grid_view : Icons.swipe),
              onPressed: () {
                setState(() {
                  _isReviewMode = !_isReviewMode;
                });
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : widget.title == 'Map View'
              ? MapView(markers: _locationMarkers)
              : PhotoGrid(
                  photos: _photos,
                  isReviewMode: _isReviewMode,
                  onDelete: _deletePhoto,
                ),
    );
  }
} 