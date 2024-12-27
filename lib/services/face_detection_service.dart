import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:collection';

class FaceGroup {
  final String id;
  final List<AssetEntity> photos;
  String? name;
  AssetEntity? representativePhoto;

  FaceGroup({
    required this.id,
    required this.photos,
    this.name,
    this.representativePhoto,
  }) {
    representativePhoto ??= photos.first;
  }
}

class FaceDetectionService extends ChangeNotifier {
  final Map<String, FaceGroup> _faceGroups = {};
  final Queue<AssetEntity> _processingQueue = Queue();
  bool _isProcessing = false;

  List<FaceGroup> get faceGroups => _faceGroups.values.toList();
  bool get isProcessing => _isProcessing;

  // Queue photos for face detection
  void queueForProcessing(List<AssetEntity> photos) {
    for (final photo in photos) {
      if (!_processingQueue.contains(photo)) {
        _processingQueue.add(photo);
      }
    }
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isProcessing || _processingQueue.isEmpty) return;

    _isProcessing = true;
    notifyListeners();

    try {
      while (_processingQueue.isNotEmpty) {
        final photo = _processingQueue.removeFirst();
        await _detectAndGroupFaces(photo);
        // Add artificial delay to prevent UI blocking
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> _detectAndGroupFaces(AssetEntity photo) async {
    // TODO: Implement actual face detection using ML Kit or similar
    // For now, we'll use a simple simulation
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Simulate finding a face and adding to a group
    final timestamp = await photo.createDateTime;
    final groupId = '${timestamp.year}_${timestamp.month}';
    
    if (!_faceGroups.containsKey(groupId)) {
      _faceGroups[groupId] = FaceGroup(
        id: groupId,
        photos: [photo],
        name: 'Face Group $groupId',
      );
    } else {
      _faceGroups[groupId]!.photos.add(photo);
    }
    
    notifyListeners();
  }

  // Name a face group
  void nameFaceGroup(String groupId, String name) {
    if (_faceGroups.containsKey(groupId)) {
      _faceGroups[groupId]!.name = name;
      notifyListeners();
    }
  }

  // Set representative photo for a group
  void setRepresentativePhoto(String groupId, AssetEntity photo) {
    if (_faceGroups.containsKey(groupId) &&
        _faceGroups[groupId]!.photos.contains(photo)) {
      _faceGroups[groupId]!.representativePhoto = photo;
      notifyListeners();
    }
  }

  // Get face groups for a specific photo
  List<FaceGroup> getGroupsForPhoto(AssetEntity photo) {
    return _faceGroups.values
        .where((group) => group.photos.contains(photo))
        .toList();
  }

  // Merge two face groups
  void mergeFaceGroups(String groupId1, String groupId2) {
    if (!_faceGroups.containsKey(groupId1) ||
        !_faceGroups.containsKey(groupId2)) {
      return;
    }

    final group1 = _faceGroups[groupId1]!;
    final group2 = _faceGroups[groupId2]!;

    // Create a new merged group
    final mergedPhotos = {...group1.photos, ...group2.photos}.toList();
    final mergedGroup = FaceGroup(
      id: groupId1,
      photos: mergedPhotos,
      name: group1.name ?? group2.name,
      representativePhoto: group1.representativePhoto,
    );

    // Replace the first group with merged group and remove the second
    _faceGroups[groupId1] = mergedGroup;
    _faceGroups.remove(groupId2);

    notifyListeners();
  }

  // Clear all face groups
  void clear() {
    _faceGroups.clear();
    _processingQueue.clear();
    _isProcessing = false;
    notifyListeners();
  }
} 