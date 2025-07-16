import 'package:cloud_firestore/cloud_firestore.dart';
import 'review.dart';

class Aircraft {
  final String id;
  final String registration;
  final String make;
  final String model;
  final int year;
  final double price;
  final String location;
  final double lat;
  final double lng;
  final List<String> avionics;
  final Map<String, String> specs;
  final double rating;
  final List<Review> reviews;
  final String ownerId;
  final String bookingWebsite;
  final List<String> paymentMethods;
  final String insuranceRequirements;
  final double insuranceDeductible;
  final bool internationalFlights;
  final DateTime lastUpdated;
  final bool isActive;
  final String type; // 'rental', 'sale', 'charter'

  Aircraft({
    required this.id,
    required this.registration,
    required this.make,
    required this.model,
    required this.year,
    required this.price,
    required this.location,
    required this.lat,
    required this.lng,
    required this.avionics,
    required this.specs,
    required this.rating,
    required this.reviews,
    required this.ownerId,
    required this.bookingWebsite,
    required this.paymentMethods,
    required this.insuranceRequirements,
    required this.insuranceDeductible,
    required this.internationalFlights,
    required this.lastUpdated,
    required this.isActive,
    this.type = 'rental',
  });

  // Convert from Firestore document
  factory Aircraft.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
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
      reviews: (data['reviews'] as List<dynamic>? ?? [])
          .map((review) => Review.fromFirestore(review))
          .toList(),
      ownerId: data['ownerId'] ?? '',
      bookingWebsite: data['bookingWebsite'] ?? '',
      paymentMethods: List<String>.from(data['paymentMethods'] ?? []),
      insuranceRequirements: data['insuranceRequirements'] ?? '',
      insuranceDeductible: (data['insuranceDeductible'] ?? 0).toDouble(),
      internationalFlights: data['internationalFlights'] ?? false,
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      type: data['type'] ?? 'rental',
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'registration': registration,
      'make': make,
      'model': model,
      'year': year,
      'price': price,
      'location': location,
      'lat': lat,
      'lng': lng,
      'avionics': avionics,
      'specs': specs,
      'rating': rating,
      'reviews': reviews.map((review) => review.toFirestore()).toList(),
      'ownerId': ownerId,
      'bookingWebsite': bookingWebsite,
      'paymentMethods': paymentMethods,
      'insuranceRequirements': insuranceRequirements,
      'insuranceDeductible': insuranceDeductible,
      'internationalFlights': internationalFlights,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'isActive': isActive,
      'type': type,
    };
  }
} 
