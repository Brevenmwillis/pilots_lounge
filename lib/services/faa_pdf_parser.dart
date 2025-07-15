// ignore: unused_import
import 'dart:io';
// ignore: unnecessary_import
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:pilots_lounge/models/faa_airport_data.dart';
// ignore: unused_import
import 'package:pilots_lounge/models/review.dart';
import 'package:flutter/foundation.dart';

class FAAPdfParser {
  static final FAAPdfParser _instance = FAAPdfParser._internal();
  factory FAAPdfParser() => _instance;
  FAAPdfParser._internal();

  PdfDocument? _document;
  // ignore: prefer_final_fields
  List<String> _textContent = [];

  /// Custom exception for web fallback
  static const String webNotSupportedMsg = 'PDF parsing is not supported on web.';

  /// Load the FAA Chart Supplement PDF
  Future<void> loadChartSupplement() async {
    if (kIsWeb) {
      // On web, throw to trigger fallback
      throw Exception(webNotSupportedMsg);
    }
    try {
      // Use an isolate for heavy PDF parsing
      final List<String> textContent = await compute(_loadAndExtractTextInIsolate, null);
      _textContent = textContent;
      // ignore: avoid_print
      print('FAA Chart Supplement loaded successfully (isolate)');
    } catch (e) {
      // ignore: avoid_print
      print('Error loading FAA Chart Supplement: $e');
      rethrow; // Re-throw to handle in UI
    }
  }

  /// Isolate entry point for PDF loading and text extraction
  static Future<List<String>> _loadAndExtractTextInIsolate(dynamic _) async {
    final ByteData data = await rootBundle.load('assets/faa_documents/CS_SW_20250220.pdf');
    final Uint8List bytes = data.buffer.asUint8List();
    final PdfDocument document = PdfDocument(inputBytes: bytes);
    final List<String> textContent = [];
    final int maxPages = document.pages.count > 10 ? 10 : document.pages.count;
    for (int i = 0; i < maxPages; i++) {
      try {
        final PdfTextExtractor extractor = PdfTextExtractor(document);
        final String pageText = extractor.extractText(startPageIndex: i);
        textContent.add(pageText);
      } catch (e) {
        textContent.add('');
      }
    }
    document.dispose();
    return textContent;
  }

  /// Extract text content from limited pages for performance
  // ignore: unused_element
  Future<void> _extractTextContentLimited() async {
    if (_document == null) return;

    _textContent.clear();
    
    // Only process first 10 pages to avoid freezing
    final int maxPages = _document!.pages.count > 10 ? 10 : _document!.pages.count;
    
    for (int i = 0; i < maxPages; i++) {
      try {
        final PdfTextExtractor extractor = PdfTextExtractor(_document!);
        final String pageText = extractor.extractText(startPageIndex: i);
        _textContent.add(pageText);
      } catch (e) {
        // ignore: avoid_print
        print('Error extracting text from page $i: $e');
        _textContent.add(''); // Add empty string to maintain index
      }
    }
  }

  /// Extract text content from all pages (original method) - kept for future use
  // ignore: unused_element
  Future<void> _extractTextContent() async {
    if (_document == null) return;

    _textContent.clear();
    
    for (int i = 0; i < _document!.pages.count; i++) {
      final PdfTextExtractor extractor = PdfTextExtractor(_document!);
      final String pageText = extractor.extractText(startPageIndex: i);
      _textContent.add(pageText);
    }
  }

  /// Get all available airport identifiers from the PDF
  List<String> getAllAirportIdentifiers() {
    final List<String> identifiers = [];
    final RegExp identifierPattern = RegExp(r'\b[A-Z]{3,4}\b');
    
    for (final String pageText in _textContent) {
      final Iterable<Match> matches = identifierPattern.allMatches(pageText);
      for (final Match match in matches) {
        final String identifier = match.group(0) ?? '';
        if (identifier.length >= 3 && identifier.length <= 4 && !identifiers.contains(identifier)) {
          identifiers.add(identifier);
        }
      }
    }
    
    return identifiers;
  }

