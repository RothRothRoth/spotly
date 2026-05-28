import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart';
import '../../services/post_service.dart';
import '../../utils/image_helper.dart';
import 'add.dart';
import 'notifications.dart';
import 'view.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _postService = PostService();
  final _authService = AuthService();
  int _currentTabIndex = 0; // 0: Shared, 1: Favorites

  Future<void> _editProfile(String currentUsername, String? currentPhotoUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final nameController = TextEditingController(text: currentUsername);
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFEFEBE4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text('Edit Profile'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      // Compress the image to ensure it fits within Firestore's 1MB limit for base64 strings
                      final pickedFile = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 30,
                        maxWidth: 600,
                      );
                      if (pickedFile != null) {
                        setState(() { isSaving = true; });
                        try {
                          final url = await _postService.uploadImage(pickedFile);
                          final result = await _authService.updateProfile(photoUrl: url);
                          if (result['success'] == true) {
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Profile picture updated!'), backgroundColor: Colors.green),
                              );
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to update: ${result['message']}'), backgroundColor: Colors.red),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Image is too large!'), backgroundColor: Colors.red),
                            );
                          }
                        } finally {
                          if (mounted) setState(() { isSaving = false; });
                        }
                      }
                    },
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF383838),
                            shape: BoxShape.circle,
                            image: currentPhotoUrl != null ? DecorationImage(
                              image: getCustomImageProvider(currentPhotoUrl),
                              fit: BoxFit.cover,
                            ) : null,
                          ),
                          child: isSaving 
                              ? const Center(child: CircularProgressIndicator())
                              : (currentPhotoUrl == null ? const Icon(Icons.person, color: Colors.white, size: 40) : null),
                        ),
                        if (!isSaving)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, size: 16, color: Colors.black),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF7A7774))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF383838),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isSaving ? null : () async {
                    setState(() { isSaving = true; });
                    final result = await _authService.updateProfile(newUsername: nameController.text);
                    
                    if (result['success'] == true && user != null) {
                      // Update authorName in all posts by this user
                      final query1 = await FirebaseFirestore.instance
                          .collection('posts')
                          .where('authorId', isEqualTo: user.uid)
                          .get();
                          
                      final query2 = await FirebaseFirestore.instance
                          .collection('posts')
                          .where('authorName', isEqualTo: currentUsername)
                          .get();
                      
                      final batch = FirebaseFirestore.instance.batch();
                      final seenDocs = <String>{};
                      
                      for (var doc in [...query1.docs, ...query2.docs]) {
                        if (!seenDocs.contains(doc.id)) {
                          seenDocs.add(doc.id);
                          batch.update(doc.reference, {
                            'authorName': nameController.text,
                            'authorId': user.uid, // Stamp the ID for future proofing
                          });
                        }
                      }
                      await batch.commit();
                    }

                    if (context.mounted) {
                      Navigator.pop(context);
                      if (result['success'] == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile updated!'), backgroundColor: Colors.green),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
                        );
                      }
                    }
                    this.setState(() {}); // Refresh parent
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          }
        );
      }
    );
  }

  Future<void> _deleteSpot(String postId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Spot?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      )
    );

    if (confirm == true) {
      await _postService.deletePost(postId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFEFEBE4),
        body: Center(child: Text('Not logged in')),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, userDocSnap) {
        final userData = userDocSnap.data?.data() as Map<String, dynamic>?;
        final photoUrl = userData?['photoUrl'] as String? ?? user.photoURL;
        final username = userData?['username'] as String? ?? user.displayName ?? user.email?.split('@').first ?? 'Explorer';
        final email = user.email ?? 'No email configured';
        final favoritesList = (userData?['favorites'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

        return Scaffold(
          backgroundColor: const Color(0xFFEFEBE4),
          body: SafeArea(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _postService.getPosts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allPosts = snapshot.data ?? [];
                final userPosts = allPosts.where((post) => (post['authorId'] ?? '') == user.uid || (post['authorName'] == username)).toList();
                final favoritePosts = allPosts.where((post) => favoritesList.contains(post['id'])).toList();
                final postsCount = userPosts.length;
                final favCount = favoritePosts.length;

                final displayList = _currentTabIndex == 0 ? userPosts : favoritePosts;

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App Bar / Top Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'My Profile',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2E2C2A),
                              letterSpacing: -0.5,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications_none, color: Color(0xFF2E2C2A), size: 28),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                                },
                              ),
                              PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_horiz, color: Color(0xFF2E2C2A)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              onSelected: (value) async {
                                if (value == 'logout') {
                                  await _authService.logout();
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
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Profile Header Info card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: const Color(0xFF383838),
                                shape: BoxShape.circle,
                                image: photoUrl != null ? DecorationImage(
                                  image: getCustomImageProvider(photoUrl),
                                  fit: BoxFit.cover,
                                ) : null,
                              ),
                              child: photoUrl == null ? Center(
                                child: Text(
                                  username.isNotEmpty ? username.substring(0, 1).toUpperCase() : 'E',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ) : null,
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          username,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2E2C2A),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 20, color: Color(0xFF7A7774)),
                                        onPressed: () => _editProfile(username, photoUrl),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF7A7774),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // User stats Row
                      Row(
                        children: [
                          _buildStatCard(postsCount.toString(), 'Shared Spots'),
                          const SizedBox(width: 12),
                          _buildStatCard(favCount.toString(), 'Favorites'),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Tabs
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _currentTabIndex = 0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _currentTabIndex == 0 ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: _currentTabIndex == 0 ? [
                                      const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                                    ] : [],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Shared Spots',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _currentTabIndex == 0 ? const Color(0xFF2E2C2A) : const Color(0xFF7A7774),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _currentTabIndex = 1),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _currentTabIndex == 1 ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: _currentTabIndex == 1 ? [
                                      const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                                    ] : [],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Favorites',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _currentTabIndex == 1 ? const Color(0xFF2E2C2A) : const Color(0xFF7A7774),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      if (displayList.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _currentTabIndex == 0 ? Icons.add_location_alt_outlined : Icons.favorite_border,
                                size: 48,
                                color: const Color(0xFFB3A89F),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _currentTabIndex == 0 ? 'No spots shared yet' : 'No favorites yet',
                                style: const TextStyle(
                                  color: Color(0xFF7A7774),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: displayList.length,
                          itemBuilder: (context, index) {
                            final data = displayList[index];
                            final isFavorite = favoritesList.contains(data['id']);
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ViewSpotScreen(
                                      post: data,
                                      heroTag: 'spot_image_${data['id']}_profile',
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Hero(
                                      tag: 'spot_image_${data['id']}_profile',
                                      child: CustomImage(
                                        data['imageUrl'] ?? '',
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                data['title'] ?? 'Untitled Spot',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Color(0xFF2E2C2A),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (_currentTabIndex == 0) ...[
                                              IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                icon: const Icon(Icons.edit, size: 18, color: Color(0xFF7A7774)),
                                                onPressed: () {
                                                  Navigator.push(context, MaterialPageRoute(builder: (_) => AddSpotScreen(existingPost: data)));
                                                },
                                              ),
                                              const SizedBox(width: 8),
                                              IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                                onPressed: () => _deleteSpot(data['id']),
                                              ),
                                            ] else ...[
                                              IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                icon: Icon(
                                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                                  color: isFavorite ? Colors.redAccent : const Color(0xFF7A7774),
                                                  size: 20,
                                                ),
                                                onPressed: () => _postService.toggleFavorite(data['id']),
                                              )
                                            ]
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          data['description'] ?? 'No description provided.',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFF7A7774),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
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
      },
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E2C2A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF7A7774),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}