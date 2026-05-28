import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../utils/image_helper.dart';
import '../../services/post_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
class ViewSpotScreen extends StatefulWidget {
  final Map<String, dynamic> post;
  final String heroTag;

  const ViewSpotScreen({super.key, required this.post, required this.heroTag});

  @override
  State<ViewSpotScreen> createState() => _ViewSpotScreenState();
}

class _ViewSpotScreenState extends State<ViewSpotScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  final TextEditingController _reviewController = TextEditingController();
  final PostService _postService = PostService();
  int _selectedRating = 5;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _launchDirections() async {
    final latVal = widget.post['latitude'] ?? 11.5564;
    final lngVal = widget.post['longitude'] ?? 104.9282;
    final lat = latVal is String ? double.tryParse(latVal) ?? 11.5564 : (latVal as num).toDouble();
    final lng = lngVal is String ? double.tryParse(lngVal) ?? 104.9282 : (lngVal as num).toDouble();
    
    final nativeUrl = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
    final webUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    
    try {
      if (!await launchUrl(nativeUrl, mode: LaunchMode.externalApplication)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final latVal = widget.post['latitude'] ?? 11.5564;
    final lngVal = widget.post['longitude'] ?? 104.9282;
    final lat = latVal is String ? double.tryParse(latVal) ?? 11.5564 : (latVal as num).toDouble();
    final lng = lngVal is String ? double.tryParse(lngVal) ?? 104.9282 : (lngVal as num).toDouble();
    final location = LatLng(lat, lng);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F6),
      body: Stack(
        children: [
          // Content
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Image Header
                Hero(
                  tag: widget.heroTag,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                    child: CustomImage(
                      widget.post['imageUrl'] ?? '',
                      width: double.infinity,
                      height: 400,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                // Animated Details
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnim.value,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title & Rating
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.post['title'] ?? 'Unnamed Spot',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2E2C2A),
                                  height: 1.1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.post['rating']?.replaceAll('/5', '') ?? '4.5',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Author badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECE9E4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Posted by ${widget.post['authorName'] ?? 'Anonymous'}',
                            style: const TextStyle(
                              color: Color(0xFF7A7774),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Description
                        const Text(
                          'About this spot',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E2C2A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.post['description'] ?? 'No description provided.',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF5A5855),
                            height: 1.6,
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Location mini-map
                        const Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E2C2A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: SizedBox(
                            height: 200,
                            width: double.infinity,
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: location,
                                initialZoom: 15,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.none, // Static map
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: location,
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
                          ),
                        ),
                        
                        // Reviews Section
                        _buildReviewsSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Back Button overlaid on top
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 24,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF2E2C2A)),
              ),
            ),
          ),
          
          // Floating Action Bar (Get Directions)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 24,
                top: 24,
                left: 24,
                right: 24,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    const Color(0xFFF9F8F6),
                    const Color(0xFFF9F8F6).withOpacity(0.8),
                    const Color(0xFFF9F8F6).withOpacity(0.0),
                  ],
                ),
              ),
              child: ElevatedButton(
                onPressed: _launchDirections,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E2C2A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  elevation: 10,
                  shadowColor: Colors.black.withOpacity(0.3),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions, size: 22),
                    SizedBox(width: 12),
                    Text(
                      'Get Directions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    final postId = widget.post['id'] ?? '';
    final postAuthorId = widget.post['authorId'] ?? '';
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        const Text(
          'Reviews',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E2C2A),
          ),
        ),
        const SizedBox(height: 16),
        
        // Rating selector
        Row(
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRating = index + 1;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  index < _selectedRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 28,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),

        // Review input
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _reviewController,
                decoration: InputDecoration(
                  hintText: 'Write a review...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF2E2C2A),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: () async {
                  final text = _reviewController.text.trim();
                  if (text.isNotEmpty) {
                    await _postService.addReview(postId, text, postAuthorId, _selectedRating);
                    _reviewController.clear();
                    setState(() {
                      _selectedRating = 5;
                    });
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Reviews list
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: _postService.getComments(postId), // we still use the 'comments' collection under the hood
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final reviews = snapshot.data ?? [];
            if (reviews.isEmpty) {
              return const Text('No reviews yet. Be the first!', style: TextStyle(color: Color(0xFF7A7774)));
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final review = reviews[index];
                final reviewId = review['id'];
                final authorName = review['authorName'] ?? 'User';
                final text = review['text'] ?? '';
                final rating = review['rating'] as int? ?? 5; // default to 5 if old comment
                final timestamp = review['createdAt'];
                final timeString = timestamp != null ? timeago.format(timestamp.toDate()) : 'Just now';
                
                final likes = (review['likes'] as List?) ?? [];
                final dislikes = (review['dislikes'] as List?) ?? [];
                
                final isLiked = likes.contains(currentUserId);
                final isDisliked = dislikes.contains(currentUserId);

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            authorName,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E2C2A)),
                          ),
                          Text(
                            timeString,
                            style: const TextStyle(fontSize: 12, color: Color(0xFFAAA69F)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (starIndex) {
                          return Icon(
                            starIndex < rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      Text(text, style: const TextStyle(color: Color(0xFF5A5855))),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _postService.toggleCommentUpvote(postId, reviewId),
                            child: Row(
                              children: [
                                Icon(
                                  isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                                  size: 18,
                                  color: isLiked ? Colors.blueAccent : const Color(0xFF7A7774),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  likes.length.toString(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isLiked ? Colors.blueAccent : const Color(0xFF7A7774),
                                    fontWeight: isLiked ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          GestureDetector(
                            onTap: () => _postService.toggleCommentDownvote(postId, reviewId),
                            child: Row(
                              children: [
                                Icon(
                                  isDisliked ? Icons.thumb_down : Icons.thumb_down_alt_outlined,
                                  size: 18,
                                  color: isDisliked ? Colors.redAccent : const Color(0xFF7A7774),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
