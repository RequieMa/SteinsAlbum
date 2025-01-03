import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/category_manager.dart';

class CategoryStatsWidget extends StatelessWidget {
  const CategoryStatsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryManager>(
      builder: (context, categoryManager, child) {
        final categories = categoryManager.categories;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.entries.map((entry) {
                    final category = entry.value;
                    return _buildCategoryChip(category);
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(CategoryInfo category) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: category.color,
        child: Icon(
          category.icon,
          color: Colors.white,
          size: 16,
        ),
      ),
      label: Text(
        '${category.name} (${category.photoCount})',
        style: TextStyle(color: category.color),
      ),
      backgroundColor: category.color.withOpacity(0.1),
    );
  }
} 