import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../models/ml_inference_model.dart';
import '../screens/category_view_screen.dart';

class CategoryGrid extends StatelessWidget {
  final List<AssetPathEntity> albums;
  final MLInferenceModel mlModel;

  const CategoryGrid({
    Key? key,
    required this.albums,
    required this.mlModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'title': 'Scenes',
        'icon': Icons.landscape,
        'color': Colors.blue,
        'type': ModelType.scene,
      },
      {
        'title': 'Selfies',
        'icon': Icons.face,
        'color': Colors.green,
        'type': ModelType.selfie,
      },
      {
        'title': 'Content',
        'icon': Icons.image,
        'color': Colors.orange,
        'type': ModelType.content,
      },
      {
        'title': 'Map View',
        'icon': Icons.map,
        'color': Colors.purple,
        'type': null,
      },
    ];

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        childAspectRatio: 1.5,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final category = categories[index];
          return _buildCategoryCard(context, category);
        },
        childCount: categories.length,
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Map<String, dynamic> category) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryViewScreen(
                title: category['title'],
                albums: albums,
                modelType: category['type'],
                mlModel: mlModel,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                category['color'],
                category['color'].withOpacity(0.7),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                category['icon'],
                size: 40.0,
                color: Colors.white,
              ),
              const SizedBox(height: 8.0),
              Text(
                category['title'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 