import 'package:flutter/material.dart';
import 'package:pilots_lounge/models/faa_airport_data.dart';
import 'package:pilots_lounge/services/faa_api_service.dart';
import 'package:pilots_lounge/widgets/app_scaffold.dart';

class FAAChartSupplementPage extends StatefulWidget {
  final String airportIdentifier;
  
  const FAAChartSupplementPage({required this.airportIdentifier, super.key});

  @override
  State<FAAChartSupplementPage> createState() => _FAAChartSupplementPageState();
}

class _FAAChartSupplementPageState extends State<FAAChartSupplementPage> {
  FAAAirportData? _airportData;
  bool _loading = true;
  List<Map<String, dynamic>> _notams = [];
  Map<String, dynamic>? _weather;
  Map<String, dynamic>? _taf;

  @override
  void initState() {
    super.initState();
    _loadAirportData();
  }

  Future<void> _loadAirportData() async {
    setState(() => _loading = true);
    
    try {
      // Load FAA data from PDF Chart Supplement with timeout
      final faaData = await FAAApiService().getAirportInfo(widget.airportIdentifier)
          .timeout(const Duration(seconds: 10));
      
      // Load real-time data with timeout
      final notams = await FAAApiService().getNotams(widget.airportIdentifier)
          .timeout(const Duration(seconds: 5));
      final weather = await FAAApiService().getWeather(widget.airportIdentifier)
          .timeout(const Duration(seconds: 5));
      final taf = await FAAApiService().getTaf(widget.airportIdentifier)
          .timeout(const Duration(seconds: 5));
      
      if (mounted) {
        setState(() {
          _airportData = faaData;
          _notams = notams;
          _weather = weather;
          _taf = taf;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading airport data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 7,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _airportData == null
              ? const Center(child: Text('Airport data not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      _buildHeader(),
                      const SizedBox(height: 20),
                      
                      // Weather Information
                      _buildWeatherSection(),
                      const SizedBox(height: 20),
                      
                      // Runways
                      _buildRunwaysSection(),
                      const SizedBox(height: 20),
                      
                      // Frequencies
                      _buildFrequenciesSection(),
                      const SizedBox(height: 20),
                      
                      // Services
                      _buildServicesSection(),
                      const SizedBox(height: 20),
                      
                      // NOTAMs
                      _buildNotamsSection(),
                      const SizedBox(height: 20),
                      
                      // Special Procedures
                      _buildSpecialProceduresSection(),
                      const SizedBox(height: 20),
                      
                      // Hazards
                      _buildHazardsSection(),
                      const SizedBox(height: 20),
                      
                      // Remarks
                      _buildRemarksSection(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _airportData!.identifier,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              _airportData!.name,
              style: const TextStyle(fontSize: 18),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${_airportData!.city}, ${_airportData!.state}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                Text('Elevation: ${_airportData!.elevation} ft MSL', maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('Type: ${_airportData!.facilityType}', maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('Ownership: ${_airportData!.ownership}', maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'WEATHER INFORMATION',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Weather Station: ${_airportData!.weatherStation}'),
            if (_weather != null) ...[
              const SizedBox(height: 8),
              Text('METAR: ${_weather!['raw_text'] ?? 'Not available'}'),
            ],
            if (_taf != null) ...[
              const SizedBox(height: 8),
              Text('TAF: ${_taf!['raw_text'] ?? 'Not available'}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRunwaysSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RUNWAYS',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._airportData!.runways.map((runway) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Runway ${runway.designation}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Length: ${runway.length} ft x ${runway.width} ft'),
                  Text('Surface: ${runway.surface}'),
                  Text('Lighting: ${runway.lighting}'),
                  Text('Markings: ${runway.markings}'),
                  if (runway.approachLights.isNotEmpty)
                    Text('Approach Lights: ${runway.approachLights}'),
                  if (runway.visualGlideSlope.isNotEmpty)
                    Text('Visual Glide Slope: ${runway.visualGlideSlope}'),
                  if (runway.remarks.isNotEmpty)
                    Text('Remarks: ${runway.remarks}'),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequenciesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'COMMUNICATIONS',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._airportData!.frequencies.map((freq) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 70,
                        child: Text(freq.type, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      SizedBox(
                        width: 70,
                        child: Text(freq.frequency, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      Flexible(child: Text(freq.hours, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  if (freq.remarks.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(freq.remarks, style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SERVICES',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Fuel Types: ${_airportData!.fuelTypes.join(", ")}', maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            ..._airportData!.services.map((service) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${service.type}: ${service.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('Phone: ${service.phone}', maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('Hours: ${service.hours}', maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (service.capabilities.isNotEmpty)
                    Text(
                      'Capabilities: ${service.capabilities.join(", ")}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (service.remarks.isNotEmpty)
                    Text(
                      'Remarks: ${service.remarks}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildNotamsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'NOTAMS',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_notams.isEmpty)
              const Text('No active NOTAMs')
            else
              ..._notams.map((notam) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NOTAM ${notam['number'] ?? 'Unknown'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(notam['message'] ?? 'No message available'),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialProceduresSection() {
    if (_airportData!.specialProcedures.isEmpty) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SPECIAL PROCEDURES',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._airportData!.specialProcedures.map((procedure) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $procedure'),
              ),
            ),
            if (_airportData!.patternAltitude.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Pattern Altitude: ${_airportData!.patternAltitude}'),
            ],
            if (_airportData!.noiseAbatement.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Noise Abatement: ${_airportData!.noiseAbatement}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHazardsSection() {
    if (_airportData!.hazards.isEmpty) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'HAZARDS',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 8),
            ..._airportData!.hazards.map((hazard) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $hazard', style: const TextStyle(color: Colors.red)),
              ),
            ),
            if (_airportData!.wildlifeHazards.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Wildlife: ${_airportData!.wildlifeHazards}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRemarksSection() {
    if (_airportData!.remarks.isEmpty) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'REMARKS',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_airportData!.remarks),
          ],
        ),
      ),
    );
  }
} 
