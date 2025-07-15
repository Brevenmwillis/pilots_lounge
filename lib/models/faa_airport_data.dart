class FAAAirportData {
  final String identifier;
  final String name;
  final String city;
  final String state;
  final double latitude;
  final double longitude;
  final int elevation;
  final String facilityType; // Airport, Heliport, Seaplane Base
  final String ownership; // Public, Private, Military
  final List<Runway> runways;
  final List<Frequency> frequencies;
  final List<Service> services;
  final List<String> fuelTypes;
  final List<String> specialProcedures;
  final List<String> hazards;
  final String patternAltitude;
  final String lighting;
  final String weatherStation;
  final String customs;
  final String immigration;
  final String agriculturalInspection;
  final String noiseAbatement;
  final String wildlifeHazards;
  final String remarks;

  FAAAirportData({
    required this.identifier,
    required this.name,
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.elevation,
    required this.facilityType,
    required this.ownership,
    required this.runways,
    required this.frequencies,
    required this.services,
    required this.fuelTypes,
    required this.specialProcedures,
    required this.hazards,
    required this.patternAltitude,
    required this.lighting,
    required this.weatherStation,
    required this.customs,
    required this.immigration,
    required this.agriculturalInspection,
    required this.noiseAbatement,
    required this.wildlifeHazards,
    required this.remarks,
  });

  factory FAAAirportData.fromJson(Map<String, dynamic> json) {
    return FAAAirportData(
      identifier: json['identifier'] ?? '',
      name: json['name'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      elevation: json['elevation'] ?? 0,
      facilityType: json['facilityType'] ?? '',
      ownership: json['ownership'] ?? '',
      runways: (json['runways'] as List?)?.map((r) => Runway.fromJson(r)).toList() ?? [],
      frequencies: (json['frequencies'] as List?)?.map((f) => Frequency.fromJson(f)).toList() ?? [],
      services: (json['services'] as List?)?.map((s) => Service.fromJson(s)).toList() ?? [],
      fuelTypes: List<String>.from(json['fuelTypes'] ?? []),
      specialProcedures: List<String>.from(json['specialProcedures'] ?? []),
      hazards: List<String>.from(json['hazards'] ?? []),
      patternAltitude: json['patternAltitude'] ?? '',
      lighting: json['lighting'] ?? '',
      weatherStation: json['weatherStation'] ?? '',
      customs: json['customs'] ?? '',
      immigration: json['immigration'] ?? '',
      agriculturalInspection: json['agriculturalInspection'] ?? '',
      noiseAbatement: json['noiseAbatement'] ?? '',
      wildlifeHazards: json['wildlifeHazards'] ?? '',
      remarks: json['remarks'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'name': name,
      'city': city,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
      'elevation': elevation,
      'facilityType': facilityType,
      'ownership': ownership,
      'runways': runways.map((r) => r.toJson()).toList(),
      'frequencies': frequencies.map((f) => f.toJson()).toList(),
      'services': services.map((s) => s.toJson()).toList(),
      'fuelTypes': fuelTypes,
      'specialProcedures': specialProcedures,
      'hazards': hazards,
      'patternAltitude': patternAltitude,
      'lighting': lighting,
      'weatherStation': weatherStation,
      'customs': customs,
      'immigration': immigration,
      'agriculturalInspection': agriculturalInspection,
      'noiseAbatement': noiseAbatement,
      'wildlifeHazards': wildlifeHazards,
      'remarks': remarks,
    };
  }
}

class Runway {
  final String designation;
  final int length;
  final int width;
  final String surface;
  final String lighting;
  final String markings;
  final String approachLights;
  final String visualGlideSlope;
  final String displacedThreshold;
  final String overrun;
  final String remarks;

  Runway({
    required this.designation,
    required this.length,
    required this.width,
    required this.surface,
    required this.lighting,
    required this.markings,
    required this.approachLights,
    required this.visualGlideSlope,
    required this.displacedThreshold,
    required this.overrun,
    required this.remarks,
  });

  factory Runway.fromJson(Map<String, dynamic> json) {
    return Runway(
      designation: json['designation'] ?? '',
      length: json['length'] ?? 0,
      width: json['width'] ?? 0,
      surface: json['surface'] ?? '',
      lighting: json['lighting'] ?? '',
      markings: json['markings'] ?? '',
      approachLights: json['approachLights'] ?? '',
      visualGlideSlope: json['visualGlideSlope'] ?? '',
      displacedThreshold: json['displacedThreshold'] ?? '',
      overrun: json['overrun'] ?? '',
      remarks: json['remarks'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'designation': designation,
      'length': length,
      'width': width,
      'surface': surface,
      'lighting': lighting,
      'markings': markings,
      'approachLights': approachLights,
      'visualGlideSlope': visualGlideSlope,
      'displacedThreshold': displacedThreshold,
      'overrun': overrun,
      'remarks': remarks,
    };
  }
}

class Frequency {
  final String type; // CTAF, Ground, Tower, ATIS, etc.
  final String frequency;
  final String hours;
  final String remarks;

  Frequency({
    required this.type,
    required this.frequency,
    required this.hours,
    required this.remarks,
  });

  factory Frequency.fromJson(Map<String, dynamic> json) {
    return Frequency(
      type: json['type'] ?? '',
      frequency: json['frequency'] ?? '',
      hours: json['hours'] ?? '',
      remarks: json['remarks'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'frequency': frequency,
      'hours': hours,
      'remarks': remarks,
    };
  }
}

class Service {
  final String type; // FBO, Maintenance, Flight Training, etc.
  final String name;
  final String phone;
  final String hours;
  final List<String> capabilities;
  final String remarks;

  Service({
    required this.type,
    required this.name,
    required this.phone,
    required this.hours,
    required this.capabilities,
    required this.remarks,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      hours: json['hours'] ?? '',
      capabilities: List<String>.from(json['capabilities'] ?? []),
      remarks: json['remarks'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'name': name,
      'phone': phone,
      'hours': hours,
      'capabilities': capabilities,
      'remarks': remarks,
    };
  }
} 
