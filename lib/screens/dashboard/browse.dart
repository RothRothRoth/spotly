import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/post_service.dart';
import '../../utils/image_helper.dart';
import 'view.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final PostService _postService = PostService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEBE4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Explore',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E2C2A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_horiz, color: Color(0xFF2E2C2A)),
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
                  ),
                ],
              ),

              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF7A7774)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 28),
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
                      controller: _pageController,
                      itemCount: filteredPosts.length,
                      itemBuilder: (context, index) {
                        final post = filteredPosts[index];
                        return AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, child) {
                            double value = 1.0;
                            if (_pageController.position.haveDimensions) {
                              value = _pageController.page! - index;
                              value = (1 - (value.abs() * 0.15)).clamp(0.0, 1.0);
                            } else if (index != 0) {
                              value = 0.85;
                            }
                            return Center(
                              child: Transform.scale(
                                scale: Curves.easeOut.transform(value),
                                child: child,
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ViewSpotScreen(post: post)),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Hero(
            tag: 'spot_image_$id',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: CustomImage(
                image,
                height: 380, // Taller image for the immersive flipbook look
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        Text(
                          '★ $rating',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                        ),
                        const SizedBox(width: 12),
                        StreamBuilder<List<String>>(
                          stream: _postService.getUserFavorites(),
                          builder: (context, favSnapshot) {
                            final isFav = (favSnapshot.data ?? []).contains(id);
                            return GestureDetector(
                              onTap: () => _postService.toggleFavorite(id),
                              child: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? Colors.redAccent : const Color(0xFF7A7774),
                                size: 24,
                              ),
                            );
                          }
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    subtitle,
                    style: const TextStyle(color: Color(0xFF5A5855)),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF383838),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'Posted by $author',
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    const Icon(Icons.arrow_forward),
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