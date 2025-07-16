import 'package:cloud_firestore/cloud_firestore.dart';
import 'review.dart';

class FlightSchool {
  final String id;
  final String name;
  final String location;
  final double lat;
  final double lng;
  final double rating;
  final double price;
  final List<String> curriculum;
  final List<String> planesAvailable;
  final double averageGraduationCost;
  final List<Review> reviews;
  final DateTime lastUpdated;
  final bool isActive;

  FlightSchool({
    required this.id,
    required this.name,
    required this.location,
    required this.lat,
    required this.lng,
    required this.rating,
    required this.price,
    required this.curriculum,
    required this.planesAvailable,
    required this.averageGraduationCost,
    required this.reviews,
    required this.lastUpdated,
    this.isActive = true,
  });

  // Convert from Firestore document
  factory FlightSchool.fromFirestore(DocumentSnapshot doc) {
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
      'rating': rating,
      'price': price,
      'curriculum': curriculum,
      'planesAvailable': planesAvailable,
      'averageGraduationCost': averageGraduationCost,
      'reviews': reviews.map((review) => review.toFirestore()).toList(),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'isActive': isActive,
    };
  }
}
