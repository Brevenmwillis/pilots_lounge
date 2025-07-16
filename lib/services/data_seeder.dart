// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pilots_lounge/models/aircraft.dart';
import 'package:pilots_lounge/models/instructor.dart';
import 'package:pilots_lounge/models/mechanic.dart';
import 'package:pilots_lounge/models/flight_school.dart';
import 'package:pilots_lounge/models/airport.dart';
import 'package:pilots_lounge/models/review.dart';

class DataSeeder {
  static final DataSeeder _instance = DataSeeder._internal();
  factory DataSeeder() => _instance;
  DataSeeder._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Seed all data
  Future<void> seedAllData() async {
    print('Starting data seeding...');
    
    try {
      await seedAircraft();
      await seedInstructors();
      await seedMechanics();
      await seedFlightSchools();
      await seedAirports();
      
      print('✅ All data seeded successfully!');
    } catch (e) {
      print('❌ Error seeding data: $e');
    }
  }

  // Seed Aircraft Data
  Future<void> seedAircraft() async {
    print('Seeding aircraft data...');
    
    final aircraftData = [
      // Rental Aircraft
      {
        'registration': 'N12345',
        'make': 'Cessna',
        'model': '172 Skyhawk',
        'year': 2018,
        'price': 165.0,
        'location': 'Phoenix Sky Harbor International Airport',
        'lat': 33.4342,
        'lng': -112.0116,
        'avionics': ['Garmin G1000 NXi', 'Autopilot', 'ADS-B In/Out', 'Weather Radar'],
        'specs': {
          'Engine': 'Lycoming O-320',
          'HP': '160',
          'Fuel Capacity': '56 gallons',
          'Range': '575 nm',
          'Cruise Speed': '120 knots',
          'Max Takeoff Weight': '2,450 lbs',
          'Useful Load': '837 lbs',
        },
        'rating': 4.7,
        'reviews': [],
        'ownerId': 'owner_phoenix_aviation',
        'bookingWebsite': 'https://phoenixaviation.com/book',
        'paymentMethods': ['Credit Card', 'Cash', 'Check'],
        'insuranceRequirements': r'$1M liability, $50K hull',
        'insuranceDeductible': 1000.0,
        'internationalFlights': false,
        'lastUpdated': DateTime.now(),
        'isActive': true,
        'type': 'rental',
      },
      {
        'registration': 'N67890',
        'make': 'Piper',
        'model': 'PA-28 Arrow',
        'year': 2016,
        'price': 195.0,
        'location': 'Scottsdale Airport',
        'lat': 33.6229,
        'lng': -111.9102,
        'avionics': ['Garmin G1000', 'Autopilot', 'ADS-B In/Out'],
        'specs': {
          'Engine': 'Lycoming IO-360',
          'HP': '200',
          'Fuel Capacity': '84 gallons',
          'Range': '750 nm',
          'Cruise Speed': '140 knots',
          'Max Takeoff Weight': '2,750 lbs',
          'Useful Load': '950 lbs',
        },
        'rating': 4.8,
        'reviews': [],
        'ownerId': 'owner_scottsdale_air',
        'bookingWebsite': 'https://scottsdaleair.com/book',
        'paymentMethods': ['Credit Card', 'Wire Transfer'],
        'insuranceRequirements': r'$1M liability, $75K hull',
        'insuranceDeductible': 1500.0,
        'internationalFlights': false,
        'lastUpdated': DateTime.now(),
        'isActive': true,
        'type': 'rental',
      },
      {
        'registration': 'N54321',
        'make': 'Cessna',
        'model': '152',
        'year': 2015,
        'price': 125.0,
        'location': 'Chandler Municipal Airport',
        'lat': 33.2692,
        'lng': -111.8108,
        'avionics': ['Garmin G500', 'Autopilot', 'ADS-B In/Out'],
        'specs': {
          'Engine': 'Lycoming O-235',
          'HP': '110',
          'Fuel Capacity': '26 gallons',
          'Range': '415 nm',
          'Cruise Speed': '100 knots',
          'Max Takeoff Weight': '1,670 lbs',
          'Useful Load': '490 lbs',
        },
        'rating': 4.5,
        'reviews': [],
        'ownerId': 'owner_chandler_flight',
        'bookingWebsite': 'https://chandlerflight.com/book',
        'paymentMethods': ['Credit Card', 'Cash'],
        'insuranceRequirements': r'$1M liability, $40K hull',
        'insuranceDeductible': 800.0,
        'internationalFlights': false,
        'lastUpdated': DateTime.now(),
        'isActive': true,
        'type': 'rental',
      },

      // Aircraft for Sale
      {
        'registration': 'N98765',
        'make': 'Cessna',
        'model': '172 Skyhawk',
        'year': 2019,
        'price': 285000.0,
        'location': 'Phoenix Deer Valley Airport',
        'lat': 33.6883,
        'lng': -112.0825,
        'avionics': ['Garmin G1000 NXi', 'Autopilot', 'ADS-B In/Out', 'Weather Radar'],
        'specs': {
          'Engine': 'Lycoming O-320',
          'HP': '160',
          'Fuel Capacity': '56 gallons',
          'Range': '575 nm',
          'Cruise Speed': '120 knots',
          'TT': '850',
          'SMOH': '150',
          'Max Takeoff Weight': '2,450 lbs',
        },
        'rating': 4.9,
        'reviews': [],
        'ownerId': 'owner_deer_valley_aviation',
        'bookingWebsite': '',
        'paymentMethods': ['Cash', 'Financing Available'],
        'insuranceRequirements': 'N/A',
        'insuranceDeductible': 0.0,
        'internationalFlights': false,
        'lastUpdated': DateTime.now(),
        'isActive': true,
        'type': 'sale',
      },

      // Charter Aircraft
      {
        'registration': 'N11111',
        'make': 'Piper',
        'model': 'PA-31 Navajo',
        'year': 2017,
        'price': 450.0,
        'location': 'Phoenix Sky Harbor International Airport',
        'lat': 33.4342,
        'lng': -112.0116,
        'avionics': ['Garmin G1000', 'Autopilot', 'ADS-B In/Out', 'Weather Radar'],
        'specs': {
          'Engine': 'Lycoming TIO-540',
          'HP': '310',
          'Fuel Capacity': '144 gallons',
          'Range': '1,200 nm',
          'Cruise Speed': '180 knots',
          'Passengers': '6',
          'Max Takeoff Weight': '6,500 lbs',
        },
        'rating': 4.8,
        'reviews': [],
        'ownerId': 'owner_phoenix_charter',
        'bookingWebsite': 'https://phoenixcharter.com/book',
        'paymentMethods': ['Credit Card', 'Wire Transfer'],
        'insuranceRequirements': r'$5M liability, $500K hull',
        'insuranceDeductible': 2500.0,
        'internationalFlights': true,
        'lastUpdated': DateTime.now(),
        'isActive': true,
        'type': 'charter',
      },
    ];

    for (final data in aircraftData) {
      await _firestore.collection('aircraft').add(data);
    }
    
    print('✅ Aircraft data seeded successfully!');
  }

