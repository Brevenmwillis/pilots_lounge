import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pilots_lounge/models/review.dart';
import 'package:pilots_lounge/services/notification_service.dart';

class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  // Submit a review for an aircraft
  Future<bool> submitAircraftReview({
    required String aircraftId,
    required double rating,
    required String comment,
    String? ownerResponse,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      // Get user profile for name
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userName = userDoc.data()?['displayName'] ?? user.email ?? 'Anonymous';

      final review = Review(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.uid,
        userName: userName,
        rating: rating,
        comment: comment,
        date: DateTime.now(),
        ownerResponse: ownerResponse,
      );

      // Add review to aircraft
      await _firestore
          .collection('aircraft')
          .doc(aircraftId)
          .update({
        'reviews': FieldValue.arrayUnion([review.toFirestore()]),
      });

      // Update aircraft rating
      await _updateAircraftRating(aircraftId);

      // Get aircraft details for notification
      final aircraftDoc = await _firestore.collection('aircraft').doc(aircraftId).get();
      final aircraftData = aircraftDoc.data();
      final aircraftName = '${aircraftData?['make']} ${aircraftData?['model']}';
      final ownerId = aircraftData?['ownerId'];

      // Send notification to owner
      if (ownerId != null && ownerId != user.uid) {
        await _notificationService.sendReviewNotification(
          ownerId: ownerId,
          reviewerName: userName,
          aircraftName: aircraftName,
          rating: rating,
        );
      }

      return true;
    } catch (e) {
      print('Error submitting aircraft review: $e');
      return false;
    }
  }

  // Submit a review for an instructor
  Future<bool> submitInstructorReview({
    required String instructorId,
    required double rating,
    required String comment,
    String? ownerResponse,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userName = userDoc.data()?['displayName'] ?? user.email ?? 'Anonymous';

      final review = Review(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.uid,
        userName: userName,
        rating: rating,
        comment: comment,
        date: DateTime.now(),
        ownerResponse: ownerResponse,
      );

      await _firestore
          .collection('instructors')
          .doc(instructorId)
          .update({
        'reviews': FieldValue.arrayUnion([review.toFirestore()]),
      });

      await _updateInstructorRating(instructorId);

      // Send notification to instructor
      final instructorDoc = await _firestore.collection('instructors').doc(instructorId).get();
      final instructorData = instructorDoc.data();
      final instructorName = instructorData?['name'] ?? 'Instructor';

      await _notificationService.sendReviewNotification(
        ownerId: instructorId,
        reviewerName: userName,
        aircraftName: instructorName,
        rating: rating,
      );

      return true;
    } catch (e) {
      print('Error submitting instructor review: $e');
      return false;
    }
  }

  // Submit a review for a mechanic
  Future<bool> submitMechanicReview({
    required String mechanicId,
    required double rating,
    required String comment,
    String? ownerResponse,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userName = userDoc.data()?['displayName'] ?? user.email ?? 'Anonymous';

      final review = Review(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.uid,
        userName: userName,
        rating: rating,
        comment: comment,
        date: DateTime.now(),
        ownerResponse: ownerResponse,
      );

      await _firestore
          .collection('mechanics')
          .doc(mechanicId)
          .update({
        'reviews': FieldValue.arrayUnion([review.toFirestore()]),
      });

      await _updateMechanicRating(mechanicId);

      return true;
    } catch (e) {
      print('Error submitting mechanic review: $e');
      return false;
    }
  }

  // Submit a review for a flight school
  Future<bool> submitFlightSchoolReview({
    required String schoolId,
    required double rating,
    required String comment,
    String? ownerResponse,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userName = userDoc.data()?['displayName'] ?? user.email ?? 'Anonymous';

      final review = Review(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.uid,
        userName: userName,
        rating: rating,
        comment: comment,
        date: DateTime.now(),
        ownerResponse: ownerResponse,
      );

      await _firestore
          .collection('flight_schools')
          .doc(schoolId)
          .update({
        'reviews': FieldValue.arrayUnion([review.toFirestore()]),
      });

      await _updateFlightSchoolRating(schoolId);

      return true;
    } catch (e) {
      print('Error submitting flight school review: $e');
      return false;
    }
  }

  // Get reviews for an aircraft
  Future<List<Review>> getAircraftReviews(String aircraftId) async {
    try {
      final doc = await _firestore.collection('aircraft').doc(aircraftId).get();
      final data = doc.data();
      final reviews = data?['reviews'] as List<dynamic>? ?? [];
      
      return reviews.map((review) => Review.fromFirestore(review)).toList();
    } catch (e) {
      print('Error getting aircraft reviews: $e');
      return [];
    }
  }

  // Get reviews for an instructor
  Future<List<Review>> getInstructorReviews(String instructorId) async {
    try {
      final doc = await _firestore.collection('instructors').doc(instructorId).get();
      final data = doc.data();
      final reviews = data?['reviews'] as List<dynamic>? ?? [];
      
      return reviews.map((review) => Review.fromFirestore(review)).toList();
    } catch (e) {
      print('Error getting instructor reviews: $e');
      return [];
    }
  }

  // Add owner response to a review
  Future<bool> addOwnerResponse({
    required String itemId,
    required String reviewId,
    required String response,
    required String collection,
  }) async {
    try {
      final doc = await _firestore.collection(collection).doc(itemId).get();
      final data = doc.data();
      final reviews = data?['reviews'] as List<dynamic>? ?? [];

      // Find and update the specific review
      for (int i = 0; i < reviews.length; i++) {
        if (reviews[i]['id'] == reviewId) {
          reviews[i]['ownerResponse'] = response;
          break;
        }
      }

      await _firestore.collection(collection).doc(itemId).update({
        'reviews': reviews,
      });

      return true;
    } catch (e) {
      print('Error adding owner response: $e');
      return false;
    }
  }

  // Update aircraft rating
  Future<void> _updateAircraftRating(String aircraftId) async {
    try {
      final reviews = await getAircraftReviews(aircraftId);
      if (reviews.isEmpty) return;

      final averageRating = reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
      
      await _firestore.collection('aircraft').doc(aircraftId).update({
        'rating': averageRating,
      });
    } catch (e) {
      print('Error updating aircraft rating: $e');
    }
  }

  // Update instructor rating
  Future<void> _updateInstructorRating(String instructorId) async {
    try {
      final reviews = await getInstructorReviews(instructorId);
      if (reviews.isEmpty) return;

      final averageRating = reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
      
      await _firestore.collection('instructors').doc(instructorId).update({
        'rating': averageRating,
      });
    } catch (e) {
      print('Error updating instructor rating: $e');
    }
  }

  // Update mechanic rating
  Future<void> _updateMechanicRating(String mechanicId) async {
    try {
      final doc = await _firestore.collection('mechanics').doc(mechanicId).get();
      final data = doc.data();
      final reviews = data?['reviews'] as List<dynamic>? ?? [];
      
      if (reviews.isEmpty) return;

      final reviewObjects = reviews.map((review) => Review.fromFirestore(review)).toList();
      final averageRating = reviewObjects.map((r) => r.rating).reduce((a, b) => a + b) / reviewObjects.length;
      
      await _firestore.collection('mechanics').doc(mechanicId).update({
        'rating': averageRating,
      });
    } catch (e) {
      print('Error updating mechanic rating: $e');
    }
  }

  // Update flight school rating
  Future<void> _updateFlightSchoolRating(String schoolId) async {
    try {
      final doc = await _firestore.collection('flight_schools').doc(schoolId).get();
      final data = doc.data();
      final reviews = data?['reviews'] as List<dynamic>? ?? [];
      
      if (reviews.isEmpty) return;

      final reviewObjects = reviews.map((review) => Review.fromFirestore(review)).toList();
      final averageRating = reviewObjects.map((r) => r.rating).reduce((a, b) => a + b) / reviewObjects.length;
      
      await _firestore.collection('flight_schools').doc(schoolId).update({
        'rating': averageRating,
      });
    } catch (e) {
      print('Error updating flight school rating: $e');
    }
  }
} 