  /// Search for airport data by identifier
  FAAAirportData? findAirportData(String identifier) {
    if (_textContent.isEmpty) return null;

    // Search through all pages for the airport identifier
    for (int pageIndex = 0; pageIndex < _textContent.length; pageIndex++) {
      final String pageText = _textContent[pageIndex];
      
      // Look for the airport identifier pattern
      final RegExp airportPattern = RegExp(
        r'$identifier\s*\n(.*?)(?=\n[A-Z]{3,4}\s|$)',
        dotAll: true,
        caseSensitive: false,
      );
      
      final Match? match = airportPattern.firstMatch(pageText);
      if (match != null) {
        return _parseAirportFromText(identifier, match.group(1) ?? '');
      }
    }
    
    return null;
  }

  /// Parse airport data from extracted text
  FAAAirportData _parseAirportFromText(String identifier, String text) {
    // Extract basic information
    final String name = _extractAirportName(text);
    final String city = _extractCity(text);
    final String state = _extractState(text);
    final int elevation = _extractElevation(text);
    final List<Runway> runways = _extractRunways(text);
    final List<Frequency> frequencies = _extractFrequencies(text);
    final List<Service> services = _extractServices(text);
    final List<String> fuelTypes = _extractFuelTypes(text);
    final List<String> specialProcedures = _extractSpecialProcedures(text);
    final List<String> hazards = _extractHazards(text);
    final String patternAltitude = _extractPatternAltitude(text);
    final String lighting = _extractLighting(text);
    final String weatherStation = _extractWeatherStation(text);
    final String customs = _extractCustoms(text);
    final String immigration = _extractImmigration(text);
    final String agriculturalInspection = _extractAgriculturalInspection(text);
    final String noiseAbatement = _extractNoiseAbatement(text);
    final String wildlifeHazards = _extractWildlifeHazards(text);
    final String remarks = _extractRemarks(text);

    return FAAAirportData(
      identifier: identifier,
      name: name,
      city: city,
      state: state,
      latitude: 0.0, // Will be extracted from coordinates if available
      longitude: 0.0, // Will be extracted from coordinates if available
      elevation: elevation,
      facilityType: 'Airport',
      ownership: 'Public',
      runways: runways,
      frequencies: frequencies,
      services: services,
      fuelTypes: fuelTypes,
      specialProcedures: specialProcedures,
      hazards: hazards,
      patternAltitude: patternAltitude,
      lighting: lighting,
      weatherStation: weatherStation,
      customs: customs,
      immigration: immigration,
      agriculturalInspection: agriculturalInspection,
      noiseAbatement: noiseAbatement,
      wildlifeHazards: wildlifeHazards,
      remarks: remarks,
    );
  }

  /// Extract airport name from text
  String _extractAirportName(String text) {
    final RegExp namePattern = RegExp(r'([A-Z][A-Z\s]+(?:AIRPORT|FIELD|BASE|MUNICIPAL))', caseSensitive: false);
    final Match? match = namePattern.firstMatch(text);
    return match?.group(1)?.trim() ?? 'Unknown Airport';
  }

  /// Extract city from text
  String _extractCity(String text) {
    final RegExp cityPattern = RegExp(r'([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*),\s*[A-Z]{2}');
    final Match? match = cityPattern.firstMatch(text);
    if (match != null) {
      final String cityState = match.group(1) ?? '';
      return cityState.split(',')[0].trim();
    }
    return 'Unknown';
  }

  /// Extract state from text
  String _extractState(String text) {
    final RegExp statePattern = RegExp(r'([A-Z]{2})\s*\n');
    final Match? match = statePattern.firstMatch(text);
    return match?.group(1) ?? 'Unknown';
  }

  /// Extract elevation from text
  int _extractElevation(String text) {
    final RegExp elevationPattern = RegExp(r'(\d+)\s*ft\s*MSL', caseSensitive: false);
    final Match? match = elevationPattern.firstMatch(text);
    return int.tryParse(match?.group(1) ?? '0') ?? 0;
  }