  // Seed Instructors Data
  Future<void> seedInstructors() async {
    print('Seeding instructors data...');
    
    final instructorsData = [
      {
        'name': 'John Smith',
        'type': 'CFI',
        'location': 'Phoenix Sky Harbor International Airport',
        'lat': 33.4342,
        'lng': -112.0116,
        'preferredLocations': ['Phoenix', 'Scottsdale', 'Mesa'],
        'endorsements': ['Private Pilot', 'Instrument Rating', 'Commercial Pilot', 'Multi-Engine'],
        'rating': 4.8,
        'reviews': [],
        'contactInfo': 'john.smith@phoenixaviation.com',
        'contactThroughApp': true,
        'lastUpdated': DateTime.now(),
        'isActive': true,
      },
      {
        'name': 'Sarah Johnson',
        'type': 'DPE',
        'location': 'Scottsdale Airport',
        'lat': 33.6229,
        'lng': -111.9102,
        'preferredLocations': ['Scottsdale', 'Phoenix', 'Paradise Valley'],
        'endorsements': ['Private Pilot', 'Instrument Rating', 'Commercial Pilot', 'Multi-Engine', 'ATP'],
        'rating': 4.9,
        'reviews': [],
        'contactInfo': 'sarah.johnson@scottsdaleair.com',
        'contactThroughApp': true,
        'lastUpdated': DateTime.now(),
        'isActive': true,
      },
      {
        'name': 'Mike Rodriguez',
        'type': 'CFI',
        'location': 'Chandler Municipal Airport',
        'lat': 33.2692,
        'lng': -111.8108,
        'preferredLocations': ['Chandler', 'Gilbert', 'Mesa'],
        'endorsements': ['Private Pilot', 'Instrument Rating', 'Commercial Pilot'],
        'rating': 4.7,
        'reviews': [],
        'contactInfo': 'mike.rodriguez@chandlerflight.com',
        'contactThroughApp': true,
        'lastUpdated': DateTime.now(),
        'isActive': true,
      },
      {
        'name': 'Lisa Chen',
        'type': 'CFI',
        'location': 'Phoenix Deer Valley Airport',
        'lat': 33.6883,
        'lng': -112.0825,
        'preferredLocations': ['Phoenix', 'Glendale', 'Peoria'],
        'endorsements': ['Private Pilot', 'Instrument Rating', 'Commercial Pilot', 'CFI'],
        'rating': 4.6,
        'reviews': [],
        'contactInfo': 'lisa.chen@deervalleyaviation.com',
        'contactThroughApp': true,
        'lastUpdated': DateTime.now(),
        'isActive': true,
      },
    ];

    for (final data in instructorsData) {
      await _firestore.collection('instructors').add(data);
    }
    
    print('✅ Instructors data seeded successfully!');
  }

