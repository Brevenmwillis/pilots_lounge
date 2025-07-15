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
  });
} 
