import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:intl/intl.dart';

class AlbumStats extends StatefulWidget {
  final List<AssetPathEntity> albums;

  const AlbumStats({
    Key? key,
    required this.albums,
  }) : super(key: key);

  @override
  _AlbumStatsState createState() => _AlbumStatsState();
}

class _AlbumStatsState extends State<AlbumStats> {
  int _totalPhotos = 0;
  DateTime? _oldestPhoto;
  DateTime? _newestPhoto;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    int total = 0;
    DateTime? oldest;
    DateTime? newest;

    for (final album in widget.albums) {
      final count = await album.assetCountAsync;
      total += count;

      final photos = await album.getAssetListRange(
        start: 0,
        end: count,
        filterOption: FilterOptionGroup(
          imageOption: const FilterOption(
            sizeConstraint: SizeConstraint(ignoreSize: true),
          ),
        ),
      );

      for (final photo in photos) {
        final date = photo.createDateTime;
        if (oldest == null || date.isBefore(oldest)) {
          oldest = date;
        }
        if (newest == null || date.isAfter(newest)) {
          newest = date;
        }
      }
    }

    if (mounted) {
      setState(() {
        _totalPhotos = total;
        _oldestPhoto = oldest;
        _newestPhoto = newest;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final dateFormat = DateFormat('MMM d, y');

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Photo Library Stats',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16.0),
            _StatRow(
              icon: Icons.photo_library,
              label: 'Total Photos',
              value: _totalPhotos.toString(),
            ),
            if (_oldestPhoto != null) ...[
              const SizedBox(height: 8.0),
              _StatRow(
                icon: Icons.access_time,
                label: 'Oldest Photo',
                value: dateFormat.format(_oldestPhoto!),
              ),
            ],
            if (_newestPhoto != null) ...[
              const SizedBox(height: 8.0),
              _StatRow(
                icon: Icons.update,
                label: 'Newest Photo',
                value: dateFormat.format(_newestPhoto!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20.0),
        const SizedBox(width: 8.0),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
        ),
      ],
    );
  }
} 