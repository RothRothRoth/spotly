import 'package:flutter/material.dart';
import '../../services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEBE4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEFEBE4),
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(color: Color(0xFF2E2C2A), fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2E2C2A)),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: NotificationService().getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading notifications'));
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return const Center(
              child: Text(
                'No new notifications',
                style: TextStyle(color: Color(0xFF7A7774), fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final note = notifications[index];
              final isRead = note['isRead'] ?? false;
              final timestamp = note['createdAt'] as Timestamp?;
              final timeString = timestamp != null 
                  ? timeago.format(timestamp.toDate()) 
                  : 'Just now';

              return InkWell(
                onTap: () {
                  if (!isRead) {
                    NotificationService().markAsRead(note['id']);
                  }
                  // Optionally navigate to the post if postId is present
                  // but we would need to fetch the post data first.
                },
                child: Container(
                  color: isRead ? Colors.transparent : Colors.white.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isRead ? const Color(0xFFE0DBD3) : Colors.blueAccent.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_active,
                          color: isRead ? const Color(0xFF7A7774) : Colors.blueAccent,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note['title'] ?? 'Notification',
                              style: TextStyle(
                                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                fontSize: 16,
                                color: const Color(0xFF2E2C2A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              note['message'] ?? '',
                              style: TextStyle(
                                color: isRead ? const Color(0xFF7A7774) : const Color(0xFF5A5855),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              timeString,
                              style: const TextStyle(
                                color: Color(0xFFAAA69F),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isRead)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
