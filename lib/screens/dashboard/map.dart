import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../services/post_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/image_helper.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final PostService _postService = PostService();
  final MapController _mapController = MapController();
  LatLng _currentCenter = const LatLng(11.5564, 104.9282); // Phnom Penh Default
  LatLng? _userLocation;

  Future<void> _recenterToMyLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      final position = await Geolocator.getCurrentPosition();
      final userLocation = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _currentCenter = userLocation;
        _userLocation = userLocation;
      });
      _mapController.move(userLocation, 14.5);
    } catch (_) {
      // Fail silently or fallback
    }
  }

  void _showSpotDetailsBottomSheet(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFEFEBE4),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bottom sheet drag handle
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB3A89F),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Image Card
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CustomImage(
                  data['imageUrl'] ?? '',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),

              // Title and Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      data['title'] ?? 'Unnamed Spot',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E2C2A),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF383838),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          data['rating']?.replaceAll('/5', '') ?? '4.5',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                data['description'] ?? 'No description provided.',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF7A7774),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Close / Action Button
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF383838),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final latVal = data['latitude'] ?? 11.5564;
                        final lngVal = data['longitude'] ?? 104.9282;
                        final lat = latVal is String ? double.tryParse(latVal) ?? 11.5564 : (latVal as num).toDouble();
                        final lng = lngVal is String ? double.tryParse(lngVal) ?? 104.9282 : (lngVal as num).toDouble();
                        
                        // Try native turn-by-turn navigation first
                        final nativeUrl = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
                        final webUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
                        
                        try {
                          if (!await launchUrl(nativeUrl, mode: LaunchMode.externalApplication)) {
                            await launchUrl(webUrl, mode: LaunchMode.externalApplication);
                          }
                        } catch (e) {
                          try {
                            await launchUrl(webUrl, mode: LaunchMode.externalApplication);
                          } catch (_) {}
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF383838),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Directions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EE),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _postService.getPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final posts = snapshot.data ?? [];
          final markers = posts.map((data) {
            final latVal = data['latitude'] ?? 11.5564;
            final lngVal = data['longitude'] ?? 104.9282;
            final lat = latVal is String ? double.tryParse(latVal) ?? 11.5564 : (latVal as num).toDouble();
            final lng = lngVal is String ? double.tryParse(lngVal) ?? 104.9282 : (lngVal as num).toDouble();

            return Marker(
              point: LatLng(lat, lng),
              width: 44,
              height: 44,
              child: GestureDetector(
                onTap: () => _showSpotDetailsBottomSheet(data),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(2),
                  child: const Icon(
                    Icons.location_on,
                    color: Color(0xFF383838), // Premium dark brown pin matching the theme
                    size: 32,
                  ),
                ),
              ),
            );
          }).toList();

          return Stack(
            children: [
              // Map View
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentCenter,
                  initialZoom: 12.5,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.spotly_fresh',
                  ),
                  MarkerLayer(markers: [
                    if (_userLocation != null)
                      Marker(
                        point: _userLocation!,
                        width: 24,
                        height: 24,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ...markers,
                  ]),
                ],
              ),

              // Floating Utility Controls (Top Right)
              Positioned(
                top: 24,
                right: 24,
                child: Column(
                  children: [
                    // Location Tracker / Recenter Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.my_location, color: Color(0xFF383838)),
                        onPressed: _recenterToMyLocation,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Zoom In Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Color(0xFF383838)),
                        onPressed: () {
                          _mapController.move(
                            _mapController.camera.center,
                            _mapController.camera.zoom + 1,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Zoom Out Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.remove, color: Color(0xFF383838)),
                        onPressed: () {
                          _mapController.move(
                            _mapController.camera.center,
                            _mapController.camera.zoom - 1,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
