import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:image_picker/image_picker.dart';
import '../models/ml_inference_model.dart';
import '../widgets/category_grid.dart';
import '../widgets/album_stats.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final MLInferenceModel _mlModel = MLInferenceModel();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = true;
  List<AssetPathEntity> _albums = [];

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    final permitted = await PhotoManager.requestPermissionExtend();
    if (permitted.isAuth) {
      await _loadAlbums();
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text('Please grant photo library access to use this app.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _loadAlbums() async {
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      hasAll: true,
    );
    
    if (mounted) {
      setState(() {
        _albums = albums;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );

    if (image != null) {
      // Refresh albums after new photo
      await _loadAlbums();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo added successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (value) {
                  // Theme switching would be handled by a state management solution
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Clear Cache'),
              onTap: () {
                // Clear cache implementation
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'SteinsAlbum',
                  applicationVersion: '1.0.0',
                  applicationIcon: const FlutterLogo(size: 32),
                  children: [
                    const Text('A privacy-focused photo management app'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SteinsAlbum'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAlbums,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAlbums,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: AlbumStats(albums: _albums),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: CategoryGrid(
                      albums: _albums,
                      mlModel: _mlModel,
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: const Icon(Icons.add_photo_alternate),
      ),
    );
  }
} 