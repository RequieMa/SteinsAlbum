import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:collection';
import '../models/photo_operation.dart';

/// Information about a photo category including its visual representation
class CategoryInfo {
  final String name;
  final Color color;
  final IconData icon;
  int photoCount;

  CategoryInfo({
    required this.name,
    required this.color,
    required this.icon,
    this.photoCount = 0,
  });
}

/// Manages photo categorization and category-related operations.
/// 
/// This service handles:
/// - Category definitions and their visual representation
/// - Photo-to-category assignments
/// - Category photo counts
/// - Background categorization processing
class CategoryManager extends ChangeNotifier {
  final Map<String, CategoryInfo> _categories = {
    'landscape': CategoryInfo(
      name: 'Landscape',
      color: Colors.green,
      icon: Icons.landscape,
    ),
    'portrait': CategoryInfo(
      name: 'Portrait',
      color: Colors.orange,
      icon: Icons.portrait,
    ),
    'food': CategoryInfo(
      name: 'Food',
      color: Colors.red,
      icon: Icons.restaurant,
    ),
    'document': CategoryInfo(
      name: 'Document',
      color: Colors.blue,
      icon: Icons.description,
    ),
    'selfie': CategoryInfo(
      name: 'Selfie',
      color: Colors.purple,
      icon: Icons.face,
    ),
  };

  final Map<AssetEntity, Set<String>> _photoCategories = {};
  final Queue<AssetEntity> _categorizationQueue = Queue();
  bool _isProcessing = false;

  /// Returns an unmodifiable map of all available categories
  Map<String, CategoryInfo> get categories => Map.unmodifiable(_categories);

  /// Returns the set of categories assigned to a specific photo
  /// If the photo has no categories, returns an empty set
  Set<String> getCategoriesForPhoto(AssetEntity photo) => 
      Set.from(_photoCategories[photo] ?? {});

  /// Whether the service is currently processing the categorization queue
  bool get isProcessing => _isProcessing;

  /// Adds a new category or updates an existing one
  /// 
  /// Parameters:
  /// - [key]: Unique identifier for the category
  /// - [info]: Category information including name, color, and icon
  void addCategory(String key, CategoryInfo info) {
    _categories[key] = info;
    notifyListeners();
  }

  /// Updates the photo count for a specific category
  /// 
  /// Parameters:
  /// - [category]: The category key to update
  /// - [delta]: The change in count (positive or negative)
  void updatePhotoCount(String category, int delta) {
    if (_categories.containsKey(category)) {
      _categories[category]!.photoCount += delta;
      notifyListeners();
    }
  }

  /// Assigns categories to a photo and updates category counts
  /// 
  /// Parameters:
  /// - [photo]: The photo to categorize
  /// - [categories]: Set of category keys to assign to the photo
  Future<void> categorizePhoto(AssetEntity photo, Set<String> categories) async {
    final oldCategories = _photoCategories[photo] ?? {};
    _photoCategories[photo] = categories;
    
    // Update photo counts
    for (final category in oldCategories) {
      updatePhotoCount(category, -1);
    }
    for (final category in categories) {
      updatePhotoCount(category, 1);
    }
    
    notifyListeners();
  }

  /// Adds a photo to the categorization queue for background processing
  /// 
  /// The photo will be processed when resources are available
  void queueForCategorization(AssetEntity photo) {
    if (!_categorizationQueue.contains(photo)) {
      _categorizationQueue.add(photo);
      _processCategorizationQueue();
    }
  }

  /// Processes the categorization queue in the background
  /// 
  /// This method ensures only one processing task runs at a time
  Future<void> _processCategorizationQueue() async {
    if (_isProcessing || _categorizationQueue.isEmpty) return;

    _isProcessing = true;
    notifyListeners();

    try {
      while (_categorizationQueue.isNotEmpty) {
        final photo = _categorizationQueue.removeFirst();
        // TODO: Implement ML model inference here
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Clears all category assignments and resets photo counts
  void clear() {
    _photoCategories.clear();
    _categorizationQueue.clear();
    for (final category in _categories.values) {
      category.photoCount = 0;
    }
    notifyListeners();
  }
} 