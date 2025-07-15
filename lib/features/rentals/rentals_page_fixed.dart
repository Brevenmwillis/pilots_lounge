import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pilots_lounge/models/aircraft.dart';
import 'package:pilots_lounge/services/map_icons.dart';
import 'package:pilots_lounge/services/placeholder_images.dart';
import 'package:pilots_lounge/widgets/app_scaffold.dart';

class RentalsPageFixed extends StatefulWidget {
  const RentalsPageFixed({super.key});

  @override
  State<RentalsPageFixed> createState() => _RentalsPageFixedState();
}

class _RentalsPageFixedState extends State<RentalsPageFixed> {
  // ignore: unused_field
  GoogleMapController? _mapController;

  final List<Aircraft> _aircraft = [
    Aircraft(
      id: '1',
      registration: 'N12345',
      make: 'Cessna',
      model: '172 Skyhawk',
      year: 2015,
      price: 150,
      location: 'Phoenix Sky Harbor',
      lat: 33.4342,
      lng: -112.0116,
      avionics: ['Garmin G1000', 'Autopilot', 'ADS-B In/Out'],
      specs: const {
        'Engine': 'Lycoming O-320',
        'HP': '160',
        'Fuel Capacity': '56 gallons',
        'Range': '575 nm',
        'Cruise Speed': '120 knots',
      },
      rating: 4.7,
      reviews: [],
      ownerId: 'owner1',
      bookingWebsite: 'https://example.com/book',
      paymentMethods: ['Credit Card', 'Cash', 'Check'],
      insuranceRequirements: r'$1M liability, $50K hull',
      insuranceDeductible: 1000,
      internationalFlights: false,
      lastUpdated: DateTime(2023, 1, 1),
      isActive: true,
    ),
  ];

  Set<Marker> get _markers => _aircraft.map((a) {
        return Marker(
          markerId: MarkerId(a.id),
          position: LatLng(a.lat, a.lng),
          icon: MapIcons.getRentalIcon(),
          infoWindow: InfoWindow(
            title: '${a.make} ${a.model}',
            snippet: '${a.price}/hr',
          ),
          onTap: () => _showAircraftDetails(a),
        );
      }).toSet();

  void _showAircraftDetails(Aircraft aircraft) {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Aircraft image placeholder
              Padding(
                padding: const EdgeInsets.all(16),
                child: PlaceholderImages.getRentalPlaceholder(),
              ),
              // Aircraft details
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${aircraft.make} ${aircraft.model}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${aircraft.price}/hr',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Location: ${aircraft.location}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Year: ${aircraft.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Avionics:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...aircraft.avionics.map((avionic) => 
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• $avionic'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Specifications:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...aircraft.specs.entries.map((entry) => 
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('${entry.key}: ${entry.value}'),
                        ),
                      ),
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Handle booking
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('Book Now'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 1,
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
                      itemCount: _aircraft.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: AircraftRentalCard(aircraft: _aircraft[i]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AircraftRentalCard extends StatelessWidget {
  final Aircraft aircraft;
  
  const AircraftRentalCard({required this.aircraft, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        width: 280,
        constraints: const BoxConstraints(maxHeight: 160),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${aircraft.make} ${aircraft.model}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '\$${aircraft.price}/hr',
              style: const TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              aircraft.location, 
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, size: 12, color: Colors.amber),
                Text('${aircraft.rating}', style: const TextStyle(fontSize: 11)),
                const SizedBox(width: 4),
                Text('(${aircraft.reviews.length} reviews)', 
                     style: const TextStyle(fontSize: 9, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Avionics: ${aircraft.avionics.take(2).join(", ")}', 
              style: const TextStyle(fontSize: 9),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              'Insurance: \$${aircraft.insuranceDeductible} deductible', 
              style: const TextStyle(fontSize: 9),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to booking website
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                ),
                child: const Text('Book Now', style: TextStyle(fontSize: 11)),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