  // Seed Mechanics Data
  Future<void> seedMechanics() async {
    print('Seeding mechanics data...');
    
    final mechanicsData = [
      {
        'name': 'Mike Johnson A&P',
        'location': 'Phoenix Sky Harbor International Airport',
        'lat': 33.4342,
        'lng': -112.0116,
        'specializations': ['Piston Engines', 'Avionics', 'Annual Inspections', 'Propeller Overhaul'],
        'averageQuotes': {
          'Annual Inspection': 800.0,
          'Oil Change': 150.0,
          '100-Hour Inspection': 600.0,
          'Avionics Installation': 2000.0,
          'Propeller Overhaul': 1200.0,
        },
        'contactInfo': 'mike.johnson@phoenixaviation.com',
        'travels': true,
        'rating': 4.8,
        'reviews': [],
        'lastUpdated': DateTime.now(),
        'isActive': true,
      },
      {
        'name': 'Bob Wilson Aviation',
        'location': 'Scottsdale Airport',
        'lat': 33.6229,
        'lng': -111.9102,
        'specializations': ['Turbine Engines', 'Composite Repair', 'Paint & Interior'],
        'averageQuotes': {
          'Annual Inspection': 1200.0,
          'Turbine Inspection': 2500.0,
          'Composite Repair': 800.0,
          'Paint Job': 15000.0,
          'Interior Refurbishment': 8000.0,
        },
        'contactInfo': 'bob.wilson@scottsdaleair.com',
        'travels': false,
        'rating': 4.9,
        'reviews': [],
        'lastUpdated': DateTime.now(),
        'isActive': true,
      },
      {
        'name': 'Carlos Martinez A&P',
        'location': 'Chandler Municipal Airport',
        'lat': 33.2692,
        'lng': -111.8108,
        'specializations': ['Piston Engines', 'Electrical Systems', 'Landing Gear'],
        'averageQuotes': {
          'Annual Inspection': 750.0,
          'Oil Change': 140.0,
          '100-Hour Inspection': 550.0,
          'Electrical Troubleshooting': 300.0,
          'Landing Gear Repair': 500.0,
        },
        'contactInfo': 'carlos.martinez@chandlerflight.com',
        'travels': true,
        'rating': 4.7,
        'reviews': [],
        'lastUpdated': DateTime.now(),
        'isActive': true,
      },
    ];

    for (final data in mechanicsData) {
      await _firestore.collection('mechanics').add(data);
    }
    
    print('✅ Mechanics data seeded successfully!');
  }

