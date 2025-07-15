import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pilots_lounge/models/airport.dart';
import 'package:pilots_lounge/services/map_icons.dart';
import 'package:pilots_lounge/services/placeholder_images.dart';
import 'package:pilots_lounge/widgets/app_scaffold.dart';
import 'faa_chart_supplement_page.dart';
import 'faa_pdf_test_page.dart';

class AirportsPage extends StatefulWidget {
  const AirportsPage({super.key});

  @override
  State<AirportsPage> createState() => _AirportsPageState();
}

class _AirportsPageState extends State<AirportsPage> {
  // ignore: unused_field
  GoogleMapController? _mapController;

  final List<Airport> _airports = [
    Airport(
      id: '1',
      code: 'KPHX',
      name: 'Phoenix Sky Harbor International',
      location: 'Phoenix, AZ',
      lat: 33.4342,
      lng: -112.0116,
      restaurants: ['Sky Harbor Grill', 'Pilot\'s Cafe', 'Runway Restaurant', 'Altitude Bar & Grill'],
      hasCourtesyCar: true,
      services: ['FBO', 'Fuel', 'Maintenance', 'Flight Training', 'Charter Services'],
      hasSelfServeFuel: true,
      tipsAndTricks: ['Call ahead for courtesy car', 'Self-serve fuel available 24/7', 'Busy airspace - monitor approach'],
      hasTieDowns: true,
      hasHangars: true,
      tieDownPrice: 15,
      hangarPrice: 350,
      rating: 4.5,
      reviews: [],
      lastUpdated: DateTime.now(),
    ),
    Airport(
      id: '2',
      code: 'KSDL',
      name: 'Scottsdale Airport',
      location: 'Scottsdale, AZ',
      lat: 33.6229,
      lng: -111.9102,
      restaurants: ['Hangar Cafe', 'Skyline Restaurant', 'Pilot\'s Lounge'],
      hasCourtesyCar: false,
      services: ['FBO', 'Fuel', 'Charter Services', 'Aircraft Sales'],
      hasSelfServeFuel: false,
      tipsAndTricks: ['No courtesy car available', 'Call FBO for fuel', 'Luxury aircraft common'],
      hasTieDowns: true,
      hasHangars: true,
      tieDownPrice: 20,
      hangarPrice: 400,
      rating: 4.3,
      reviews: [],
      lastUpdated: DateTime.now(),
    ),
    Airport(
      id: '3',
      code: 'KCHD',
      name: 'Chandler Municipal Airport',
      location: 'Chandler, AZ',
      lat: 33.2692,
      lng: -111.8108,
      restaurants: ['Chandler Cafe', 'Skyway Diner'],
      hasCourtesyCar: true,
      services: ['FBO', 'Fuel', 'Flight Training', 'Aircraft Maintenance'],
      hasSelfServeFuel: true,
      tipsAndTricks: ['Courtesy car available with 24hr notice', 'Great for flight training'],
      hasTieDowns: true,
      hasHangars: true,
      tieDownPrice: 12,
      hangarPrice: 300,
      rating: 4.7,
      reviews: [],
      lastUpdated: DateTime.now(),
    ),
    Airport(
      id: '4',
      code: 'KFFZ',
      name: 'Falcon Field Airport',
      location: 'Mesa, AZ',
      lat: 33.4608,
      lng: -111.7283,
      restaurants: ['Falcon\'s Nest', 'Warbird Cafe'],
      hasCourtesyCar: true,
      services: ['FBO', 'Fuel', 'Warbird Maintenance', 'Flight Training'],
      hasSelfServeFuel: true,
      tipsAndTricks: ['Home to many warbirds', 'Courtesy car available', 'Watch for vintage aircraft'],
      hasTieDowns: true,
      hasHangars: true,
      tieDownPrice: 10,
      hangarPrice: 280,
      rating: 4.6,
      reviews: [],
      lastUpdated: DateTime.now(),
    ),
    Airport(
      id: '5',
      code: 'KGEU',
      name: 'Glendale Municipal Airport',
      location: 'Glendale, AZ',
      lat: 33.5269,
      lng: -112.2950,
      restaurants: ['Glendale Grill', 'Pilot\'s Pantry'],
      hasCourtesyCar: false,
      services: ['FBO', 'Fuel', 'Aircraft Sales', 'Flight Training'],
      hasSelfServeFuel: false,
      tipsAndTricks: ['No courtesy car', 'Call ahead for services', 'Good for training'],
      hasTieDowns: true,
      hasHangars: false,
      tieDownPrice: 8,
      hangarPrice: 0,
      rating: 4.1,
      reviews: [],
      lastUpdated: DateTime.now(),
    ),
    Airport(
      id: '6',
      code: 'KGYR',
      name: 'Phoenix Goodyear Airport',
      location: 'Goodyear, AZ',
      lat: 33.4228,
      lng: -112.3759,
      restaurants: ['Goodyear Cafe', 'Skyway Restaurant'],
      hasCourtesyCar: true,
      services: ['FBO', 'Fuel', 'Aircraft Maintenance', 'Flight Training'],
      hasSelfServeFuel: true,
      tipsAndTricks: ['Courtesy car available', 'Less busy than Sky Harbor', 'Good alternative'],
      hasTieDowns: true,
      hasHangars: true,
      tieDownPrice: 14,
      hangarPrice: 320,
      rating: 4.4,
      reviews: [],
      lastUpdated: DateTime.now(),
    ),
    Airport(
      id: '7',
      code: 'KDVT',
      name: 'Phoenix Deer Valley Airport',
      location: 'Phoenix, AZ',
      lat: 33.6883,
      lng: -112.0825,
      restaurants: ['Deer Valley Diner', 'Pilot\'s Cafe'],
      hasCourtesyCar: true,
      services: ['FBO', 'Fuel', 'Flight Training', 'Aircraft Sales'],
      hasSelfServeFuel: true,
      tipsAndTricks: ['Busiest GA airport in US', 'Courtesy car available', 'Call ahead'],
      hasTieDowns: true,
      hasHangars: true,
      tieDownPrice: 18,
      hangarPrice: 380,
      rating: 4.8,
      reviews: [],
      lastUpdated: DateTime.now(),
    ),
    Airport(
      id: '8',
      code: 'KLUF',
      name: 'Luke Air Force Base',
      location: 'Glendale, AZ',
      lat: 33.5350,
      lng: -112.3831,
      restaurants: ['Luke AFB Club', 'Base Exchange'],
      hasCourtesyCar: false,
      services: ['Military Base', 'Limited Civilian Access', 'F-35 Training'],
      hasSelfServeFuel: false,
      tipsAndTricks: ['Military base - restricted access', 'F-35 training flights', 'Contact base for clearance'],
      hasTieDowns: false,
      hasHangars: false,
      tieDownPrice: 0,
      hangarPrice: 0,
      rating: 4.2,
      reviews: [],
      lastUpdated: DateTime.now(),
    ),
    Airport(
      id: '9',
      code: 'KP08',
      name: 'Coolidge Municipal Airport',
      location: 'Coolidge, AZ',
      lat: 32.9358,
      lng: -111.4269,
      restaurants: ['Coolidge Cafe'],
      hasCourtesyCar: false,
      services: ['FBO', 'Fuel', 'Flight Training'],
      hasSelfServeFuel: true,
      tipsAndTricks: ['Small airport', 'Self-serve fuel', 'Quiet airspace'],
      hasTieDowns: true,
      hasHangars: false,
      tieDownPrice: 5,
      hangarPrice: 0,
      rating: 4.0,
      reviews: [],
      lastUpdated: DateTime.now(),
    ),
    Airport(
      id: '10',
      code: 'KPRC',
      name: 'Prescott Regional Airport',
      location: 'Prescott, AZ',
      lat: 34.6494,
      lng: -112.4197,
      restaurants: ['Prescott Cafe', 'Mountain View Restaurant'],
      hasCourtesyCar: true,
      services: ['FBO', 'Fuel', 'Flight Training', 'Aircraft Maintenance'],
      hasSelfServeFuel: true,
      tipsAndTricks: ['Mountain flying', 'Courtesy car available', 'Cooler weather'],
      hasTieDowns: true,
      hasHangars: true,
      tieDownPrice: 12,
      hangarPrice: 300,
      rating: 4.5,
      reviews: [],
      lastUpdated: DateTime.now(),
    ),
    Airport(
      id: '11',
      code: 'KFLG',
      name: 'Flagstaff Pulliam Airport',
      location: 'Flagstaff, AZ',
      lat: 35.1403,
      lng: -111.6694,
      restaurants: ['Flagstaff Cafe', 'Mountain Air Restaurant'],
      hasCourtesyCar: true,
      services: ['FBO', 'Fuel', 'Flight Training', 'Aircraft Maintenance'],
      hasSelfServeFuel: true,
      tipsAndTricks: ['High altitude airport', 'Mountain flying', 'Courtesy car available'],
      hasTieDowns: true,
      hasHangars: true,
      tieDownPrice: 15,
      hangarPrice: 350,
      rating: 4.6,
      reviews: [],
      lastUpdated: DateTime.now(),
    ),
    Airport(
      id: '12',
      code: 'KTUS',
      name: 'Tucson International Airport',
      location: 'Tucson, AZ',
      lat: 32.1161,
      lng: -110.9410,
      restaurants: ['Tucson Cafe', 'Desert View Restaurant', 'Pilot\'s Lounge'],
      hasCourtesyCar: true,
      services: ['FBO', 'Fuel', 'Flight Training', 'Aircraft Maintenance', 'Charter Services'],
      hasSelfServeFuel: true,
      tipsAndTricks: ['Courtesy car available', 'Self-serve fuel', 'Desert flying'],
      hasTieDowns: true,
      hasHangars: true,
      tieDownPrice: 16,
      hangarPrice: 360,
      rating: 4.4,
      reviews: [],
      lastUpdated: DateTime.now(),
    ),
  ];

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
    return AppScaffold(
      currentIndex: 7,
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
                  // Drag handle
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Cards
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
