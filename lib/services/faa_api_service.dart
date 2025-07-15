import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pilots_lounge/models/faa_airport_data.dart';
import 'faa_pdf_parser.dart';

class FAAApiService {
  static final FAAApiService _instance = FAAApiService._internal();
  factory FAAApiService() => _instance;
  FAAApiService._internal();

  final FAAPdfParser _pdfParser = FAAPdfParser();
  bool _pdfLoaded = false;
  final bool _usePdfData = false; // Set to false to disable PDF parsing for now

  // FAA API endpoints
  static const String _baseUrl = 'https://external-api.faa.gov';
  static const String _notamUrl = 'https://external-api.faa.gov/notamapi/v1';
  static const String _weatherUrl = 'https://aviationweather.gov/api';

  // Initialize the PDF parser
  Future<void> initializePdfParser() async {
    if (!_pdfLoaded) {
      try {
        await _pdfParser.loadChartSupplement();
        _pdfLoaded = true;
      } catch (e) {
        // ignore: avoid_print
        print('Failed to load PDF, using mock data: $e');
        _pdfLoaded = false; // Mark as failed so we use mock data
      }
    }
  }

  // Get airport information from FAA database
  Future<FAAAirportData?> getAirportInfo(String identifier) async {
    try {
      // For now, skip PDF parsing to avoid freezing
      if (_usePdfData) {
        // First try to get data from the PDF Chart Supplement
        await initializePdfParser();
        
        // Only try PDF if it was loaded successfully
        if (_pdfLoaded) {
          final pdfData = _pdfParser.findAirportData(identifier);
          if (pdfData != null) {
            return pdfData;
          }
        }
      }

      // Use mock data (more reliable and faster)
      return getMockAirportData(identifier);
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching airport info: $e');
      // Fallback to mock data
      return getMockAirportData(identifier);
    }
  }

