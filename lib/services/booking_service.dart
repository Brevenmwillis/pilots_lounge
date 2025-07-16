import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pilots_lounge/services/notification_service.dart';
import 'package:pilots_lounge/services/payment_service.dart';

// Booking status enum
enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  rejected,
}

// Booking type enum
enum BookingType {
  rental,
  charter,
  instruction,
  maintenance,
}

class BookingService {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  final PaymentService _paymentService = PaymentService();

  // Create a new booking
  Future<BookingResult> createBooking({
    required String aircraftId,
    required DateTime startTime,
    required DateTime endTime,
    required BookingType type,
    required double totalAmount,
    String? notes,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return BookingResult(
          success: false,
          error: 'User not authenticated',
          bookingId: null,
        );
      }

      // Check if aircraft is available
      final isAvailable = await _checkAircraftAvailability(
        aircraftId,
        startTime,
        endTime,
      );

      if (!isAvailable) {
        return BookingResult(
          success: false,
          error: 'Aircraft is not available for the selected time period',
          bookingId: null,
        );
      }

      // Create booking document
      final bookingData = {
        'userId': user.uid,
        'aircraftId': aircraftId,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        'type': type.name,
        'totalAmount': totalAmount,
        'status': BookingStatus.pending.name,
        'notes': notes ?? '',
        'additionalData': additionalData ?? {},
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final bookingRef = await _firestore.collection('bookings').add(bookingData);
      final bookingId = bookingRef.id;

      // Get aircraft details for notification
      final aircraftDoc = await _firestore.collection('aircraft').doc(aircraftId).get();
      final aircraftData = aircraftDoc.data();
      final aircraftName = '${aircraftData?['make']} ${aircraftData?['model']}';
      final ownerId = aircraftData?['ownerId'];

      // Send notification to owner
      if (ownerId != null && ownerId != user.uid) {
        await _notificationService.sendNotification(
          userId: ownerId,
          title: 'New Booking Request',
          message: 'New ${type.name} booking request for $aircraftName',
          type: NotificationType.messageReceived,
          priority: NotificationPriority.normal,
          data: {
            'bookingId': bookingId,
            'aircraftId': aircraftId,
            'aircraftName': aircraftName,
            'startTime': startTime.toIso8601String(),
            'endTime': endTime.toIso8601String(),
            'totalAmount': totalAmount,
          },
        );
      }

      return BookingResult(
        success: true,
        bookingId: bookingId,
        totalAmount: totalAmount,
      );
    } catch (e) {
      return BookingResult(
        success: false,
        error: e.toString(),
        bookingId: null,
      );
    }
  }

