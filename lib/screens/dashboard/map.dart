import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../services/post_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/image_helper.dart';
import 'dart:ui'; // For BackdropFilter
import 'notifications.dart';
import '../../services/auth_service.dart';
import 'view.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  final PostService _postService = PostService();
  final MapController _mapController = MapController();
  LatLng _currentCenter = const LatLng(11.5564, 104.9282); // Phnom Penh Default
  LatLng? _userLocation;
  
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _recenterToMyLocation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

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
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            margin: const EdgeInsets.only(top: 60),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF9F6).withOpacity(0.9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ],
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4CDC4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Image with modern rounded styling
                    Hero(
                      tag: 'spot_image_${data['id'] ?? data.hashCode}_map',
                      child: Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            )
                          ]
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: CustomImage(
                            data['imageUrl'] ?? '',
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Title & Rating Glass Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              data['title'] ?? 'Unnamed Spot',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 24,
                                height: 1.2,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E1E1E),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF9800).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.white, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  data['rating']?.replaceAll('/5', '') ?? '4.5',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Description
                    const Text(
                      "About this place",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2E2C2A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['description'] ?? 'No description provided.',
                      style: const TextStyle(
                        color: Color(0xFF6B6865),
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Actions
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ViewSpotScreen(
                                    post: data,
                                    heroTag: 'spot_image_${data['id'] ?? data.hashCode}_map',
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: const Color(0xFFE5E0D8)),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'View Details',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF5E5B58),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: InkWell(
                            onTap: () async {
                              final latVal = data['latitude'] ?? 11.5564;
                              final lngVal = data['longitude'] ?? 104.9282;
                              final lat = latVal is String ? double.tryParse(latVal) ?? 11.5564 : (latVal as num).toDouble();
                              final lng = lngVal is String ? double.tryParse(lngVal) ?? 104.9282 : (lngVal as num).toDouble();
                              
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
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF2E2C2A), Color(0xFF1E1E1E)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2E2C2A).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  )
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.directions_rounded, color: Colors.white, size: 22),
                                  SizedBox(width: 8),
                                  Text(
                                    'Get Directions',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _postService.getPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
             return const Center(
               child: CircularProgressIndicator(
                 valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E2C2A)),
               ),
             );
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
              width: 60,
              height: 60,
              alignment: Alignment.topCenter,
              child: GestureDetector(
                onTap: () => _showSpotDetailsBottomSheet(data),
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -5 * _pulseController.value),
                      child: child,
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E2C2A),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2E2C2A).withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ],
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
                  initialZoom: 13.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    // FIX: Changed userAgentPackageName from 'com.example...' to a valid one 
                    // to prevent OSM tile server from blocking requests on real devices.
                    userAgentPackageName: 'com.spotly.app',
                  ),
                  MarkerLayer(markers: [
                    if (_userLocation != null)
                      Marker(
                        point: _userLocation!,
                        width: 70,
                        height: 70,
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blueAccent.withOpacity(0.2 * (1 - _pulseController.value)),
                              ),
                              child: Center(
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blueAccent.withOpacity(0.4),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ...markers,
                  ]),
                ],
              ),

              // Top Gradient for Status Bar protection
              Positioned(
                top: 0, left: 0, right: 0,
                child: IgnorePointer(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                        ]
                      )
                    ),
                  ),
                ),
              ),

              // Top Left Menu (Bell & 3-Dots)
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none, color: Color(0xFF2E2C2A), size: 28),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                      },
                    ),
                    const SizedBox(width: 12),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_horiz, color: Color(0xFF2E2C2A), size: 28),
                      color: const Color(0xFFF9F6F0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

                      onSelected: (value) async {
                        if (value == 'logout') {
                          await AuthService().logout();
                          if (!context.mounted) return;
                          Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
                        } else if (value == 'settings') {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings coming soon!')));
                        } else if (value == 'about') {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: const Color(0xFFEFEBE4),
                              title: const Text('About Spotly'),
                              content: const Text('Spotly is your premium spot-sharing app. Discover, share, and favorite the best places around you!'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))
                              ],
                            ),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'settings',
                          child: Row(children: [Icon(Icons.settings_outlined, size: 20), SizedBox(width: 12), Text('Settings')]),
                        ),
                        const PopupMenuItem(
                          value: 'about',
                          child: Row(children: [Icon(Icons.info_outline, size: 20), SizedBox(width: 12), Text('About')]),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'logout',
                          child: Row(children: [Icon(Icons.logout, color: Colors.redAccent, size: 20), SizedBox(width: 12), Text('Log Out', style: TextStyle(color: Colors.redAccent))]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Modern Floating Controls (Right Side)
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 20,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildMapControlButton(
                            icon: Icons.my_location_rounded,
                            onPressed: _recenterToMyLocation,
                            isTop: true,
                          ),
                          Container(
                            height: 1,
                            width: 30,
                            color: Colors.grey.withOpacity(0.2),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                          ),
                          _buildMapControlButton(
                            icon: Icons.add_rounded,
                            onPressed: () {
                              _mapController.move(
                                _mapController.camera.center,
                                _mapController.camera.zoom + 1,
                              );
                            },
                          ),
                          Container(
                            height: 1,
                            width: 30,
                            color: Colors.grey.withOpacity(0.2),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                          ),
                          _buildMapControlButton(
                            icon: Icons.remove_rounded,
                            onPressed: () {
                              _mapController.move(
                                _mapController.camera.center,
                                _mapController.camera.zoom - 1,
                              );
                            },
                            isBottom: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMapControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isTop = false,
    bool isBottom = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(isTop ? 20 : 0),
          bottom: Radius.circular(isBottom ? 20 : 0),
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: const Color(0xFF383838), size: 24),
        ),
      ),
    );
  }
}
