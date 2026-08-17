import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:papersafe/core/services/places_service.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  final PlacesService _placesService = PlacesService();
  GoogleMapController? _mapController;

  static const LatLng _defaultLocation = LatLng(28.6139, 77.2090); // New Delhi
  List<DocumentCenterPlace> _places = [];
  DocumentCenterPlace? _selectedPlace;
  Set<Marker> _markers = {};
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadNearbyPlaces();
  }

  Future<void> _loadNearbyPlaces() async {
    final places = await _placesService.getNearbyCenters(_defaultLocation);
    setState(() {
      _places = places;
      _updateMarkers();
    });
  }

  void _updateMarkers() {
    final filtered = _selectedCategory == 'All'
        ? _places
        : _places.where((p) => p.category.toLowerCase().contains(_selectedCategory.toLowerCase())).toList();

    _markers = filtered.map((place) {
      return Marker(
        markerId: MarkerId(place.id),
        position: place.location,
        infoWindow: InfoWindow(title: place.name, snippet: place.category),
        onTap: () {
          setState(() => _selectedPlace = place);
        },
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Nearby Government & Print Centers', style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: Stack(
        children: [
          // Google Map View
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _defaultLocation,
              zoom: 14.0,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),

          // Filter Chips Top Bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ['All', 'Aadhaar', 'Passport', 'RTO', 'Printing'].map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = category;
                            _updateMarkers();
                          });
                        }
                      },
                      selectedColor: Colors.tealAccent,
                      backgroundColor: Colors.black87,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Selected Place Detail Bottom Sheet Card
          if (_selectedPlace != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.tealAccent.withOpacity(0.5)),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, blurRadius: 16, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.tealAccent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.location_on, color: Colors.tealAccent),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedPlace!.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${_selectedPlace!.category} • ${_selectedPlace!.distance} away',
                                style: const TextStyle(color: Colors.tealAccent, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white54),
                          onPressed: () => setState(() => _selectedPlace = null),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _selectedPlace!.address,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Opening directions to ${_selectedPlace!.name}')),
                          );
                        },
                        icon: const Icon(Icons.directions, color: Colors.black),
                        label: const Text('Get Directions', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.tealAccent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
