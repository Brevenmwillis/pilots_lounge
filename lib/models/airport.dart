import 'package:cloud_firestore/cloud_firestore.dart';
import 'review.dart';

class Airport {
  final String id;
  final String code;
  final String name;
  final String location;
  final double lat;
  final double lng;
  final List<String> restaurants;
  final bool hasCourtesyCar;
  final List<String> services;
  final bool hasSelfServeFuel;
  final List<String> tipsAndTricks;
  final bool hasTieDowns;
  final bool hasHangars;
  final double tieDownPrice;
  final double hangarPrice;
  final double rating;
  final List<Review> reviews;
  final DateTime lastUpdated;
  final bool isActive;

  Airport({
    required this.id,
    required this.code,
    required this.name,
    required this.location,
    required this.lat,
    required this.lng,
    required this.restaurants,
    required this.hasCourtesyCar,
    required this.services,
    required this.hasSelfServeFuel,
    required this.tipsAndTricks,
    required this.hasTieDowns,
    required this.hasHangars,
    required this.tieDownPrice,
    required this.hangarPrice,
    required this.rating,
    required this.reviews,
    required this.lastUpdated,
    this.isActive = true,
  });

  // Convert from Firestore document
  factory Airport.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
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
      'code': code,
      'name': name,
      'location': location,
      'lat': lat,
      'lng': lng,
      'restaurants': restaurants,
      'hasCourtesyCar': hasCourtesyCar,
      'services': services,
      'hasSelfServeFuel': hasSelfServeFuel,
      'tipsAndTricks': tipsAndTricks,
      'hasTieDowns': hasTieDowns,
      'hasHangars': hasHangars,
      'tieDownPrice': tieDownPrice,
      'hangarPrice': hangarPrice,
      'rating': rating,
      'reviews': reviews.map((review) => review.toFirestore()).toList(),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'isActive': isActive,
    };
  }
} 
