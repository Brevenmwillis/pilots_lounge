import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pilots_lounge/models/user_profile.dart';
import 'package:pilots_lounge/models/aircraft.dart';
import 'package:pilots_lounge/models/instructor.dart';
import 'package:pilots_lounge/models/mechanic.dart';
import 'package:pilots_lounge/models/flight_school.dart';
import 'package:pilots_lounge/models/review.dart';
import 'package:pilots_lounge/models/airport.dart';

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
        'type': aircraft.type,
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
          type: data['type'] ?? 'rental',
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
            type: data['type'] ?? 'rental',
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

  // Mechanic Operations
  Future<String> createMechanic(Mechanic mechanic) async {
    try {
      final docRef = await _firestore.collection('mechanics').add({
        'name': mechanic.name,
        'location': mechanic.location,
        'lat': mechanic.lat,
        'lng': mechanic.lng,
        'specializations': mechanic.specializations,
        'averageQuotes': mechanic.averageQuotes,
        'contactInfo': mechanic.contactInfo,
        'travels': mechanic.travels,
        'rating': mechanic.rating,
        'reviews': mechanic.reviews.map((r) => r.toFirestore()).toList(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'isActive': mechanic.isActive,
        'createdAt': FieldValue.serverTimestamp(),
        'ownerId': _auth.currentUser?.uid,
      });
      return docRef.id;
    } catch (e) {
      // ignore: avoid_print
      print('Error creating mechanic: $e');
      rethrow;
    }
  }

  Future<List<Mechanic>> getMechanics() async {
    try {
      final querySnapshot = await _firestore.collection('mechanics').where('isActive', isEqualTo: true).get();
      return querySnapshot.docs.map((doc) {
        // ignore: unnecessary_cast
        final data = doc.data() as Map<String, dynamic>;
        return Mechanic(
          id: doc.id,
          name: data['name'] ?? '',
          location: data['location'] ?? '',
          lat: (data['lat'] ?? 0).toDouble(),
          lng: (data['lng'] ?? 0).toDouble(),
          specializations: List<String>.from(data['specializations'] ?? []),
          averageQuotes: Map<String, double>.from(data['averageQuotes'] ?? {}),
          contactInfo: data['contactInfo'] ?? '',
          travels: data['travels'] ?? false,
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
          lastUpdated: data['lastUpdated']?.toDate() ?? DateTime.now(),
          isActive: data['isActive'] ?? true,
        );
      }).toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error getting mechanics: $e');
      return [];
    }
  }

  Future<void> updateMechanic(String mechanicId, Map<String, dynamic> updates) async {
    try {
      updates['lastUpdated'] = FieldValue.serverTimestamp();
      await _firestore.collection('mechanics').doc(mechanicId).update(updates);
    } catch (e) {
      // ignore: avoid_print
      print('Error updating mechanic: $e');
      rethrow;
    }
  }

  Future<void> deleteMechanic(String mechanicId) async {
    try {
      await _firestore.collection('mechanics').doc(mechanicId).delete();
    } catch (e) {
      // ignore: avoid_print
      print('Error deleting mechanic: $e');
      rethrow;
    }
  }

  // Flight School Operations
  Future<String> createFlightSchool(FlightSchool school) async {
    try {
      final docRef = await _firestore.collection('flight_schools').add({
        'name': school.name,
        'location': school.location,
        'lat': school.lat,
        'lng': school.lng,
        'rating': school.rating,
        'price': school.price,
        'curriculum': school.curriculum,
        'planesAvailable': school.planesAvailable,
        'averageGraduationCost': school.averageGraduationCost,
        'reviews': school.reviews.map((r) => r.toFirestore()).toList(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'isActive': school.isActive,
        'createdAt': FieldValue.serverTimestamp(),
        'ownerId': _auth.currentUser?.uid,
      });
      return docRef.id;
    } catch (e) {
      // ignore: avoid_print
      print('Error creating flight school: $e');
      rethrow;
    }
  }

  Future<List<FlightSchool>> getFlightSchools() async {
    try {
      final querySnapshot = await _firestore.collection('flight_schools').where('isActive', isEqualTo: true).get();
      return querySnapshot.docs.map((doc) {
        // ignore: unnecessary_cast
        final data = doc.data() as Map<String, dynamic>;
        return FlightSchool(
          id: doc.id,
          name: data['name'] ?? '',
          location: data['location'] ?? '',
          lat: (data['lat'] ?? 0).toDouble(),
          lng: (data['lng'] ?? 0).toDouble(),
          rating: (data['rating'] ?? 0).toDouble(),
          price: (data['price'] ?? 0).toDouble(),
          curriculum: List<String>.from(data['curriculum'] ?? []),
          planesAvailable: List<String>.from(data['planesAvailable'] ?? []),
          averageGraduationCost: (data['averageGraduationCost'] ?? 0).toDouble(),
          reviews: (data['reviews'] as List?)?.map((r) => Review(
            id: r['id'] ?? '',
            userId: r['userId'] ?? '',
            userName: r['userName'] ?? '',
            rating: (r['rating'] ?? 0.0).toDouble(),
            comment: r['comment'] ?? '',
            date: r['date'] != null ? r['date'].toDate() : DateTime.now(),
            ownerResponse: r['ownerResponse'],
          )).toList() ?? [],
          lastUpdated: data['lastUpdated']?.toDate() ?? DateTime.now(),
          isActive: data['isActive'] ?? true,
        );
      }).toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error getting flight schools: $e');
      return [];
    }
  }

  Future<void> updateFlightSchool(String schoolId, Map<String, dynamic> updates) async {
    try {
      updates['lastUpdated'] = FieldValue.serverTimestamp();
      await _firestore.collection('flight_schools').doc(schoolId).update(updates);
    } catch (e) {
      // ignore: avoid_print
      print('Error updating flight school: $e');
      rethrow;
    }
  }

  Future<void> deleteFlightSchool(String schoolId) async {
    try {
      await _firestore.collection('flight_schools').doc(schoolId).delete();
    } catch (e) {
      // ignore: avoid_print
      print('Error deleting flight school: $e');
      rethrow;
    }
  }

  // Airport Operations
  Future<List<Airport>> getAirports() async {
    try {
      final querySnapshot = await _firestore.collection('airports').where('isActive', isEqualTo: true).get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Airport(
          id: doc.id,
          code: data['code'] ?? '',
          name: data['name'] ?? '',
          location: data['location'] ?? '',
          lat: (data['lat'] ?? 0).toDouble(),
          lng: (data['lng'] ?? 0).toDouble(),
          restaurants: List<String>.from(data['restaurants'] ?? []),
          hasCourtesyCar: data['hasCourtesyCar'] ?? false,
          services: List<String>.from(data['services'] ?? []),
          hasSelfServeFuel: data['hasSelfServeFuel'] ?? false,
          tipsAndTricks: List<String>.from(data['tipsAndTricks'] ?? []),
          hasTieDowns: data['hasTieDowns'] ?? false,
          hasHangars: data['hasHangars'] ?? false,
          tieDownPrice: (data['tieDownPrice'] ?? 0).toDouble(),
          hangarPrice: (data['hangarPrice'] ?? 0).toDouble(),
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
          lastUpdated: data['lastUpdated']?.toDate() ?? DateTime.now(),
          isActive: data['isActive'] ?? true,
        );
      }).toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error getting airports: $e');
      return [];
    }
  }

  // Get aircraft for rent
  Future<List<Aircraft>> getAircraftForRent() async {
    try {
      final querySnapshot = await _firestore
          .collection('aircraft_listings')
          .where('isActive', isEqualTo: true)
          .where('type', isEqualTo: 'rental')
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Aircraft(
          id: doc.id,
          registration: data['registration'] ?? '',
          make: data['make'] ?? '',
          model: data['model'] ?? '',
          year: data['year'] ?? 0,
          price: (data['price'] ?? 0).toDouble(),
          location: data['location'] ?? '',
          lat: (data['lat'] ?? 0).toDouble(),
          lng: (data['lng'] ?? 0).toDouble(),
          avionics: List<String>.from(data['avionics'] ?? []),
          specs: Map<String, String>.from(data['specs'] ?? {}),
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
          ownerId: data['ownerId'] ?? '',
          bookingWebsite: data['bookingWebsite'] ?? '',
          paymentMethods: List<String>.from(data['paymentMethods'] ?? []),
          insuranceRequirements: data['insuranceRequirements'] ?? '',
          insuranceDeductible: (data['insuranceDeductible'] ?? 0).toDouble(),
          internationalFlights: data['internationalFlights'] ?? false,
          lastUpdated: data['lastUpdated']?.toDate() ?? DateTime.now(),
          isActive: data['isActive'] ?? true,
          type: data['type'] ?? 'rental',
        );
      }).toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error getting rental aircraft: $e');
      return [];
    }
  }
} 