  // Seed Flight Schools Data
  Future<void> seedFlightSchools() async {
    print('Seeding flight schools data...');
    
    final schoolsData = [
      {
        'name': 'ATP Flight School - Phoenix',
        'location': 'Phoenix Sky Harbor International Airport',
        'lat': 33.4342,
        'lng': -112.0116,
        'rating': 4.6,
        'price': 175.0,
        'curriculum': ['Private Pilot', 'Instrument Rating', 'Commercial Pilot', 'CFI', 'Multi-Engine'],
        'planesAvailable': ['Cessna 172', 'Piper PA-28', 'Cessna 152', 'Piper Seminole'],
        'averageGraduationCost': 85000.0,
        'reviews': [],
        'lastUpdated': DateTime.now(),
        'isActive': true,
      },
      {
        'name': 'Chandler Flight School',
        'location': 'Chandler Municipal Airport',
        'lat': 33.2692,
        'lng': -111.8108,
        'rating': 4.8,
        'price': 160.0,
        'curriculum': ['Private Pilot', 'Instrument Rating', 'Commercial Pilot'],
        'planesAvailable': ['Cessna 152', 'Cessna 172', 'Piper PA-28'],
        'averageGraduationCost': 75000.0,
        'reviews': [],
        'lastUpdated': DateTime.now(),
        'isActive': true,
      },
      {
        'name': 'Mesa Gateway Aviation',
        'location': 'Phoenix-Mesa Gateway Airport',
        'lat': 33.3076,
        'lng': -111.6556,
        'rating': 4.5,
        'price': 180.0,
        'curriculum': ['Private Pilot', 'Commercial Pilot', 'Multi-Engine', 'CFI'],
        'planesAvailable': ['Cessna 172', 'Piper Seminole', 'Cessna 152'],
        'averageGraduationCost': 90000.0,
        'reviews': [],
        'lastUpdated': DateTime.now(),
        'isActive': true,
      },
      {
        'name': 'Scottsdale Aviation Academy',
        'location': 'Scottsdale Airport',
        'lat': 33.6229,
        'lng': -111.9102,
        'rating': 4.7,
        'price': 190.0,
        'curriculum': ['Private Pilot', 'Instrument Rating', 'Commercial Pilot', 'Multi-Engine'],
        'planesAvailable': ['Cessna 172', 'Piper Arrow', 'Piper Seminole'],
        'averageGraduationCost': 95000.0,
        'reviews': [],
        'lastUpdated': DateTime.now(),
        'isActive': true,
      },
    ];

    for (final data in schoolsData) {
      await _firestore.collection('flight_schools').add(data);
    }
    
    print('✅ Flight schools data seeded successfully!');
  }

