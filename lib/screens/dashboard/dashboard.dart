import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'map.dart';
import '../../services/post_service.dart';
import '../../services/auth_service.dart';
import 'browse.dart';
import 'profile.dart';
import 'add.dart';
import '../../utils/image_helper.dart';
import 'view.dart';

// Tab 0: Dashboard/Welcome feed view (Aesthetic Redesign)
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final username = user?.displayName ?? user?.email?.split('@').first ?? 'Explorer';
    final postService = PostService();

    return Scaffold(
      backgroundColor: const Color(0xFFEFEBE4),
      body: SafeArea(
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: postService.getPosts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            final posts = snapshot.data ?? [];

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar / Greeting Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Hello, $username',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2E2C2A),
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),
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

                  const SizedBox(height: 24),

                  // Welcome Premium Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF383838), Color(0xFF222222)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back! ✨',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Discover & share the\nbest spots around you.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Explore Spots Section (Horizontal Cards)
                  const Text(
                    'Explore the best Spots',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E2C2A),
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (posts.isEmpty)
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(
                        child: Text(
                          'No shared spots yet.',
                          style: TextStyle(color: Color(0xFF7A7774)),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final data = posts[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => ViewSpotScreen(post: data)));
                            },
                            child: Container(
                              width: 280,
                              margin: const EdgeInsets.only(right: 18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 6)),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Hero(
                                      tag: 'spot_image_${data['id']}',
                                      child: CustomImage(
                                        data['imageUrl'] ?? '',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.0),
                                          Colors.black.withOpacity(0.65),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.all(18),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data['title'] ?? 'Spot',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(Icons.star, color: Colors.amber, size: 14),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    data['rating'] ?? '4.5/5',
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              StreamBuilder<List<String>>(
                                                stream: PostService().getUserFavorites(),
                                                builder: (context, favSnapshot) {
                                                  final isFav = (favSnapshot.data ?? []).contains(data['id']);
                                                  return GestureDetector(
                                                    onTap: () => PostService().toggleFavorite(data['id']),
                                                    child: Icon(
                                                      isFav ? Icons.favorite : Icons.favorite_border,
                                                      color: isFav ? Colors.redAccent : Colors.white70,
                                                      size: 20,
                                                    ),
                                                  );
                                                }
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Recent Spots Section (Vertical beautiful list)
                  const Text(
                    'Recently Checked Spots',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E2C2A),
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (posts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'No recent spots.',
                          style: TextStyle(color: Color(0xFF7A7774)),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: posts.length > 5 ? 5 : posts.length,
                      itemBuilder: (context, index) {
                        final data = posts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ViewSpotScreen(post: data)));
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: Row(
                              children: [
                                Hero(
                                  tag: 'spot_image_${data['id']}',
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: CustomImage(
                                      data['imageUrl'] ?? '',
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['title'] ?? 'Untitled Spot',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2E2C2A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Posted by ${data['authorName'] ?? 'Anonymous'}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF7A7774),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  StreamBuilder<List<String>>(
                                    stream: PostService().getUserFavorites(),
                                    builder: (context, favSnapshot) {
                                      final isFav = (favSnapshot.data ?? []).contains(data['id']);
                                      return GestureDetector(
                                        onTap: () => PostService().toggleFavorite(data['id']),
                                        child: Icon(
                                          isFav ? Icons.favorite : Icons.favorite_border,
                                          color: isFav ? Colors.redAccent : const Color(0xFF7A7774),
                                          size: 20,
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 14),
                                      const SizedBox(width: 2),
                                      Text(
                                        data['rating']?.replaceAll('/5', '') ?? '4.5',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2E2C2A),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// Main Dashboard containing Bottom Navigation Bar connecting all tabs
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0; // Starts on the Feed/Welcome screen

  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      const DashboardTab(),
      const MapScreen(),
      const BrowseScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEBE4),
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),

      // Floating Action Button is shown on all screens
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 68), // Lowered slightly
        child: FloatingActionButton(
          backgroundColor: const Color(0xFFB9B0A2), // Light brown/beige matching the mockup
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.add,
            color: Colors.black87,
            size: 32,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddSpotScreen()),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // Highly custom premium Navigation Bar connecting all screens
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 22),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFECE9E4), // Custom grey/beige bottom bar background
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(4, (index) {
            final isSelected = _currentIndex == index;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFDCD8D1) : Colors.transparent, // Active pill highlight
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _getIconForIndex(index, isSelected),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _getIconForIndex(int index, bool isSelected) {
    final color = isSelected ? Colors.black : const Color(0xFF5A5855);
    switch (index) {
      case 0:
        return Image.asset('assets/dashboard.png', width: 26, height: 26, color: color); // Dashboard
      case 1:
        return Image.asset('assets/map.png', width: 26, height: 26, color: color); // Map
      case 2:
        return Image.asset('assets/browse.png', width: 26, height: 26, color: color); // Browse
      case 3:
        return Icon(Icons.account_circle_outlined, size: 26, color: color); // Profile
      default:
        return Icon(Icons.help_outline, size: 26, color: color);
    }
  }
}