  /// Extract runway information from text
  List<Runway> _extractRunways(String text) {
    final List<Runway> runways = [];
    final RegExp runwayPattern = RegExp(
      r'RWY\s+(\d{1,2}[LRC]?/\d{1,2}[LRC]?)\s+(\d+)\s*x\s*(\d+)\s*([A-Z\s]+)',
      caseSensitive: false,
    );
    
    final Iterable<Match> matches = runwayPattern.allMatches(text);
    for (final Match match in matches) {
      runways.add(Runway(
        designation: match.group(1) ?? '',
        length: int.tryParse(match.group(2) ?? '0') ?? 0,
        width: int.tryParse(match.group(3) ?? '0') ?? 0,
        surface: match.group(4)?.trim() ?? 'Unknown',
        lighting: _extractRunwayLighting(text, match.group(1) ?? ''),
        markings: _extractRunwayMarkings(text, match.group(1) ?? ''),
        approachLights: _extractApproachLights(text, match.group(1) ?? ''),
        visualGlideSlope: _extractVisualGlideSlope(text, match.group(1) ?? ''),
        displacedThreshold: '0',
        overrun: 'Yes',
        remarks: '',
      ));
    }
    
    return runways;
  }

  /// Extract frequencies from text
  List<Frequency> _extractFrequencies(String text) {
    final List<Frequency> frequencies = [];
    final RegExp freqPattern = RegExp(
      r'(CTAF|GROUND|TOWER|ATIS|APPROACH|DEPARTURE)\s+(\d+\.\d+)\s+(\d{2}:\d{2}-\d{2}:\d{2}|24)',
      caseSensitive: false,
    );
    
    final Iterable<Match> matches = freqPattern.allMatches(text);
    for (final Match match in matches) {
      frequencies.add(Frequency(
        type: match.group(1)?.toUpperCase() ?? '',
        frequency: match.group(2) ?? '',
        hours: match.group(3) ?? '24',
        remarks: '',
      ));
    }
    
    return frequencies;
  }

  /// Extract services from text
  List<Service> _extractServices(String text) {
    final List<Service> services = [];
    final RegExp servicePattern = RegExp(
      r'(FBO|MAINTENANCE|FLIGHT\s+TRAINING)\s+([A-Z\s]+)\s+\((\d{3})\s+(\d{3})-(\d{4})\)',
      caseSensitive: false,
    );
    
    final Iterable<Match> matches = servicePattern.allMatches(text);
    for (final Match match in matches) {
      services.add(Service(
        type: match.group(1)?.toUpperCase() ?? '',
        name: match.group(2)?.trim() ?? '',
        phone: '(${match.group(3)}) ${match.group(4)}-${match.group(5)}',
        hours: '24',
        capabilities: _extractServiceCapabilities(text, match.group(2) ?? ''),
        remarks: '',
      ));
    }
    
    return services;
  }

  /// Extract fuel types from text
  List<String> _extractFuelTypes(String text) {
    final List<String> fuelTypes = [];
    if (text.toUpperCase().contains('100LL')) fuelTypes.add('100LL');
    if (text.toUpperCase().contains('JET A')) fuelTypes.add('Jet A');
    if (text.toUpperCase().contains('JP-8')) fuelTypes.add('JP-8');
    return fuelTypes;
  }

  /// Extract special procedures from text
  List<String> _extractSpecialProcedures(String text) {
    final List<String> procedures = [];
    final RegExp procedurePattern = RegExp(r'•\s*([^•\n]+)', caseSensitive: false);
    final Iterable<Match> matches = procedurePattern.allMatches(text);
    
    for (final Match match in matches) {
      final String procedure = match.group(1)?.trim() ?? '';
      if (procedure.isNotEmpty) {
        procedures.add(procedure);
      }
    }
    
    return procedures;
  }

  /// Extract hazards from text
  List<String> _extractHazards(String text) {
    final List<String> hazards = [];
    final RegExp hazardPattern = RegExp(r'HAZARD[:\s]+([^•\n]+)', caseSensitive: false);
    final Iterable<Match> matches = hazardPattern.allMatches(text);
    
    for (final Match match in matches) {
      final String hazard = match.group(1)?.trim() ?? '';
      if (hazard.isNotEmpty) {
        hazards.add(hazard);
      }
    }
    
    return hazards;
  }

