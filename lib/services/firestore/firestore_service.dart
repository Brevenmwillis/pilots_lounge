import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pilots_lounge/models/user_profile.dart';
import 'package:pilots_lounge/models/aircraft.dart';
import 'package:pilots_lounge/models/instructor.dart';
import 'package:pilots_lounge/models/review.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // User Profile Operations
  Future<void> createUserProfile(UserProfile profile) async {
    try {
      await _firestore.collection('users').doc(profile.id).set(profile.toFirestore());
    } catch (e) {
      // ignore: avoid_print
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Error getting user profile: $e');
      return null;
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _firestore.collection('users').doc(profile.id).update(profile.toFirestore());
    } catch (e) {
      // ignore: avoid_print
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Aircraft Listing Operations
  Future<String> createAircraftListing(Aircraft aircraft) async {
    try {
      final docRef = await _firestore.collection('aircraft_listings').add({
        'ownerId': aircraft.ownerId,
        'registration': aircraft.registration,
        'make': aircraft.make,
        'model': aircraft.model,
        'year': aircraft.year,
        'price': aircraft.price,
        'location': aircraft.location,
        'lat': aircraft.lat,
        'lng': aircraft.lng,
        'avionics': aircraft.avionics,
        'specs': aircraft.specs,
        'rating': aircraft.rating,
        'reviews': aircraft.reviews,
        'bookingWebsite': aircraft.bookingWebsite,
        'paymentMethods': aircraft.paymentMethods,
        'insuranceRequirements': aircraft.insuranceRequirements,
        'insuranceDeductible': aircraft.insuranceDeductible,
        'internationalFlights': aircraft.internationalFlights,
        'lastUpdated': aircraft.lastUpdated,
        'isActive': aircraft.isActive,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending', // pending, approved, rejected, sold
      });
      return docRef.id;
    } catch (e) {
      // ignore: avoid_print
      print('Error creating aircraft listing: $e');
      rethrow;
    }
  }

  Future<List<Aircraft>> getAircraftListings({String? ownerId, bool? isActive}) async {
    try {
      Query query = _firestore.collection('aircraft_listings');
      
      if (ownerId != null) {
        query = query.where('ownerId', isEqualTo: ownerId);
      }
      
      if (isActive != null) {
        query = query.where('isActive', isEqualTo: isActive);
      }
      
      query = query.where('status', isEqualTo: 'approved');
      
      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Aircraft(
          id: doc.id,
          registration: data['registration'] ?? '',
          make: data['make'] ?? '',
          model: data['model'] ?? '',
          year: data['year'] ?? 0,
          price: data['price'] ?? 0.0,
          location: data['location'] ?? '',
          lat: data['lat'] ?? 0.0,
          lng: data['lng'] ?? 0.0,
          avionics: List<String>.from(data['avionics'] ?? []),
          specs: Map<String, String>.from(data['specs'] ?? {}),
          rating: data['rating'] ?? 0.0,
          reviews: (data['reviews'] as List?)?.map((r) => Review(
            id: r['id'] ?? '',
            userId: r['userId'] ?? '',
            userName: r['userName'] ?? '',
            rating: (r['rating'] ?? 0.0).toDouble(),
            comment: r['comment'] ?? '',
            date: r['date'] != null ? r['date'].toDate() : DateTime.now(),
            ownerResponse: r['ownerResponse'],
          )).toList() ?? [],
          ownerId: data['ownerId'] ?? '',
          bookingWebsite: data['bookingWebsite'] ?? '',
          paymentMethods: List<String>.from(data['paymentMethods'] ?? []),
          insuranceRequirements: data['insuranceRequirements'] ?? '',
          insuranceDeductible: data['insuranceDeductible'] ?? 0,
          internationalFlights: data['internationalFlights'] ?? false,
          lastUpdated: data['lastUpdated']?.toDate() ?? DateTime.now(),
          isActive: data['isActive'] ?? true,
        );
      }).toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error getting aircraft listings: $e');
      return [];
    }
  }

  Future<void> updateAircraftListing(String listingId, Map<String, dynamic> updates) async {
    try {
      updates['lastUpdated'] = FieldValue.serverTimestamp();
      await _firestore.collection('aircraft_listings').doc(listingId).update(updates);
    } catch (e) {
      // ignore: avoid_print
      print('Error updating aircraft listing: $e');
      rethrow;
    }
  }

  Future<void> deleteAircraftListing(String listingId) async {
    try {
      await _firestore.collection('aircraft_listings').doc(listingId).delete();
    } catch (e) {
      // ignore: avoid_print
      print('Error deleting aircraft listing: $e');
      rethrow;
    }
  }

  // Get current user's profile
  Future<UserProfile?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await getUserProfile(user.uid);
    }
    return null;
  }

  // Get current user's listings (all statuses)
  Future<List<Aircraft>> getCurrentUserListings() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        Query query = _firestore.collection('aircraft_listings').where('ownerId', isEqualTo: user.uid);
        final querySnapshot = await query.get();
        return querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Aircraft(
            id: doc.id,
            registration: data['registration'] ?? '',
            make: data['make'] ?? '',
            model: data['model'] ?? '',
            year: data['year'] ?? 0,
            price: data['price'] ?? 0.0,
            location: data['location'] ?? '',
            lat: data['lat'] ?? 0.0,
            lng: data['lng'] ?? 0.0,
            avionics: List<String>.from(data['avionics'] ?? []),
            specs: Map<String, String>.from(data['specs'] ?? {}),
            rating: data['rating'] ?? 0.0,
            reviews: (data['reviews'] as List?)?.map((r) => Review(
              id: r['id'] ?? '',
              userId: r['userId'] ?? '',
              userName: r['userName'] ?? '',
              rating: (r['rating'] ?? 0.0).toDouble(),
              comment: r['comment'] ?? '',
              date: r['date'] != null ? r['date'].toDate() : DateTime.now(),
              ownerResponse: r['ownerResponse'],
            )).toList() ?? [],
            ownerId: data['ownerId'] ?? '',
            bookingWebsite: data['bookingWebsite'] ?? '',
            paymentMethods: List<String>.from(data['paymentMethods'] ?? []),
            insuranceRequirements: data['insuranceRequirements'] ?? '',
            insuranceDeductible: data['insuranceDeductible'] ?? 0,
            internationalFlights: data['internationalFlights'] ?? false,
            lastUpdated: data['lastUpdated']?.toDate() ?? DateTime.now(),
            isActive: data['isActive'] ?? true,
          );
        }).toList();
      } catch (e) {
        // ignore: avoid_print
        print('Error getting current user listings: $e');
        return [];
      }
    }
    return [];
  }

  // Check if user profile exists, create if not
  Future<UserProfile> ensureUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user');
    }

    UserProfile? profile = await getUserProfile(user.uid);
    if (profile == null) {
      // Create new profile from Firebase Auth user
      profile = UserProfile(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
        photoURL: user.photoURL,
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );
      await createUserProfile(profile);
    }
    return profile;
  }

  // Instructor Operations
  Future<String> createInstructor(Instructor instructor) async {
    try {
      final docRef = await _firestore.collection('instructors').add({
        'name': instructor.name,
        'type': instructor.type,
        'location': instructor.location,
        'lat': instructor.lat,
        'lng': instructor.lng,
        'preferredLocations': instructor.preferredLocations,
        'endorsements': instructor.endorsements,
        'rating': instructor.rating,
        'reviews': instructor.reviews.map((r) => r.toFirestore()).toList(),
        'contactInfo': instructor.contactInfo,
        'contactThroughApp': instructor.contactThroughApp,
        'lastUpdated': FieldValue.serverTimestamp(),
        'isActive': instructor.isActive,
        'createdAt': FieldValue.serverTimestamp(),
        'ownerId': _auth.currentUser?.uid,
      });
      return docRef.id;
    } catch (e) {
      // ignore: avoid_print
      print('Error creating instructor: $e');
      rethrow;
    }
  }

  Future<List<Instructor>> getInstructors({String? type}) async {
    try {
      Query query = _firestore.collection('instructors').where('isActive', isEqualTo: true);
      
      if (type != null && type != 'All') {
        query = query.where('type', isEqualTo: type);
      }
      
      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Instructor(
          id: doc.id,
          name: data['name'] ?? '',
          type: data['type'] ?? 'CFI',
          location: data['location'] ?? '',
          lat: (data['lat'] ?? 0).toDouble(),
          lng: (data['lng'] ?? 0).toDouble(),
          preferredLocations: List<String>.from(data['preferredLocations'] ?? []),
          endorsements: List<String>.from(data['endorsements'] ?? []),
          rating: (data['rating'] ?? 0).toDouble(),
          reviews: (data['reviews'] as List?)?.map((r) => Review(
            id: r['id'] ?? '',
            userId: r['userId'] ?? '',
            userName: r['userName'] ?? '',
            rating: (r['rating'] ?? 0.0).toDouble(),
            comment: r['comment'] ?? '',
            date: r['date'] != null ? r['date'].toDate() : DateTime.now(),
            ownerResponse: r['ownerResponse'],
          )).toList() ?? [],
          contactInfo: data['contactInfo'],
          contactThroughApp: data['contactThroughApp'] ?? true,
          lastUpdated: data['lastUpdated']?.toDate() ?? DateTime.now(),
          isActive: data['isActive'] ?? true,
        );
      }).toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error getting instructors: $e');
      return [];
    }
  }

  Future<void> updateInstructor(String instructorId, Map<String, dynamic> updates) async {
    try {
      updates['lastUpdated'] = FieldValue.serverTimestamp();
      await _firestore.collection('instructors').doc(instructorId).update(updates);
    } catch (e) {
      // ignore: avoid_print
      print('Error updating instructor: $e');
      rethrow;
    }
  }

  Future<void> deleteInstructor(String instructorId) async {
    try {
      await _firestore.collection('instructors').doc(instructorId).delete();
    } catch (e) {
      // ignore: avoid_print
      print('Error deleting instructor: $e');
      rethrow;
    }
  }
} 
