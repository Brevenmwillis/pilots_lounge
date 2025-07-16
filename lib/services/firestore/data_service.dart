import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pilots_lounge/models/aircraft.dart';
import 'package:pilots_lounge/models/instructor.dart';
import 'package:pilots_lounge/models/mechanic.dart';
import 'package:pilots_lounge/models/flight_school.dart';
import 'package:pilots_lounge/models/airport.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Aircraft Operations
  Future<List<Aircraft>> getAircraftForRent() async {
    try {
      final snapshot = await _firestore
          .collection('aircraft')
          .where('isActive', isEqualTo: true)
          .where('type', isEqualTo: 'rental')
          .get();
      
      return snapshot.docs.map((doc) => Aircraft.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting rental aircraft: $e');
      return [];
    }
  }

  Future<List<Aircraft>> getAircraftForSale() async {
    try {
      final snapshot = await _firestore
          .collection('aircraft')
          .where('isActive', isEqualTo: true)
          .where('type', isEqualTo: 'sale')
          .get();
      
      return snapshot.docs.map((doc) => Aircraft.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting aircraft for sale: $e');
      return [];
    }
  }

  Future<List<Aircraft>> getCharterAircraft() async {
    try {
      final snapshot = await _firestore
          .collection('aircraft')
          .where('isActive', isEqualTo: true)
          .where('type', isEqualTo: 'charter')
          .get();
      
      return snapshot.docs.map((doc) => Aircraft.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting charter aircraft: $e');
      return [];
    }
  }

  // Instructor Operations
  Future<List<Instructor>> getInstructors({String? type}) async {
    try {
      Query query = _firestore
          .collection('instructors')
          .where('isActive', isEqualTo: true);
      
      if (type != null && type != 'All') {
        query = query.where('type', isEqualTo: type);
      }
      
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => Instructor.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting instructors: $e');
      return [];
    }
  }

  // Mechanic Operations
  Future<List<Mechanic>> getMechanics() async {
    try {
      final snapshot = await _firestore
          .collection('mechanics')
          .where('isActive', isEqualTo: true)
          .get();
      
      return snapshot.docs.map((doc) => Mechanic.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting mechanics: $e');
      return [];
    }
  }

  // Flight School Operations
  Future<List<FlightSchool>> getFlightSchools() async {
    try {
      final snapshot = await _firestore
          .collection('flight_schools')
          .where('isActive', isEqualTo: true)
          .get();
      
      return snapshot.docs.map((doc) => FlightSchool.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting flight schools: $e');
      return [];
    }
  }

  // Airport Operations
  Future<List<Airport>> getAirports() async {
    try {
      final snapshot = await _firestore
          .collection('airports')
          .where('isActive', isEqualTo: true)
          .get();
      
      return snapshot.docs.map((doc) => Airport.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting airports: $e');
      return [];
    }
  }

  // Create Operations
  Future<void> createAircraft(Aircraft aircraft) async {
    try {
      await _firestore.collection('aircraft').add(aircraft.toFirestore());
    } catch (e) {
      print('Error creating aircraft: $e');
      rethrow;
    }
  }

  Future<void> createInstructor(Instructor instructor) async {
    try {
      await _firestore.collection('instructors').add(instructor.toFirestore());
    } catch (e) {
      print('Error creating instructor: $e');
      rethrow;
    }
  }

  Future<void> createMechanic(Mechanic mechanic) async {
    try {
      await _firestore.collection('mechanics').add(mechanic.toFirestore());
    } catch (e) {
      print('Error creating mechanic: $e');
      rethrow;
    }
  }

  Future<void> createFlightSchool(FlightSchool school) async {
    try {
      await _firestore.collection('flight_schools').add(school.toFirestore());
    } catch (e) {
      print('Error creating flight school: $e');
      rethrow;
    }
  }

  // Update Operations
  Future<void> updateAircraft(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('aircraft').doc(id).update(data);
    } catch (e) {
      print('Error updating aircraft: $e');
      rethrow;
    }
  }

  // Delete Operations
  Future<void> deleteAircraft(String id) async {
    try {
      await _firestore.collection('aircraft').doc(id).delete();
    } catch (e) {
      print('Error deleting aircraft: $e');
      rethrow;
    }
  }

  // Search Operations
  Future<List<Aircraft>> searchAircraft({
    String? make,
    String? model,
    double? minPrice,
    double? maxPrice,
    String? location,
  }) async {
    try {
      Query query = _firestore
          .collection('aircraft')
          .where('isActive', isEqualTo: true);
      
      if (make != null) {
        query = query.where('make', isEqualTo: make);
      }
      if (model != null) {
        query = query.where('model', isEqualTo: model);
      }
      if (minPrice != null) {
        query = query.where('price', isGreaterThanOrEqualTo: minPrice);
      }
      if (maxPrice != null) {
        query = query.where('price', isLessThanOrEqualTo: maxPrice);
      }
      
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => Aircraft.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error searching aircraft: $e');
      return [];
    }
  }
} 