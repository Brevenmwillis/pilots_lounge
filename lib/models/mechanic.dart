import 'package:cloud_firestore/cloud_firestore.dart';
import 'review.dart';

class Mechanic {
  final String id;
  final String name;
  final String location;
  final double lat;
  final double lng;
  final List<String> specializations;
  final Map<String, double> averageQuotes;
  final String contactInfo;
  final bool travels;
  final double rating;
  final List<Review> reviews;
  final DateTime lastUpdated;
  final bool isActive;

  Mechanic({
    required this.id,
    required this.name,
    required this.location,
    required this.lat,
    required this.lng,
    required this.specializations,
    required this.averageQuotes,
    required this.contactInfo,
    required this.travels,
    required this.rating,
    required this.reviews,
    required this.lastUpdated,
    required this.isActive,
  });

  // Convert from Firestore document
  factory Mechanic.fromFirestore(DocumentSnapshot doc) {
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
      reviews: (data['reviews'] as List<dynamic>? ?? [])
          .map((review) => Review.fromFirestore(review))
          .toList(),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'location': location,
      'lat': lat,
      'lng': lng,
      'specializations': specializations,
      'averageQuotes': averageQuotes,
      'contactInfo': contactInfo,
      'travels': travels,
      'rating': rating,
      'reviews': reviews.map((review) => review.toFirestore()).toList(),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'isActive': isActive,
    };
  }
} 
