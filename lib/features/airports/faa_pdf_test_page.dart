import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';
import 'package:pilots_lounge/models/faa_airport_data.dart';
import 'package:pilots_lounge/services/faa_pdf_parser.dart';
import 'package:pilots_lounge/services/faa_api_service.dart';
import 'package:pilots_lounge/widgets/app_scaffold.dart';

class FAAPdfTestPage extends StatefulWidget {
  const FAAPdfTestPage({super.key});

  @override
  State<FAAPdfTestPage> createState() => _FAAPdfTestPageState();
}

class _FAAPdfTestPageState extends State<FAAPdfTestPage> {
  bool _loading = false;
  String _status = 'Ready to test PDF parsing';
  List<String> _airportIdentifiers = [];
  FAAAirportData? _testAirportData;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 7,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'FAA Chart Supplement PDF Test',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    // Status
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status: $_status',
                              style: const TextStyle(fontSize: 16),
                            ),
                            if (_loading) ...[
                              const SizedBox(height: 16),
                              const LinearProgressIndicator(),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Test buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _loading ? null : _testPdfLoading,
                            child: const Text('Load PDF'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _loading ? null : _testAirportExtraction,
                            child: const Text('Extract Airports'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Airport identifiers found
                    if (_airportIdentifiers.isNotEmpty) ...[
                      const Text(
                        'Airport Identifiers Found:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          itemCount: _airportIdentifiers.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                _airportIdentifiers[index],
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => _testSpecificAirport(_airportIdentifiers[index]),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    // Test airport data
                    if (_testAirportData != null) ...[
                      const Text(
                        'Test Airport Data:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 300),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Identifier: ${_testAirportData!.identifier}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Name: ${_testAirportData!.name}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text('City: ${_testAirportData!.city}'),
                                const SizedBox(height: 4),
                                Text('State: ${_testAirportData!.state}'),
                                const SizedBox(height: 4),
                                Text('Elevation: ${_testAirportData!.elevation} ft MSL'),
                                const SizedBox(height: 4),
                                Text('Runways: ${_testAirportData!.runways.length}'),
                                const SizedBox(height: 4),
                                Text('Frequencies: ${_testAirportData!.frequencies.length}'),
                                const SizedBox(height: 4),
                                Text('Services: ${_testAirportData!.services.length}'),
                                const SizedBox(height: 4),
                                Wrap(
                                  children: [
                                    const Text('Fuel Types: '),
                                    ..._testAirportData!.fuelTypes.map((fuel) => 
                                      Chip(
                                        label: Text(fuel),
                                        backgroundColor: Colors.blue.shade100,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      )
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testPdfLoading() async {
    setState(() {
      _loading = true;
      _status = 'Loading PDF...';
    });

    try {
      final pdfParser = FAAPdfParser();
      await pdfParser.loadChartSupplement().timeout(const Duration(seconds: 30));
      setState(() {
        _loading = false;
        _status = 'PDF loaded successfully!';
      });
    } catch (e) {
      if (e.toString().contains(FAAPdfParser.webNotSupportedMsg)) {
        setState(() {
          _loading = false;
        });
        if (context.mounted) {
          final useMock = await showDialog<bool>(
            // ignore: use_build_context_synchronously
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Web Not Supported'),
              content: const Text('PDF parsing is not supported on web. Would you like to use mock data instead?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Use Mock Data'),
                ),
              ],
            ),
          );
          if (useMock == true) {
            setState(() {
              _status = 'Loaded mock data (web fallback)';
              _airportIdentifiers = ['KPHX', 'KSDL', 'KCHD'];
              _testAirportData = FAAAirportData(
                identifier: 'KPHX',
                name: 'Phoenix Sky Harbor International',
                city: 'Phoenix',
                state: 'AZ',
                latitude: 33.4342,
                longitude: -112.0116,
                elevation: 1135,
                facilityType: 'Airport',
                ownership: 'Public',
                runways: [],
                frequencies: [],
                services: [],
                fuelTypes: ['100LL', 'Jet A'],
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
                remarks: '',
              );
            });
          } else {
            setState(() {
              _status = 'PDF parsing cancelled (web)';
            });
          }
        }
      } else {
        setState(() {
          _loading = false;
          _status = 'Error loading PDF: $e';
        });
      }
    }
  }

  Future<void> _testAirportExtraction() async {
    setState(() {
      _loading = true;
      _status = 'Extracting airport identifiers...';
    });

    try {
      final pdfParser = FAAPdfParser();
      await pdfParser.loadChartSupplement().timeout(const Duration(seconds: 30));
      final identifiers = pdfParser.getAllAirportIdentifiers();
      
      setState(() {
        _loading = false;
        _status = 'Found ${identifiers.length} airport identifiers';
        _airportIdentifiers = identifiers;
      });
    } catch (e) {
      if (e.toString().contains(FAAPdfParser.webNotSupportedMsg)) {
        setState(() {
          _loading = false;
        });
        if (context.mounted) {
          final useMock = await showDialog<bool>(
            // ignore: use_build_context_synchronously
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Web Not Supported'),
              content: const Text('PDF parsing is not supported on web. Would you like to use mock data instead?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Use Mock Data'),
                ),
              ],
            ),
          );
          if (useMock == true) {
            setState(() {
              _status = 'Found 3 airport identifiers (mock data)';
              _airportIdentifiers = ['KPHX', 'KSDL', 'KCHD', 'KFFZ', 'KGEU', 'KGYR', 'KDVT', 'KLUF', 'KP08'];
            });
          } else {
            setState(() {
              _status = 'Airport extraction cancelled (web)';
            });
          }
        }
      } else {
        setState(() {
          _loading = false;
          _status = 'Error extracting airports: $e';
        });
      }
    }
  }

  Future<void> _testSpecificAirport(String identifier) async {
    setState(() {
      _loading = true;
      _status = 'Loading data for $identifier...';
    });

    try {
      final airportData = await FAAApiService().getAirportInfo(identifier)
          .timeout(const Duration(seconds: 10));
      
      setState(() {
        _loading = false;
        _status = 'Loaded data for $identifier';
        _testAirportData = airportData;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _status = 'Error loading $identifier: $e';
      });
    }
  }
} 
