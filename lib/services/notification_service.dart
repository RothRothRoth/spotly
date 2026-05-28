import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool get _shouldUseMock => AuthService.forceMock;

  /// Send a notification to a specific user
  Future<void> sendNotification({
    required String toUserId,
    required String title,
    required String message,
    String? postId,
  }) async {
    if (_shouldUseMock) return; // In mock mode, we don't send real notifications
    
    final currentUser = FirebaseAuth.instance.currentUser;
    // Don't send notification to yourself
    if (currentUser != null && currentUser.uid == toUserId) return;

    final data = {
      'title': title,
      'message': message,
      'postId': postId,
      'senderId': currentUser?.uid ?? 'system',
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(toUserId)
        .collection('notifications')
        .add(data);
  }

  /// Get stream of notifications for current user
  Stream<List<Map<String, dynamic>>> getNotifications() {
    if (_shouldUseMock) return Stream.value([]);
    
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return Stream.value([]);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    if (_shouldUseMock) return;
    
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }
}
