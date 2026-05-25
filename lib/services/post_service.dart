import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'auth_service.dart';

class PostService {
  // Singleton pattern
  static final PostService _instance = PostService._internal();
  factory PostService() => _instance;
  PostService._internal();

  bool get _isFirebaseAvailable {
    if (AuthService.forceMock) return false;
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  bool get _shouldUseMock => AuthService.forceMock || !_isFirebaseAvailable;

  // In-memory mock storage for posts when Firebase is unavailable
  final List<Map<String, dynamic>> _mockPosts = [];

  final StreamController<List<Map<String, dynamic>>> _mockStreamController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  Stream<List<Map<String, dynamic>>> getPosts() {
    if (_shouldUseMock) {
      return _getMockStream();
    } else {
      return FirebaseFirestore.instance
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return data;
              }).toList());
    }
  }

  Stream<List<Map<String, dynamic>>> _getMockStream() async* {
    yield List<Map<String, dynamic>>.from(_mockPosts);
    yield* _mockStreamController.stream;
  }

  Future<String> uploadImage(XFile imageFile) async {
    if (_shouldUseMock) {
      return 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80';
    }
    try {
      // Instead of using Firebase Storage, we encode the image directly to base64
      // This saves it as a string inside the Firestore document
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      
      final ext = imageFile.name.toLowerCase().endsWith('.png') ? 'png' : 'jpeg';
      return 'data:image/$ext;base64,$base64String';
    } catch (e) {
      print('Image Encode Error: $e');
      rethrow;
    }
  }

  Future<void> addPost(Map<String, dynamic> postData) async {
    final Map<String, dynamic> data = Map<String, dynamic>.from(postData);
    if (_shouldUseMock) {
      data['createdAt'] = DateTime.now();
      _mockPosts.insert(0, data);
      _mockStreamController.add(List<Map<String, dynamic>>.from(_mockPosts));
    } else {
      data['createdAt'] = FieldValue.serverTimestamp();
      await FirebaseFirestore.instance.collection('posts').add(data);
    }
  }

  Future<void> updatePost(String postId, Map<String, dynamic> data) async {
    if (_shouldUseMock) return;
    await FirebaseFirestore.instance.collection('posts').doc(postId).update(data);
  }

  Future<void> deletePost(String postId) async {
    if (_shouldUseMock) return;
    await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
  }

  Future<void> toggleFavorite(String postId) async {
    if (_shouldUseMock) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userDoc = await userDocRef.get();
    
    List<dynamic> favorites = [];
    if (userDoc.exists && userDoc.data()!.containsKey('favorites')) {
      favorites = userDoc.data()!['favorites'] as List<dynamic>;
    }

    if (favorites.contains(postId)) {
      favorites.remove(postId);
    } else {
      favorites.add(postId);
    }

    await userDocRef.set({'favorites': favorites}, SetOptions(merge: true));
  }

  Stream<List<String>> getUserFavorites() {
    if (_shouldUseMock) return Stream.value([]);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || !snapshot.data()!.containsKey('favorites')) return [];
      return List<String>.from(snapshot.data()!['favorites']);
    });
  }
}
