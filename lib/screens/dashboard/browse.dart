import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/post_service.dart';
import '../../utils/image_helper.dart';
import 'view.dart';
import 'notifications.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final PostService _postService = PostService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 8.0),
              child: Align(
                alignment: Alignment.topRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none, color: Color(0xFF2E2C2A), size: 28),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                      },
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_horiz, color: Color(0xFF2E2C2A), size: 30),
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
            ),
            
            // Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Explore the best Spots',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1A1A1A),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: TextField(
                controller: _searchController,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: const TextStyle(color: Color(0xFFAAA69F), fontSize: 15),
                  filled: true,
                  fillColor: const Color(0xFFEBE7DF),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Cards List
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _postService.getPosts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No posts yet'));
                  }
                  final posts = snapshot.data!;
                  final filteredPosts = posts.where((post) {
                    final title = (post['title'] ?? '').toString().toLowerCase();
                    final description = (post['description'] ?? '').toString().toLowerCase();
                    final query = _searchQuery.toLowerCase();
                    return title.contains(query) || description.contains(query);
                  }).toList();

                  if (filteredPosts.isEmpty) {
                    return const Center(
                      child: Text(
                        'No matching spots found',
                        style: TextStyle(color: Color(0xFF7A7774)),
                      ),
                    );
                  }

                  return PageView.builder(
                    controller: PageController(viewportFraction: 0.92),
                    itemCount: filteredPosts.length,
                    itemBuilder: (context, index) {
                      final post = filteredPosts[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ViewSpotScreen(post: post, heroTag: 'spot_image_${post['id']}_browse')),
                            );
                          },
                          child: buildCard(
                            id: post['id'] ?? '',
                            title: post['title'] ?? '',
                            image: post['imageUrl'] ?? '',
                            subtitle: post['description'] ?? '',
                            rating: post['rating'] ?? '4.5/5',
                            author: post['authorName'] ?? 'Anonymous',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCard({
    required String id,
    required String title,
    required String image,
    required String subtitle,
    required String rating,
    required String author,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE4DFD7), // Muted greyish beige for card
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // Image with dots and heart
          Expanded(
            child: Stack(
              children: [
                Hero(
                  tag: 'spot_image_${id}_browse',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: CustomImage(
                      image,
                      height: double.infinity, 
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              // Heart Icon
              Positioned(
                top: 20,
                left: 20,
                child: StreamBuilder<List<String>>(
                  stream: _postService.getUserFavorites(),
                  builder: (context, favSnapshot) {
                    final isFav = (favSnapshot.data ?? []).contains(id);
                    return GestureDetector(
                      onTap: () => _postService.toggleFavorite(id),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.redAccent : Colors.black87,
                        size: 26,
                      ),
                    );
                  }
                ),
              ),
              // Dots Scroll Indicator inside the image
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ),
          
          // Card Details
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1A1A1A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        Text(
                          'Ratings : ${rating.replaceAll('/5', '')}/5',
                          style: const TextStyle(
                            fontWeight: FontWeight.w400, 
                            fontSize: 12,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.star, color: const Color(0xFFD3A466), size: 14),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF464646),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Posted by $author',
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      color: Color(0xFF464646),
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}