  // Confirm a booking
  Future<bool> confirmBooking(String bookingId) async {
    try {
      final bookingDoc = await _firestore.collection('bookings').doc(bookingId).get();
      final bookingData = bookingDoc.data();
      
      if (bookingData == null) return false;

      await _firestore.collection('bookings').doc(bookingId).update({
        'status': BookingStatus.confirmed.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Send confirmation notification to user
      await _notificationService.sendBookingConfirmation(
        userId: bookingData['userId'],
        aircraftId: bookingData['aircraftId'],
        aircraftName: 'Aircraft', // You'd get this from aircraft data
        bookingDate: (bookingData['startTime'] as Timestamp).toDate(),
        amount: bookingData['totalAmount'],
      );

      return true;
    } catch (e) {
      print('Error confirming booking: $e');
      return false;
    }
  }

  // Cancel a booking
  Future<bool> cancelBooking(String bookingId, {String? reason}) async {
    try {
      final bookingDoc = await _firestore.collection('bookings').doc(bookingId).get();
      final bookingData = bookingDoc.data();
      
      if (bookingData == null) return false;

      await _firestore.collection('bookings').doc(bookingId).update({
        'status': BookingStatus.cancelled.name,
        'cancellationReason': reason ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Send cancellation notification
      await _notificationService.sendNotification(
        userId: bookingData['userId'],
        title: 'Booking Cancelled',
        message: 'Your booking has been cancelled${reason != null ? ': $reason' : ''}',
        type: NotificationType.messageReceived,
        priority: NotificationPriority.normal,
      );

      return true;
    } catch (e) {
      print('Error cancelling booking: $e');
      return false;
    }
  }

  // Get user bookings
  Future<List<Booking>> getUserBookings({
    String? userId,
    BookingStatus? status,
    int limit = 50,
  }) async {
    try {
      final currentUserId = userId ?? FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return [];

      Query query = _firestore
          .collection('bookings')
          .where('userId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting user bookings: $e');
      return [];
    }
  }

  // Get aircraft bookings (for owners)
  Future<List<Booking>> getAircraftBookings(String aircraftId) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('aircraftId', isEqualTo: aircraftId)
          .orderBy('startTime', descending: true)
          .get();

      return snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting aircraft bookings: $e');
      return [];
    }
  }

  // Check aircraft availability
  Future<bool> _checkAircraftAvailability(
    String aircraftId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('aircraftId', isEqualTo: aircraftId)
          .where('status', whereIn: [
            BookingStatus.pending.name,
            BookingStatus.confirmed.name,
            BookingStatus.inProgress.name,
          ])
          .get();

      for (final doc in snapshot.docs) {
        final bookingData = doc.data();
        final bookingStart = (bookingData['startTime'] as Timestamp).toDate();
        final bookingEnd = (bookingData['endTime'] as Timestamp).toDate();

        // Check for overlap
        if (startTime.isBefore(bookingEnd) && endTime.isAfter(bookingStart)) {
          return false; // Conflict found
        }
      }

      return true; // No conflicts
    } catch (e) {
      print('Error checking aircraft availability: $e');
      return false;
    }
  }

  // Process payment for booking
  Future<PaymentResult> processBookingPayment({
    required String bookingId,
    required PaymentMethod paymentMethod,
  }) async {
    try {
      final bookingDoc = await _firestore.collection('bookings').doc(bookingId).get();
      final bookingData = bookingDoc.data();
      
      if (bookingData == null) {
        return PaymentResult(
          success: false,
          error: 'Booking not found',
          paymentId: null,
        );
      }

      final paymentResult = await _paymentService.createRentalPayment(
        amount: bookingData['totalAmount'],
        currency: 'USD',
        aircraftId: bookingData['aircraftId'],
        description: 'Booking ${bookingData['type']} - ${bookingId}',
        paymentMethod: paymentMethod,
      );

      if (paymentResult.success) {
        // Update booking with payment info
        await _firestore.collection('bookings').doc(bookingId).update({
          'paymentId': paymentResult.paymentId,
          'paymentStatus': 'completed',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Send payment confirmation
        await _notificationService.sendPaymentConfirmation(
          userId: bookingData['userId'],
          paymentId: paymentResult.paymentId!,
          amount: bookingData['totalAmount'],
          description: 'Booking ${bookingData['type']}',
        );
      }

      return paymentResult;
    } catch (e) {
      return PaymentResult(
        success: false,
        error: e.toString(),
        paymentId: null,
      );
    }
  }
}

// Booking result class
class BookingResult {
  final bool success;
  final String? bookingId;
  final String? error;
  final double? totalAmount;

  BookingResult({
    required this.success,
    this.bookingId,
    this.error,
    this.totalAmount,
  });
}

// Booking model
class Booking {
  final String id;
  final String userId;
  final String aircraftId;
  final DateTime startTime;
  final DateTime endTime;
  final BookingType type;
  final double totalAmount;
  final BookingStatus status;
  final String notes;
  final Map<String, dynamic> additionalData;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? paymentId;
  final String? paymentStatus;
  final String? cancellationReason;

  Booking({
    required this.id,
    required this.userId,
    required this.aircraftId,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.totalAmount,
    required this.status,
    required this.notes,
    required this.additionalData,
    required this.createdAt,
    required this.updatedAt,
    this.paymentId,
    this.paymentStatus,
    this.cancellationReason,
  });

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      userId: data['userId'] ?? '',
      aircraftId: data['aircraftId'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      type: BookingType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => BookingType.rental,
      ),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => BookingStatus.pending,
      ),
      notes: data['notes'] ?? '',
      additionalData: Map<String, dynamic>.from(data['additionalData'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      paymentId: data['paymentId'],
      paymentStatus: data['paymentStatus'],
      cancellationReason: data['cancellationReason'],
    );
  }
} 