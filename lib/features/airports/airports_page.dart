import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pilots_lounge/models/airport.dart';
import 'package:pilots_lounge/services/map_icons.dart';
import 'package:pilots_lounge/services/placeholder_images.dart';
import 'package:pilots_lounge/widgets/app_scaffold.dart';
import 'faa_chart_supplement_page.dart';
import 'faa_pdf_test_page.dart';
import 'package:pilots_lounge/services/firestore/data_service.dart';
import 'package:pilots_lounge/widgets/loading_overlay.dart';
import 'package:pilots_lounge/widgets/error_widgets.dart';

class AirportsPage extends StatefulWidget {
  const AirportsPage({super.key});

  @override
  State<AirportsPage> createState() => _AirportsPageState();
}

class _AirportsPageState extends State<AirportsPage> {
  // ignore: unused_field
  GoogleMapController? _mapController;
  final DataService _dataService = DataService();
  List<Airport> _airports = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAirports();
  }

  Future<void> _loadAirports() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final airports = await _dataService.getAirports();
      setState(() {
        _airports = airports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load airports: $e';
        _isLoading = false;
      });
    }
  }

  Set<Marker> get _markers => _airports.map((a) {
        return Marker(
          markerId: MarkerId(a.id),
          position: LatLng(a.lat, a.lng),
          icon: MapIcons.getAirportIcon(),
          infoWindow: InfoWindow(
            title: '${a.code} - ${a.name}',
            snippet: 'Rating: ${a.rating}',
          ),
          onTap: () => _showAirportDetails(a),
        );
      }).toSet();

  void _showAirportDetails(Airport airport) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxHeight: 600, maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: PlaceholderImages.getAirportPlaceholder(),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${airport.code} - ${airport.name}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Location: ${airport.location}',
                        style: const TextStyle(fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${airport.rating} (${airport.reviews.length} reviews)',
                              style: const TextStyle(fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Restaurants:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...airport.restaurants.map((restaurant) => 
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '• $restaurant',
                            style: const TextStyle(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Services:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...airport.services.map((service) => 
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '• $service',
                            style: const TextStyle(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            airport.hasCourtesyCar ? Icons.directions_car : Icons.block,
                            color: airport.hasCourtesyCar ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              airport.hasCourtesyCar ? 'Courtesy Car Available' : 'No Courtesy Car',
                              style: const TextStyle(fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            airport.hasSelfServeFuel ? Icons.local_gas_station : Icons.block,
                            color: airport.hasSelfServeFuel ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              airport.hasSelfServeFuel ? 'Self-Serve Fuel Available' : 'FBO Fuel Only',
                              style: const TextStyle(fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Pricing:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Tie-down: \$${airport.tieDownPrice}/day', style: const TextStyle(fontSize: 14)),
                      Text('Hangar: \$${airport.hangarPrice}/month', style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 24),
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: const Text('Close'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _showDetailedAirportInfo(airport);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: const Text('View Details'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => FAAChartSupplementPage(
                                      airportIdentifier: airport.code,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                backgroundColor: Colors.blue,
                              ),
                              child: const Text('FAA Chart', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetailedAirportInfo(Airport airport) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxHeight: 600, maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Airport image placeholder
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: PlaceholderImages.getAirportPlaceholder(),
                ),
                // Airport details
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${airport.code} - ${airport.name}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Location: ${airport.location}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${airport.rating} (${airport.reviews.length} reviews)',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Restaurants:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...airport.restaurants.map((restaurant) => 
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• $restaurant', style: const TextStyle(fontSize: 14)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Services:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...airport.services.map((service) => 
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• $service', style: const TextStyle(fontSize: 14)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            airport.hasCourtesyCar ? Icons.directions_car : Icons.block,
                            color: airport.hasCourtesyCar ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            airport.hasCourtesyCar ? 'Courtesy Car Available' : 'No Courtesy Car',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            airport.hasSelfServeFuel ? Icons.local_gas_station : Icons.block,
                            color: airport.hasSelfServeFuel ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            airport.hasSelfServeFuel ? 'Self-Serve Fuel Available' : 'FBO Fuel Only',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Pricing:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Tie-down: \$${airport.tieDownPrice}/day', style: const TextStyle(fontSize: 14)),
                      Text('Hangar: \$${airport.hangarPrice}/month', style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('Close'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return AppScaffold(
        currentIndex: 7,
        child: NetworkErrorWidget(
          onRetry: _loadAirports,
          customMessage: _error,
        ),
      );
    }
    if (_airports.isEmpty && !_isLoading) {
      return AppScaffold(
        currentIndex: 7,
        child: EmptyState(
          title: 'No Airports Found',
          message: 'There are currently no airports available.',
          icon: Icons.local_airport,
          onAction: _loadAirports,
          actionText: 'Refresh',
        ),
      );
    }
    return AppScaffold(
      currentIndex: 7,
      child: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Loading airports...',
        child: Column(
          children: [
            // Test button for PDF parsing
            Container(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const FAAPdfTestPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Test FAA PDF Parsing'),
              ),
            ),
            // Map and airport cards
            Expanded(
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(33.4, -111.8),
                      zoom: 9,
                    ),
                    markers: _markers,
                    onMapCreated: (c) => _mapController = c,
                    myLocationEnabled: true,
                    zoomControlsEnabled: false,
                  ),
                  DraggableScrollableSheet(
                    initialChildSize: 0.4,
                    minChildSize: 0.3,
                    maxChildSize: 0.8,
                    builder: (_, controller) => Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
                      ),
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              controller: controller,
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              itemCount: _airports.length,
                              itemBuilder: (_, i) => Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: AirportCard(
                                  airport: _airports[i],
                                  onTap: () => _showAirportDetails(_airports[i]),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AirportCard extends StatelessWidget {
  final Airport airport;
  final VoidCallback onTap;
  
  const AirportCard({required this.airport, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        width: 280, // Reduced width to prevent overflow
        constraints: const BoxConstraints(maxHeight: 180),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${airport.code} - ${airport.name}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              airport.location, 
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, size: 12, color: Colors.amber),
                Text('${airport.rating}', style: const TextStyle(fontSize: 10)),
                const SizedBox(width: 4),
                Flexible(
                  child: Text('(${airport.reviews.length} reviews)', 
                       style: const TextStyle(fontSize: 8, color: Colors.grey)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Restaurants: ${airport.restaurants.take(1).join(", ")}', 
              style: const TextStyle(fontSize: 8),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  airport.hasCourtesyCar ? Icons.directions_car : Icons.block,
                  size: 12,
                  color: airport.hasCourtesyCar ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    airport.hasCourtesyCar ? 'Courtesy Car' : 'No Courtesy Car',
                    style: const TextStyle(fontSize: 8),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  airport.hasSelfServeFuel ? Icons.local_gas_station : Icons.block,
                  size: 12,
                  color: airport.hasSelfServeFuel ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    airport.hasSelfServeFuel ? 'Self-Serve Fuel' : 'FBO Fuel Only',
                    style: const TextStyle(fontSize: 8),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Services: ${airport.services.take(2).join(", ")}', 
              style: const TextStyle(fontSize: 8),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              'Tie-down: \$${airport.tieDownPrice}/day | Hangar: \$${airport.hangarPrice}/month', 
              style: const TextStyle(fontSize: 8),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                ),
                child: const Text('View Details', style: TextStyle(fontSize: 10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
