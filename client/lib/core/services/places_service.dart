import 'package:google_maps_flutter/google_maps_flutter.dart';

class DocumentCenterPlace {
  final String id;
  final String name;
  final String address;
  final String category;
  final LatLng location;
  final double rating;
  final String distance;

  DocumentCenterPlace({
    required this.id,
    required this.name,
    required this.address,
    required this.category,
    required this.location,
    required this.rating,
    required this.distance,
  });
}

class PlacesService {
  /// Get nearby document processing and government service centers
  Future<List<DocumentCenterPlace>> getNearbyCenters(LatLng userLocation) async {
    // Return structured mock places around user location for demo/production fallback
    final double lat = userLocation.latitude;
    final double lng = userLocation.longitude;

    return [
      DocumentCenterPlace(
        id: 'place_1',
        name: 'Aadhaar Seva Kendra & Document Center',
        address: 'Sector 62, Near Metro Station, New Delhi',
        category: 'Aadhaar & Identity',
        location: LatLng(lat + 0.005, lng + 0.004),
        rating: 4.6,
        distance: '0.8 km',
      ),
      DocumentCenterPlace(
        id: 'place_2',
        name: 'Passport Seva Kendra (PSK)',
        address: 'Commercial Complex, Institutional Area',
        category: 'Passport Services',
        location: LatLng(lat - 0.008, lng + 0.006),
        rating: 4.8,
        distance: '1.4 km',
      ),
      DocumentCenterPlace(
        id: 'place_3',
        name: 'Regional Transport Office (RTO)',
        address: 'Transport Department Hub',
        category: 'Driving License',
        location: LatLng(lat + 0.012, lng - 0.007),
        rating: 4.2,
        distance: '2.5 km',
      ),
      DocumentCenterPlace(
        id: 'place_4',
        name: 'Print & Digital Express Cyber Station',
        address: 'Main Market Plaza, Shop #14',
        category: 'Printing & Scanning',
        location: LatLng(lat - 0.003, lng - 0.004),
        rating: 4.7,
        distance: '0.5 km',
      ),
    ];
  }
}
