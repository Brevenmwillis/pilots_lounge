// ignore: unused_import
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
  final List<dynamic> reviews;
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
} 
