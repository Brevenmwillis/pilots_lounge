import 'package:cloud_firestore/cloud_firestore.dart';
import 'review.dart';

class Instructor {
  final String id;
  final String name;
  final String type; // 'CFI' or 'DPE'
  final String location;
  final double lat;
  final double lng;
  final List<String> preferredLocations;
  final List<String> endorsements;
  final double rating;
  final List<Review> reviews;
  final String? contactInfo;
  final bool contactThroughApp;
  final DateTime lastUpdated;
  final bool isActive;

  Instructor({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.lat,
    required this.lng,
    required this.preferredLocations,
    required this.endorsements,
    required this.rating,
    required this.reviews,
    this.contactInfo,
    required this.contactThroughApp,
    required this.lastUpdated,
    required this.isActive,
  });

  // Convert from Firestore document
  factory Instructor.fromFirestore(DocumentSnapshot doc) {
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
      reviews: (data['reviews'] as List<dynamic>? ?? [])
          .map((review) => Review.fromFirestore(review))
          .toList(),
      contactInfo: data['contactInfo'],
      contactThroughApp: data['contactThroughApp'] ?? true,
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'location': location,
      'lat': lat,
      'lng': lng,
      'preferredLocations': preferredLocations,
      'endorsements': endorsements,
      'rating': rating,
      'reviews': reviews.map((review) => review.toFirestore()).toList(),
      'contactInfo': contactInfo,
      'contactThroughApp': contactThroughApp,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'isActive': isActive,
    };
  }
} 
