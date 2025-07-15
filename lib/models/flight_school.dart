// ignore: unused_import
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
  final List<dynamic> reviews;
  final DateTime lastUpdated;

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
  });
}
