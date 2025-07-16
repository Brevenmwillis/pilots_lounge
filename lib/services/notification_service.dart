import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Notification types
enum NotificationType {
  bookingConfirmation,
  bookingReminder,
  paymentReceived,
  paymentFailed,
  reviewReceived,
  messageReceived,
  aircraftAvailable,
  priceChange,
  maintenanceUpdate,
  weatherAlert,
}

// Notification priority
enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send notification to user
  Future<bool> sendNotification({
    required String userId,
    required String title,
    required String message,
    required NotificationType type,
    NotificationPriority priority = NotificationPriority.normal,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notification = {
        'userId': userId,
        'title': title,
        'message': message,
        'type': type.name,
        'priority': priority.name,
        'data': data ?? {},
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      };

      await _firestore.collection('notifications').add(notification);
      
      // In a real app, you'd also send push notifications via FCM
      await _sendPushNotification(userId, title, message, data);
      
      return true;
    } catch (e) {
      print('Error sending notification: $e');
      return false;
    }
  }

  // Send booking confirmation
  Future<bool> sendBookingConfirmation({
    required String userId,
    required String aircraftId,
    required String aircraftName,
    required DateTime bookingDate,
    required double amount,
  }) async {
    return sendNotification(
      userId: userId,
      title: 'Booking Confirmed!',
      message: 'Your booking for $aircraftName on ${bookingDate.toString().split(' ')[0]} has been confirmed.',
      type: NotificationType.bookingConfirmation,
      priority: NotificationPriority.high,
      data: {
        'aircraftId': aircraftId,
        'bookingDate': bookingDate.toIso8601String(),
        'amount': amount,
      },
    );
  }

  // Send payment confirmation
  Future<bool> sendPaymentConfirmation({
    required String userId,
    required String paymentId,
    required double amount,
    required String description,
  }) async {
    return sendNotification(
      userId: userId,
      title: 'Payment Successful',
      message: 'Payment of \$${amount.toStringAsFixed(2)} for $description has been processed successfully.',
      type: NotificationType.paymentReceived,
      priority: NotificationPriority.high,
      data: {
        'paymentId': paymentId,
        'amount': amount,
        'description': description,
      },
    );
  }

  // Send review notification to owner
  Future<bool> sendReviewNotification({
    required String ownerId,
    required String reviewerName,
    required String aircraftName,
    required double rating,
  }) async {
    return sendNotification(
      userId: ownerId,
      title: 'New Review Received',
      message: '$reviewerName left a ${rating.toStringAsFixed(1)}-star review for $aircraftName.',
      type: NotificationType.reviewReceived,
      priority: NotificationPriority.normal,
      data: {
        'reviewerName': reviewerName,
        'aircraftName': aircraftName,
        'rating': rating,
      },
    );
  }

  // Send booking reminder
  Future<bool> sendBookingReminder({
    required String userId,
    required String aircraftName,
    required DateTime bookingDate,
  }) async {
    return sendNotification(
      userId: userId,
      title: 'Upcoming Booking Reminder',
      message: 'Your booking for $aircraftName is tomorrow. Don\'t forget to check weather and NOTAMs!',
      type: NotificationType.bookingReminder,
      priority: NotificationPriority.normal,
      data: {
        'aircraftName': aircraftName,
        'bookingDate': bookingDate.toIso8601String(),
      },
    );
  }

  // Get user notifications
  Future<List<AppNotification>> getUserNotifications({
    String? userId,
    bool unreadOnly = false,
    int limit = 50,
  }) async {
    try {
      final currentUserId = userId ?? FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return [];

      Query query = _firestore
          .collection('notifications')
          .where('userId', isEqualTo: currentUserId)
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (unreadOnly) {
        query = query.where('read', isEqualTo: false);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => AppNotification.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  // Mark notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'read': true});
      return true;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  // Mark all notifications as read
  Future<bool> markAllNotificationsAsRead({String? userId}) async {
    try {
      final currentUserId = userId ?? FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return false;

      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: currentUserId)
          .where('read', isEqualTo: false)
          .get();

      for (final doc in notifications.docs) {
        batch.update(doc.reference, {'read': true});
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return false;
    }
  }

  // Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
      return true;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  // Simulate push notification (in real app, use FCM)
  Future<void> _sendPushNotification(
    String userId,
    String title,
    String message,
    Map<String, dynamic>? data,
  ) async {
    // In a real app, you'd use Firebase Cloud Messaging (FCM)
    // For now, we'll just log it
    print('Push notification sent to $userId: $title - $message');
  }
}

// App notification model
class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationPriority priority;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final bool read;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.data,
    required this.timestamp,
    required this.read,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => NotificationType.messageReceived,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.name == data['priority'],
        orElse: () => NotificationPriority.normal,
      ),
      data: Map<String, dynamic>.from(data['data'] ?? {}),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      read: data['read'] ?? false,
    );
  }
} 