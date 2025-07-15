// ignore: unused_import
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
  final List<String> reviews;
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
} 