  // Get NOTAMs for an airport
  Future<List<Map<String, dynamic>>> getNotams(String airportCode) async {
    try {
      final response = await http.get(
        Uri.parse('$_notamUrl/notams?icaoCode=$airportCode'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['notams'] ?? []);
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching NOTAMs: $e');
    }
    return [];
  }

  // Get aviation weather for an airport
  Future<Map<String, dynamic>?> getWeather(String airportCode) async {
    try {
      final response = await http.get(
        Uri.parse('$_weatherUrl/data/metar?ids=$airportCode&format=json'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data.isNotEmpty ? data[0] : null;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching weather: $e');
    }
    return null;
  }

  // Get TAF (Terminal Aerodrome Forecast)
  Future<Map<String, dynamic>?> getTaf(String airportCode) async {
    try {
      final response = await http.get(
        Uri.parse('$_weatherUrl/data/taf?ids=$airportCode&format=json'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data.isNotEmpty ? data[0] : null;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching TAF: $e');
    }
    return null;
  }

  // Get flight restrictions
  Future<List<Map<String, dynamic>>> getFlightRestrictions(String airportCode) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/restrictions?airport=$airportCode'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['restrictions'] ?? []);
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching flight restrictions: $e');
    }
    return [];
  }

  // Mock data for development (since FAA APIs require authentication)
  FAAAirportData getMockAirportData(String identifier) {
    final mockData = {
      'KPHX': FAAAirportData(
        identifier: 'KPHX',
        name: 'Phoenix Sky Harbor International Airport',
        city: 'Phoenix',
        state: 'AZ',
        latitude: 33.4342,
        longitude: -112.0116,
        elevation: 1135,
        facilityType: 'Airport',
        ownership: 'Public',
        runways: [
          Runway(
            designation: '08/26',
            length: 11489,
            width: 150,
            surface: 'Asphalt',
            lighting: 'High Intensity',
            markings: 'Precision',
            approachLights: 'ALSF-2',
            visualGlideSlope: 'PAPI',
            displacedThreshold: '0',
            overrun: 'Yes',
            remarks: 'Primary runway',
          ),
          Runway(
            designation: '07L/25R',
            length: 7800,
            width: 150,
            surface: 'Asphalt',
            lighting: 'High Intensity',
            markings: 'Non-Precision',
            approachLights: 'MALSR',
            visualGlideSlope: 'PAPI',
            displacedThreshold: '0',
            overrun: 'Yes',
            remarks: 'Secondary runway',
          ),
        ],
        frequencies: [
          Frequency(type: 'CTAF', frequency: '118.3', hours: '24', remarks: 'Common Traffic Advisory Frequency'),
          Frequency(type: 'Ground', frequency: '121.9', hours: '24', remarks: 'Ground Control'),
          Frequency(type: 'Tower', frequency: '118.3', hours: '24', remarks: 'Tower Control'),
          Frequency(type: 'ATIS', frequency: '127.55', hours: '24', remarks: 'Automated Terminal Information Service'),
        ],
        services: [
          Service(
            type: 'FBO',
            name: 'Signature Flight Support',
            phone: '(602) 275-1100',
            hours: '24',
            capabilities: ['Fuel', 'Maintenance', 'Catering', 'Ground Transportation'],
            remarks: 'Full service FBO',
          ),
          Service(
            type: 'FBO',
            name: 'Atlantic Aviation',
            phone: '(602) 275-1101',
            hours: '24',
            capabilities: ['Fuel', 'Maintenance', 'Flight Planning'],
            remarks: 'Full service FBO',
          ),
        ],
        fuelTypes: ['100LL', 'Jet A'],
        specialProcedures: [
          'Noise abatement procedures in effect',
          'Right traffic pattern for runway 26',
          'Left traffic pattern for runway 08',
        ],
        hazards: [
          'Wildlife on and in vicinity of airport',
          'Construction equipment on taxiways',
        ],
        patternAltitude: '1500 AGL',
        lighting: 'Pilot controlled lighting available',
        weatherStation: 'ASOS',
        customs: 'Available',
        immigration: 'Available',
        agriculturalInspection: 'Available',
        noiseAbatement: 'Voluntary noise abatement procedures',
        wildlifeHazards: 'Birds and wildlife present',
        remarks: 'Busy airport - monitor approach frequency',
      ),
      'KSDL': FAAAirportData(
        identifier: 'KSDL',
        name: 'Scottsdale Airport',
        city: 'Scottsdale',
        state: 'AZ',
        latitude: 33.6229,
        longitude: -111.9102,
        elevation: 1519,
        facilityType: 'Airport',
        ownership: 'Public',
        runways: [
          Runway(
            designation: '03/21',
            length: 8000,
            width: 100,
            surface: 'Asphalt',
            lighting: 'High Intensity',
            markings: 'Non-Precision',
            approachLights: 'MALSR',
            visualGlideSlope: 'PAPI',
            displacedThreshold: '0',
            overrun: 'Yes',
            remarks: 'Primary runway',
          ),
        ],
        frequencies: [
          Frequency(type: 'CTAF', frequency: '122.8', hours: '24', remarks: 'Common Traffic Advisory Frequency'),
          Frequency(type: 'Ground', frequency: '121.7', hours: '24', remarks: 'Ground Control'),
          Frequency(type: 'Tower', frequency: '122.8', hours: '24', remarks: 'Tower Control'),
        ],
        services: [
          Service(
            type: 'FBO',
            name: 'Scottsdale Air Center',
            phone: '(480) 945-7000',
            hours: '24',
            capabilities: ['Fuel', 'Maintenance', 'Flight Training'],
            remarks: 'Full service FBO',
          ),
        ],
        fuelTypes: ['100LL', 'Jet A'],
        specialProcedures: [
          'Noise sensitive area',
          'Right traffic pattern for runway 21',
          'Left traffic pattern for runway 03',
        ],
        hazards: [
          'Wildlife in vicinity',
          'Residential area nearby',
        ],
        patternAltitude: '1500 AGL',
        lighting: 'Pilot controlled lighting available',
        weatherStation: 'ASOS',
        customs: 'Not available',
        immigration: 'Not available',
        agriculturalInspection: 'Not available',
        noiseAbatement: 'Mandatory noise abatement procedures',
        wildlifeHazards: 'Birds present',
        remarks: 'Luxury aircraft common',
      ),
      'KCHD': FAAAirportData(
        identifier: 'KCHD',
        name: 'Chandler Municipal Airport',
        city: 'Chandler',
        state: 'AZ',
        latitude: 33.2692,
        longitude: -111.8108,
        elevation: 1243,
        facilityType: 'Airport',
        ownership: 'Public',
        runways: [
          Runway(
            designation: '04/22',
            length: 5000,
            width: 75,
            surface: 'Asphalt',
            lighting: 'Medium Intensity',
            markings: 'Non-Precision',
            approachLights: 'None',
            visualGlideSlope: 'PAPI',
            displacedThreshold: '0',
            overrun: 'Yes',
            remarks: 'Primary runway',
          ),
        ],
        frequencies: [
          Frequency(type: 'CTAF', frequency: '122.9', hours: '24', remarks: 'Common Traffic Advisory Frequency'),
          Frequency(type: 'Ground', frequency: '121.8', hours: '24', remarks: 'Ground Control'),
        ],
        services: [
          Service(
            type: 'FBO',
            name: 'Chandler Air Service',
            phone: '(480) 963-4200',
            hours: '24',
            capabilities: ['Fuel', 'Maintenance', 'Flight Training'],
            remarks: 'Full service FBO',
          ),
        ],
        fuelTypes: ['100LL'],
        specialProcedures: [
          'Right traffic pattern for runway 22',
          'Left traffic pattern for runway 04',
        ],
        hazards: [
          'Wildlife in vicinity',
        ],
        patternAltitude: '1500 AGL',
        lighting: 'Pilot controlled lighting available',
        weatherStation: 'ASOS',
        customs: 'Not available',
        immigration: 'Not available',
        agriculturalInspection: 'Not available',
        noiseAbatement: 'Voluntary noise abatement procedures',
        wildlifeHazards: 'Birds present',
        remarks: 'Great for flight training',
      ),
      'KFFZ': FAAAirportData(
        identifier: 'KFFZ',
        name: 'Falcon Field Airport',
        city: 'Mesa',
        state: 'AZ',
        latitude: 33.4608,
        longitude: -111.7283,
        elevation: 1394,
        facilityType: 'Airport',
        ownership: 'Public',
        runways: [
          Runway(
            designation: '04/22',
            length: 5000,
            width: 75,
            surface: 'Asphalt',
            lighting: 'Medium Intensity',
            markings: 'Non-Precision',
            approachLights: 'None',
            visualGlideSlope: 'PAPI',
            displacedThreshold: '0',
            overrun: 'Yes',
            remarks: 'Primary runway',
          ),
        ],
        frequencies: [
          Frequency(type: 'CTAF', frequency: '122.7', hours: '24', remarks: 'Common Traffic Advisory Frequency'),
          Frequency(type: 'Ground', frequency: '121.6', hours: '24', remarks: 'Ground Control'),
        ],
        services: [
          Service(
            type: 'FBO',
            name: 'Falcon Field Aviation',
            phone: '(480) 835-0300',
            hours: '24',
            capabilities: ['Fuel', 'Warbird Maintenance', 'Flight Training'],
            remarks: 'Warbird specialist',
          ),
        ],
        fuelTypes: ['100LL'],
        specialProcedures: [
          'Home to many warbirds',
          'Right traffic pattern for runway 22',
          'Left traffic pattern for runway 04',
        ],
        hazards: [
          'Vintage aircraft operations',
          'Wildlife in vicinity',
        ],
        patternAltitude: '1500 AGL',
        lighting: 'Pilot controlled lighting available',
        weatherStation: 'ASOS',
        customs: 'Not available',
        immigration: 'Not available',
        agriculturalInspection: 'Not available',
        noiseAbatement: 'Voluntary noise abatement procedures',
        wildlifeHazards: 'Birds present',
        remarks: 'Watch for vintage aircraft',
      ),
      'KGEU': FAAAirportData(
        identifier: 'KGEU',
        name: 'Glendale Municipal Airport',
        city: 'Glendale',
        state: 'AZ',
        latitude: 33.5269,
        longitude: -112.2950,
        elevation: 1061,
        facilityType: 'Airport',
        ownership: 'Public',
        runways: [
          Runway(
            designation: '01/19',
            length: 4500,
            width: 75,
            surface: 'Asphalt',
            lighting: 'Medium Intensity',
            markings: 'Non-Precision',
            approachLights: 'None',
            visualGlideSlope: 'PAPI',
            displacedThreshold: '0',
            overrun: 'Yes',
            remarks: 'Primary runway',
          ),
        ],
        frequencies: [
          Frequency(type: 'CTAF', frequency: '122.8', hours: '24', remarks: 'Common Traffic Advisory Frequency'),
        ],
        services: [
          Service(
            type: 'FBO',
            name: 'Glendale Aviation',
            phone: '(623) 435-4000',
            hours: '24',
            capabilities: ['Fuel', 'Aircraft Sales', 'Flight Training'],
            remarks: 'Full service FBO',
          ),
        ],
        fuelTypes: ['100LL'],
        specialProcedures: [
          'Right traffic pattern for runway 19',
          'Left traffic pattern for runway 01',
        ],
        hazards: [
          'Wildlife in vicinity',
        ],
        patternAltitude: '1500 AGL',
        lighting: 'Pilot controlled lighting available',
        weatherStation: 'ASOS',
        customs: 'Not available',
        immigration: 'Not available',
        agriculturalInspection: 'Not available',
        noiseAbatement: 'Voluntary noise abatement procedures',
        wildlifeHazards: 'Birds present',
        remarks: 'Good for training',
      ),
      'KGYR': FAAAirportData(
        identifier: 'KGYR',
        name: 'Phoenix Goodyear Airport',
        city: 'Goodyear',
        state: 'AZ',
        latitude: 33.4228,
        longitude: -112.3759,
        elevation: 968,
        facilityType: 'Airport',
        ownership: 'Public',
        runways: [
          Runway(
            designation: '03/21',
            length: 8500,
            width: 100,
            surface: 'Asphalt',
            lighting: 'High Intensity',
            markings: 'Non-Precision',
            approachLights: 'MALSR',
            visualGlideSlope: 'PAPI',
            displacedThreshold: '0',
            overrun: 'Yes',
            remarks: 'Primary runway',
          ),
        ],
        frequencies: [
          Frequency(type: 'CTAF', frequency: '122.9', hours: '24', remarks: 'Common Traffic Advisory Frequency'),
          Frequency(type: 'Ground', frequency: '121.8', hours: '24', remarks: 'Ground Control'),
        ],
        services: [
          Service(
            type: 'FBO',
            name: 'Goodyear Aviation',
            phone: '(623) 932-2000',
            hours: '24',
            capabilities: ['Fuel', 'Maintenance', 'Flight Training'],
            remarks: 'Full service FBO',
          ),
        ],
        fuelTypes: ['100LL', 'Jet A'],
        specialProcedures: [
          'Right traffic pattern for runway 21',
          'Left traffic pattern for runway 03',
        ],
        hazards: [
          'Wildlife in vicinity',
        ],
        patternAltitude: '1500 AGL',
        lighting: 'Pilot controlled lighting available',
        weatherStation: 'ASOS',
        customs: 'Not available',
        immigration: 'Not available',
        agriculturalInspection: 'Not available',
        noiseAbatement: 'Voluntary noise abatement procedures',
        wildlifeHazards: 'Birds present',
        remarks: 'Less busy than Sky Harbor',
      ),
      'KDVT': FAAAirportData(
        identifier: 'KDVT',
        name: 'Phoenix Deer Valley Airport',
        city: 'Phoenix',
        state: 'AZ',
        latitude: 33.6883,
        longitude: -112.0825,
        elevation: 1478,
        facilityType: 'Airport',
        ownership: 'Public',
        runways: [
          Runway(
            designation: '07L/25R',
            length: 8000,
            width: 100,
            surface: 'Asphalt',
            lighting: 'High Intensity',
            markings: 'Non-Precision',
            approachLights: 'MALSR',
            visualGlideSlope: 'PAPI',
            displacedThreshold: '0',
            overrun: 'Yes',
            remarks: 'Primary runway',
          ),
          Runway(
            designation: '07R/25L',
            length: 8000,
            width: 100,
            surface: 'Asphalt',
            lighting: 'High Intensity',
            markings: 'Non-Precision',
            approachLights: 'MALSR',
            visualGlideSlope: 'PAPI',
            displacedThreshold: '0',
            overrun: 'Yes',
            remarks: 'Secondary runway',
          ),
        ],
        frequencies: [
          Frequency(type: 'CTAF', frequency: '122.8', hours: '24', remarks: 'Common Traffic Advisory Frequency'),
          Frequency(type: 'Ground', frequency: '121.7', hours: '24', remarks: 'Ground Control'),
          Frequency(type: 'Tower', frequency: '122.8', hours: '24', remarks: 'Tower Control'),
        ],
        services: [
          Service(
            type: 'FBO',
            name: 'Deer Valley Aviation',
            phone: '(623) 869-0970',
            hours: '24',
            capabilities: ['Fuel', 'Flight Training', 'Aircraft Sales'],
            remarks: 'Busiest GA airport in US',
          ),
        ],
        fuelTypes: ['100LL', 'Jet A'],
        specialProcedures: [
          'Busiest GA airport in US',
          'Right traffic pattern for runway 25',
          'Left traffic pattern for runway 07',
        ],
        hazards: [
          'High traffic volume',
          'Wildlife in vicinity',
        ],
        patternAltitude: '1500 AGL',
        lighting: 'Pilot controlled lighting available',
        weatherStation: 'ASOS',
        customs: 'Not available',
        immigration: 'Not available',
        agriculturalInspection: 'Not available',
        noiseAbatement: 'Mandatory noise abatement procedures',
        wildlifeHazards: 'Birds present',
        remarks: 'Call ahead for services',
      ),
      'KLUF': FAAAirportData(
        identifier: 'KLUF',
        name: 'Luke Air Force Base',
        city: 'Glendale',
        state: 'AZ',
        latitude: 33.5350,
        longitude: -112.3831,
        elevation: 1085,
        facilityType: 'Airport',
        ownership: 'Military',
        runways: [
          Runway(
            designation: '03/21',
            length: 9000,
            width: 150,
            surface: 'Asphalt',
            lighting: 'High Intensity',
            markings: 'Precision',
            approachLights: 'ALSF-2',
            visualGlideSlope: 'PAPI',
            displacedThreshold: '0',
            overrun: 'Yes',
            remarks: 'Primary runway',
          ),
        ],
        frequencies: [
          Frequency(type: 'CTAF', frequency: '118.3', hours: '24', remarks: 'Common Traffic Advisory Frequency'),
          Frequency(type: 'Ground', frequency: '121.9', hours: '24', remarks: 'Ground Control'),
          Frequency(type: 'Tower', frequency: '118.3', hours: '24', remarks: 'Tower Control'),
        ],
        services: [
          Service(
            type: 'Military',
            name: 'Luke AFB Operations',
            phone: '(623) 856-7000',
            hours: '24',
            capabilities: ['Military Operations', 'F-35 Training'],
            remarks: 'Military base - restricted access',
          ),
        ],
        fuelTypes: ['JP-8'],
        specialProcedures: [
          'Military base - contact for clearance',
          'F-35 training flights',
          'Restricted airspace',
        ],
        hazards: [
          'Military operations',
          'F-35 training flights',
          'Restricted access',
        ],
        patternAltitude: '1500 AGL',
        lighting: 'Pilot controlled lighting available',
        weatherStation: 'ASOS',
        customs: 'Available',
        immigration: 'Available',
        agriculturalInspection: 'Available',
        noiseAbatement: 'Military operations',
        wildlifeHazards: 'Birds present',
        remarks: 'Contact base for clearance',
      ),
      'KP08': FAAAirportData(
        identifier: 'KP08',
        name: 'Coolidge Municipal Airport',
        city: 'Coolidge',
        state: 'AZ',
        latitude: 32.9358,
        longitude: -111.4269,
        elevation: 1574,
        facilityType: 'Airport',
        ownership: 'Public',
        runways: [
          Runway(
            designation: '05/23',
            length: 4000,
            width: 60,
            surface: 'Asphalt',
            lighting: 'Medium Intensity',
            markings: 'Non-Precision',
            approachLights: 'None',
            visualGlideSlope: 'None',
            displacedThreshold: '0',
            overrun: 'Yes',
            remarks: 'Primary runway',
          ),
        ],
        frequencies: [
          Frequency(type: 'CTAF', frequency: '122.9', hours: '24', remarks: 'Common Traffic Advisory Frequency'),
        ],
        services: [
          Service(
            type: 'FBO',
            name: 'Coolidge Aviation',
            phone: '(520) 723-3000',
            hours: '24',
            capabilities: ['Fuel', 'Flight Training'],
            remarks: 'Small airport',
          ),
        ],
        fuelTypes: ['100LL'],
        specialProcedures: [
          'Right traffic pattern for runway 23',
          'Left traffic pattern for runway 05',
        ],
        hazards: [
          'Wildlife in vicinity',
        ],
        patternAltitude: '1500 AGL',
        lighting: 'Pilot controlled lighting available',
        weatherStation: 'ASOS',
        customs: 'Not available',
        immigration: 'Not available',
        agriculturalInspection: 'Not available',
        noiseAbatement: 'Voluntary noise abatement procedures',
        wildlifeHazards: 'Birds present',
        remarks: 'Quiet airspace',
      ),
      'KPRC': FAAAirportData(
        identifier: 'KPRC',
        name: 'Prescott Regional Airport',
        city: 'Prescott',
        state: 'AZ',
        latitude: 34.6494,
        longitude: -112.4197,
        elevation: 5045,
        facilityType: 'Airport',
        ownership: 'Public',
        runways: [
          Runway(
            designation: '03/21',
            length: 7500,
            width: 100,
            surface: 'Asphalt',
            lighting: 'High Intensity',
            markings: 'Non-Precision',
            approachLights: 'MALSR',
            visualGlideSlope: 'PAPI',
            displacedThreshold: '0',
            overrun: 'Yes',
            remarks: 'Primary runway',
          ),
        ],
        frequencies: [
          Frequency(type: 'CTAF', frequency: '122.8', hours: '24', remarks: 'Common Traffic Advisory Frequency'),
          Frequency(type: 'Ground', frequency: '121.7', hours: '24', remarks: 'Ground Control'),
        ],
        services: [
          Service(
            type: 'FBO',
            name: 'Prescott Aviation',
            phone: '(928) 771-5000',
            hours: '24',
            capabilities: ['Fuel', 'Flight Training', 'Aircraft Maintenance'],
            remarks: 'Mountain flying',
          ),
        ],
        fuelTypes: ['100LL', 'Jet A'],
        specialProcedures: [
          'Mountain flying considerations',
          'Right traffic pattern for runway 21',
          'Left traffic pattern for runway 03',
        ],
        hazards: [
          'Mountain weather',
          'Wildlife in vicinity',
        ],
        patternAltitude: '1500 AGL',
        lighting: 'Pilot controlled lighting available',
        weatherStation: 'ASOS',
        customs: 'Not available',
        immigration: 'Not available',
        agriculturalInspection: 'Not available',
        noiseAbatement: 'Voluntary noise abatement procedures',
        wildlifeHazards: 'Birds present',
        remarks: 'Cooler weather',
      ),
      'KFLG': FAAAirportData(
        identifier: 'KFLG',
        name: 'Flagstaff Pulliam Airport',
        city: 'Flagstaff',
        state: 'AZ',
        latitude: 35.1403,
        longitude: -111.6694,
        elevation: 7014,
        facilityType: 'Airport',
        ownership: 'Public',
        runways: [
          Runway(
            designation: '03/21',
            length: 8000,
            width: 100,
            surface: 'Asphalt',
            lighting: 'High Intensity',
            markings: 'Non-Precision',
            approachLights: 'MALSR',
            visualGlideSlope: 'PAPI',
            displacedThreshold: '0',
            overrun: 'Yes',
            remarks: 'Primary runway',
          ),
        ],
        frequencies: [
          Frequency(type: 'CTAF', frequency: '122.8', hours: '24', remarks: 'Common Traffic Advisory Frequency'),
          Frequency(type: 'Ground', frequency: '121.7', hours: '24', remarks: 'Ground Control'),
        ],
        services: [
          Service(
            type: 'FBO',
            name: 'Flagstaff Aviation',
            phone: '(928) 556-1234',
            hours: '24',
            capabilities: ['Fuel', 'Flight Training', 'Aircraft Maintenance'],
            remarks: 'High altitude airport',
          ),
        ],
        fuelTypes: ['100LL', 'Jet A'],
        specialProcedures: [
          'High altitude airport',
          'Mountain flying considerations',
          'Right traffic pattern for runway 21',
          'Left traffic pattern for runway 03',
        ],
        hazards: [
          'High altitude operations',
          'Mountain weather',
          'Wildlife in vicinity',
        ],
        patternAltitude: '1500 AGL',
        lighting: 'Pilot controlled lighting available',
        weatherStation: 'ASOS',
        customs: 'Not available',
        immigration: 'Not available',
        agriculturalInspection: 'Not available',
        noiseAbatement: 'Voluntary noise abatement procedures',
        wildlifeHazards: 'Birds present',
        remarks: 'Mountain flying',
      ),
      'KTUS': FAAAirportData(
        identifier: 'KTUS',
        name: 'Tucson International Airport',
        city: 'Tucson',
        state: 'AZ',
        latitude: 32.1161,
        longitude: -110.9410,
        elevation: 2643,
        facilityType: 'Airport',
        ownership: 'Public',
        runways: [
          Runway(
            designation: '11L/29R',
            length: 10996,
            width: 150,
            surface: 'Asphalt',
            lighting: 'High Intensity',
            markings: 'Precision',
            approachLights: 'ALSF-2',
            visualGlideSlope: 'PAPI',
            displacedThreshold: '0',
            overrun: 'Yes',
            remarks: 'Primary runway',
          ),
          Runway(
            designation: '11R/29L',
            length: 8200,
            width: 150,
            surface: 'Asphalt',
            lighting: 'High Intensity',
            markings: 'Non-Precision',
            approachLights: 'MALSR',
            visualGlideSlope: 'PAPI',
            displacedThreshold: '0',
            overrun: 'Yes',
            remarks: 'Secondary runway',
          ),
        ],
        frequencies: [
          Frequency(type: 'CTAF', frequency: '118.3', hours: '24', remarks: 'Common Traffic Advisory Frequency'),
          Frequency(type: 'Ground', frequency: '121.9', hours: '24', remarks: 'Ground Control'),
          Frequency(type: 'Tower', frequency: '118.3', hours: '24', remarks: 'Tower Control'),
          Frequency(type: 'ATIS', frequency: '127.55', hours: '24', remarks: 'Automated Terminal Information Service'),
        ],
        services: [
          Service(
            type: 'FBO',
            name: 'Tucson Aviation',
            phone: '(520) 573-8000',
            hours: '24',
            capabilities: ['Fuel', 'Flight Training', 'Aircraft Maintenance', 'Charter Services'],
            remarks: 'Full service FBO',
          ),
        ],
        fuelTypes: ['100LL', 'Jet A'],
        specialProcedures: [
          'Desert flying considerations',
          'Right traffic pattern for runway 29',
          'Left traffic pattern for runway 11',
        ],
        hazards: [
          'Desert weather',
          'Wildlife in vicinity',
        ],
        patternAltitude: '1500 AGL',
        lighting: 'Pilot controlled lighting available',
        weatherStation: 'ASOS',
        customs: 'Available',
        immigration: 'Available',
        agriculturalInspection: 'Available',
        noiseAbatement: 'Voluntary noise abatement procedures',
        wildlifeHazards: 'Birds present',
        remarks: 'Desert flying',
      ),
    };

    return mockData[identifier] ?? FAAAirportData(
      identifier: identifier,
      name: 'Unknown Airport',
      city: 'Unknown',
      state: 'Unknown',
      latitude: 0.0,
      longitude: 0.0,
      elevation: 0,
      facilityType: 'Airport',
      ownership: 'Unknown',
      runways: [],
      frequencies: [],
      services: [],
      fuelTypes: [],
      specialProcedures: [],
      hazards: [],
      patternAltitude: '',
      lighting: '',
      weatherStation: '',
      customs: '',
      immigration: '',
      agriculturalInspection: '',
      noiseAbatement: '',
      wildlifeHazards: '',
      remarks: 'No data available',
    );
  }
} 
