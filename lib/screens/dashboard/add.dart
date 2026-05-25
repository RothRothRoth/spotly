import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../services/auth_service.dart';
import '../../services/post_service.dart';
import '../../utils/image_helper.dart';

class AddSpotScreen extends StatefulWidget {
  final Map<String, dynamic>? existingPost;

  const AddSpotScreen({super.key, this.existingPost});

  @override
  State<AddSpotScreen> createState() => _AddSpotScreenState();
}

class _AddSpotScreenState extends State<AddSpotScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _mapController = MapController();
  int _rating = 5;

  XFile? _selectedImage;
  LatLng _pinLocation = const LatLng(11.5564, 104.9282); // Phnom Penh default
  String _address = '';
  bool _isLoading = false;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.existingPost != null) {
      final p = widget.existingPost!;
      _titleController.text = p['title'] ?? '';
      _descriptionController.text = p['description'] ?? '';
      
      final existingRatingStr = (p['rating'] ?? '').replaceAll('/5', '');
      _rating = int.tryParse(existingRatingStr.split('.').first) ?? 5;
      
      _address = p['address'] ?? '';
      _existingImageUrl = p['imageUrl'];

      final latVal = p['latitude'] ?? 11.5564;
      final lngVal = p['longitude'] ?? 104.9282;
      final lat = latVal is String ? double.tryParse(latVal) ?? 11.5564 : (latVal as num).toDouble();
      final lng = lngVal is String ? double.tryParse(lngVal) ?? 104.9282 : (lngVal as num).toDouble();
      _pinLocation = LatLng(lat, lng);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    // Aggressive compression to prevent Firestore size limit errors
    final picked = await picker.pickImage(
      source: source, 
      imageQuality: 30,
      maxWidth: 600,
    );
    if (picked != null) {
      setState(() => _selectedImage = picked);
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFEFEBE4),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _useMyLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    final position = await Geolocator.getCurrentPosition();
    final latlng = LatLng(position.latitude, position.longitude);
    await _updatePin(latlng);
    _mapController.move(latlng, 15);
  }

  Future<void> _updatePin(LatLng latlng) async {
    setState(() => _pinLocation = latlng);
    try {
      final placemarks = await placemarkFromCoordinates(
        latlng.latitude,
        latlng.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          _address =
              '${p.street ?? ''}, ${p.locality ?? ''}, ${p.country ?? ''}'
                  .replaceAll(RegExp(r'^,\s*|,\s*$'), '');
        });
      }
    } catch (_) {
      setState(() => _address = '${latlng.latitude}, ${latlng.longitude}');
    }
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a spot name')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = AuthService().currentUser;
      final postService = PostService();

      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await postService.uploadImage(_selectedImage!);
      } else if (_existingImageUrl != null) {
        imageUrl = _existingImageUrl;
      } else {
        imageUrl = 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80';
      }

      final postData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'rating': '$_rating/5',
        'authorName': user?.username ?? 'Anonymous',
        'latitude': _pinLocation.latitude,
        'longitude': _pinLocation.longitude,
        'address': _address,
        'imageUrl': imageUrl,
      };

      if (widget.existingPost != null) {
        await postService.updatePost(widget.existingPost!['id'], postData);
      } else {
        await postService.addPost(postData);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Spot added!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEBE4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEFEBE4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: GestureDetector(
          onTap: _isLoading ? null : _submit,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF383838),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Continue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Text(
                widget.existingPost != null ? 'Edit your spot!' : 'Add your spot!',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Image picker
            GestureDetector(
              onTap: _showImageSourceSheet,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: kIsWeb
                            ? Image.network(
                                _selectedImage!.path,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(_selectedImage!.path),
                                fit: BoxFit.cover,
                              ),
                      )
                    : (_existingImageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CustomImage(
                              _existingImageUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined,
                                  size: 40, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                'Click to add your image',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          )),
              ),
            ),

            const SizedBox(height: 24),

            // Location section
            const Text(
              'Spot location',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 10),

            // Map
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _pinLocation,
                        initialZoom: 13,
                        onTap: (tapPosition, latlng) => _updatePin(latlng),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _pinLocation,
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.redAccent,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.my_location, color: Color(0xFF383838), size: 20),
                          onPressed: _useMyLocation,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Text(
              'Click on map and pin your exact location',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),

            if (_address.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                '📍 $_address',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],

            const SizedBox(height: 20),

            // Spot name
            const Text(
              'Spot Name',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter your spot name',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Description
            const Text(
              'Description',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Enter your spot's description",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Personal Rating
            const Text(
              'Rating',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 36,
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
