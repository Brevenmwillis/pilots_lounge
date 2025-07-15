import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final String? photoURL;
  final String? phoneNumber;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  
  // Pilot credentials
  final String? pilotLicense;
  final List<String> ratings; // ['Private', 'Instrument', 'Commercial', 'CFI', etc.]
  final int? totalFlightHours;
  final String? medicalClass; // ['First', 'Second', 'Third']
  final DateTime? medicalExpiry;
  
  // Business information (for FBOs, schools, mechanics)
  final bool isBusinessAccount;
  final String? businessName;
  final String? businessLicense;
  final String? businessType; // ['FBO', 'Flight School', 'Mechanic', 'Charter', 'Rental']
  final String? businessAddress;
  final String? businessPhone;
  final String? businessWebsite;
  
  // Account status
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime lastUpdated;
  
  // Preferences
  final List<String> preferredAircraftTypes;
  final double? maxRentalPrice;
  final int? maxTravelDistance;

  UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoURL,
    this.phoneNumber,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.pilotLicense,
    this.ratings = const [],
    this.totalFlightHours,
    this.medicalClass,
    this.medicalExpiry,
    this.isBusinessAccount = false,
    this.businessName,
    this.businessLicense,
    this.businessType,
    this.businessAddress,
    this.businessPhone,
    this.businessWebsite,
    this.isVerified = false,
    this.isActive = true,
    required this.createdAt,
    required this.lastUpdated,
    this.preferredAircraftTypes = const [],
    this.maxRentalPrice,
    this.maxTravelDistance,
  });

  // Create from Firestore document
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoURL: data['photoURL'],
      phoneNumber: data['phoneNumber'],
      address: data['address'],
      city: data['city'],
      state: data['state'],
      zipCode: data['zipCode'],
      pilotLicense: data['pilotLicense'],
      ratings: List<String>.from(data['ratings'] ?? []),
      totalFlightHours: data['totalFlightHours'],
      medicalClass: data['medicalClass'],
      medicalExpiry: data['medicalExpiry']?.toDate(),
      isBusinessAccount: data['isBusinessAccount'] ?? false,
      businessName: data['businessName'],
      businessLicense: data['businessLicense'],
      businessType: data['businessType'],
      businessAddress: data['businessAddress'],
      businessPhone: data['businessPhone'],
      businessWebsite: data['businessWebsite'],
      isVerified: data['isVerified'] ?? false,
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      lastUpdated: data['lastUpdated']?.toDate() ?? DateTime.now(),
      preferredAircraftTypes: List<String>.from(data['preferredAircraftTypes'] ?? []),
      maxRentalPrice: data['maxRentalPrice']?.toDouble(),
      maxTravelDistance: data['maxTravelDistance'],
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'pilotLicense': pilotLicense,
      'ratings': ratings,
      'totalFlightHours': totalFlightHours,
      'medicalClass': medicalClass,
      'medicalExpiry': medicalExpiry,
      'isBusinessAccount': isBusinessAccount,
      'businessName': businessName,
      'businessLicense': businessLicense,
      'businessType': businessType,
      'businessAddress': businessAddress,
      'businessPhone': businessPhone,
      'businessWebsite': businessWebsite,
      'isVerified': isVerified,
      'isActive': isActive,
      'createdAt': createdAt,
      'lastUpdated': lastUpdated,
      'preferredAircraftTypes': preferredAircraftTypes,
      'maxRentalPrice': maxRentalPrice,
      'maxTravelDistance': maxTravelDistance,
    };
  }

  // Create a copy with updated fields
  UserProfile copyWith({
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? pilotLicense,
    List<String>? ratings,
    int? totalFlightHours,
    String? medicalClass,
    DateTime? medicalExpiry,
    bool? isBusinessAccount,
    String? businessName,
    String? businessLicense,
    String? businessType,
    String? businessAddress,
    String? businessPhone,
    String? businessWebsite,
    bool? isVerified,
    bool? isActive,
    List<String>? preferredAircraftTypes,
    double? maxRentalPrice,
    int? maxTravelDistance,
  }) {
    return UserProfile(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      pilotLicense: pilotLicense ?? this.pilotLicense,
      ratings: ratings ?? this.ratings,
      totalFlightHours: totalFlightHours ?? this.totalFlightHours,
      medicalClass: medicalClass ?? this.medicalClass,
      medicalExpiry: medicalExpiry ?? this.medicalExpiry,
      isBusinessAccount: isBusinessAccount ?? this.isBusinessAccount,
      businessName: businessName ?? this.businessName,
      businessLicense: businessLicense ?? this.businessLicense,
      businessType: businessType ?? this.businessType,
      businessAddress: businessAddress ?? this.businessAddress,
      businessPhone: businessPhone ?? this.businessPhone,
      businessWebsite: businessWebsite ?? this.businessWebsite,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      lastUpdated: DateTime.now(),
      preferredAircraftTypes: preferredAircraftTypes ?? this.preferredAircraftTypes,
      maxRentalPrice: maxRentalPrice ?? this.maxRentalPrice,
      maxTravelDistance: maxTravelDistance ?? this.maxTravelDistance,
    );
  }
} 
