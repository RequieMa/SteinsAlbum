import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatefulWidget {
  final Map<String, List<Marker>> markers;

  const MapView({
    Key? key,
    required this.markers,
  }) : super(key: key);

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late GoogleMapController _controller;
  String _selectedCategory = 'All';
  Set<Marker> _visibleMarkers = {};

  @override
  void initState() {
    super.initState();
    _updateVisibleMarkers();
  }

  void _updateVisibleMarkers() {
    if (_selectedCategory == 'All') {
      _visibleMarkers = widget.markers.values
          .expand((markers) => markers)
          .toSet();
    } else {
      _visibleMarkers = Set.from(widget.markers[_selectedCategory] ?? []);
    }
    setState(() {});
  }

  void _fitBounds() {
    if (_visibleMarkers.isEmpty) return;

    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (final marker in _visibleMarkers) {
      final lat = marker.position.latitude;
      final lng = marker.position.longitude;

      minLat = minLat < lat ? minLat : lat;
      maxLat = maxLat > lat ? maxLat : lat;
      minLng = minLng < lng ? minLng : lng;
      maxLng = maxLng > lng ? maxLng : lng;
    }

    _controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        50.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['All', ...widget.markers.keys];

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(0, 0),
            zoom: 2,
          ),
          markers: _visibleMarkers,
          onMapCreated: (controller) {
            _controller = controller;
            _fitBounds();
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
        ),
        Positioned(
          top: 16.0,
          left: 16.0,
          right: 16.0,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                      _updateVisibleMarkers();
                      _fitBounds();
                    });
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
} 