  /// Extract pattern altitude from text
  String _extractPatternAltitude(String text) {
    final RegExp patternPattern = RegExp(r'(\d+)\s*AGL', caseSensitive: false);
    final Match? match = patternPattern.firstMatch(text);
    return match?.group(1) != null ? '${match!.group(1)} AGL' : '';
  }

  /// Extract lighting information from text
  String _extractLighting(String text) {
    if (text.toUpperCase().contains('PCL')) return 'Pilot controlled lighting available';
    if (text.toUpperCase().contains('LIGHTING')) return 'Lighting available';
    return '';
  }

  /// Extract weather station information from text
  String _extractWeatherStation(String text) {
    if (text.toUpperCase().contains('ASOS')) return 'ASOS';
    if (text.toUpperCase().contains('AWOS')) return 'AWOS';
    return '';
  }

  /// Extract customs information from text
  String _extractCustoms(String text) {
    if (text.toUpperCase().contains('CUSTOMS')) return 'Available';
    return 'Not available';
  }

  /// Extract immigration information from text
  String _extractImmigration(String text) {
    if (text.toUpperCase().contains('IMMIGRATION')) return 'Available';
    return 'Not available';
  }

  /// Extract agricultural inspection information from text
  String _extractAgriculturalInspection(String text) {
    if (text.toUpperCase().contains('AGRICULTURAL')) return 'Available';
    return 'Not available';
  }

  /// Extract noise abatement information from text
  String _extractNoiseAbatement(String text) {
    if (text.toUpperCase().contains('NOISE')) return 'Noise abatement procedures in effect';
    return '';
  }

  /// Extract wildlife hazards from text
  String _extractWildlifeHazards(String text) {
    if (text.toUpperCase().contains('WILDLIFE') || text.toUpperCase().contains('BIRDS')) {
      return 'Wildlife present';
    }
    return '';
  }

  /// Extract remarks from text
  String _extractRemarks(String text) {
    final RegExp remarksPattern = RegExp(r'REMARKS[:\s]+([^•\n]+)', caseSensitive: false);
    final Match? match = remarksPattern.firstMatch(text);
    return match?.group(1)?.trim() ?? '';
  }

  /// Helper methods for runway information extraction
  String _extractRunwayLighting(String text, String runway) {
    if (text.toUpperCase().contains('HIGH INTENSITY')) return 'High Intensity';
    if (text.toUpperCase().contains('MEDIUM INTENSITY')) return 'Medium Intensity';
    if (text.toUpperCase().contains('LOW INTENSITY')) return 'Low Intensity';
    return '';
  }

  String _extractRunwayMarkings(String text, String runway) {
    if (text.toUpperCase().contains('PRECISION')) return 'Precision';
    if (text.toUpperCase().contains('NON-PRECISION')) return 'Non-Precision';
    return '';
  }

  String _extractApproachLights(String text, String runway) {
    if (text.toUpperCase().contains('ALSF-2')) return 'ALSF-2';
    if (text.toUpperCase().contains('MALSR')) return 'MALSR';
    return '';
  }

  String _extractVisualGlideSlope(String text, String runway) {
    if (text.toUpperCase().contains('PAPI')) return 'PAPI';
    if (text.toUpperCase().contains('VASI')) return 'VASI';
    return '';
  }

  List<String> _extractServiceCapabilities(String text, String serviceName) {
    final List<String> capabilities = [];
    if (text.toUpperCase().contains('FUEL')) capabilities.add('Fuel');
    if (text.toUpperCase().contains('MAINTENANCE')) capabilities.add('Maintenance');
    if (text.toUpperCase().contains('FLIGHT TRAINING')) capabilities.add('Flight Training');
    if (text.toUpperCase().contains('CHARTER')) capabilities.add('Charter Services');
    return capabilities;
  }

  /// Dispose of the PDF document
  void dispose() {
    _document?.dispose();
    _document = null;
    _textContent.clear();
  }
} 
