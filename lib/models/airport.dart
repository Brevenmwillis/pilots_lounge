// ignore: unused_import
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
  final List<dynamic> reviews;
  final DateTime lastUpdated;

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
  });
} 