  // Seed Airports Data
  Future<void> seedAirports() async {
    print('Seeding airports data...');
    
    final airportsData = [
      {
        'code': 'KPHX',
        'name': 'Phoenix Sky Harbor International Airport',
        'location': 'Phoenix, AZ',
        'lat': 33.4342,
        'lng': -112.0116,
        'restaurants': ['Sky Harbor Grill', 'Pilot\'s Cafe', 'Runway Restaurant', 'Altitude Bar & Grill'],
        'hasCourtesyCar': true,
        'services': ['FBO', 'Fuel', 'Maintenance', 'Flight Training', 'Charter Services'],
        'hasSelfServeFuel': true,
        'tipsAndTricks': ['Call ahead for courtesy car', 'Self-serve fuel available 24/7', 'Busy airspace - monitor approach'],
        'hasTieDowns': true,
        'hasHangars': true,
        'tieDownPrice': 15.0,
        'hangarPrice': 350.0,
        'rating': 4.5,
        'reviews': [],
        'lastUpdated': DateTime.now(),
        'isActive': true,
      },
      {
        'code': 'KSDL',
        'name': 'Scottsdale Airport',
        'location': 'Scottsdale, AZ',
        'lat': 33.6229,
        'lng': -111.9102,
        'restaurants': ['Hangar Cafe', 'Skyline Restaurant', 'Pilot\'s Lounge'],
        'hasCourtesyCar': false,
        'services': ['FBO', 'Fuel', 'Charter Services', 'Aircraft Sales'],
        'hasSelfServeFuel': false,
        'tipsAndTricks': ['No courtesy car available', 'Call FBO for fuel', 'Luxury aircraft common'],
        'hasTieDowns': true,
        'hasHangars': true,
        'tieDownPrice': 20.0,
        'hangarPrice': 400.0,
        'rating': 4.3,
        'reviews': [],
        'lastUpdated': DateTime.now(),
        'isActive': true,
      },
      {
        'code': 'KCHD',
        'name': 'Chandler Municipal Airport',
        'location': 'Chandler, AZ',
        'lat': 33.2692,
        'lng': -111.8108,
        'restaurants': ['Chandler Cafe', 'Skyway Diner'],
        'hasCourtesyCar': true,
        'services': ['FBO', 'Fuel', 'Flight Training', 'Aircraft Maintenance'],
        'hasSelfServeFuel': true,
        'tipsAndTricks': ['Courtesy car available with 24hr notice', 'Great for flight training'],
        'hasTieDowns': true,
        'hasHangars': true,
        'tieDownPrice': 12.0,
        'hangarPrice': 300.0,
        'rating': 4.7,
        'reviews': [],
        'lastUpdated': DateTime.now(),
        'isActive': true,
      },
      {
        'code': 'KDVT',
        'name': 'Phoenix Deer Valley Airport',
        'location': 'Phoenix, AZ',
        'lat': 33.6883,
        'lng': -112.0825,
        'restaurants': ['Deer Valley Diner', 'Pilot\'s Cafe'],
        'hasCourtesyCar': true,
        'services': ['FBO', 'Fuel', 'Flight Training', 'Aircraft Sales'],
        'hasSelfServeFuel': true,
        'tipsAndTricks': ['Busiest GA airport in US', 'Courtesy car available', 'Call ahead'],
        'hasTieDowns': true,
        'hasHangars': true,
        'tieDownPrice': 18.0,
        'hangarPrice': 380.0,
        'rating': 4.8,
        'reviews': [],
        'lastUpdated': DateTime.now(),
        'isActive': true,
      },
      {
        'code': 'KIWA',
        'name': 'Phoenix-Mesa Gateway Airport',
        'location': 'Mesa, AZ',
        'lat': 33.3076,
        'lng': -111.6556,
        'restaurants': ['Gateway Cafe', 'Mesa Diner'],
        'hasCourtesyCar': true,
        'services': ['FBO', 'Fuel', 'Flight Training', 'Aircraft Maintenance'],
        'hasSelfServeFuel': true,
        'tipsAndTricks': ['Courtesy car available', 'Less busy than Sky Harbor', 'Good alternative'],
        'hasTieDowns': true,
        'hasHangars': true,
        'tieDownPrice': 14.0,
        'hangarPrice': 320.0,
        'rating': 4.4,
        'reviews': [],
        'lastUpdated': DateTime.now(),
        'isActive': true,
      },
    ];

    for (final data in airportsData) {
      await _firestore.collection('airports').add(data);
    }
    
    print('✅ Airports data seeded successfully!');
  }

  // Clear all data (for testing)
  Future<void> clearAllData() async {
    print('Clearing all data...');
    
    try {
      final collections = ['aircraft', 'instructors', 'mechanics', 'flight_schools', 'airports'];
      
      for (final collection in collections) {
        final snapshot = await _firestore.collection(collection).get();
        final batch = _firestore.batch();
        
        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        
        await batch.commit();
      }
      
      print('✅ All data cleared successfully!');
    } catch (e) {
      print('❌ Error clearing data: $e');
    }
  }
} 