import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pilots_lounge/models/mechanic.dart';
import 'package:pilots_lounge/services/map_icons.dart';
import 'package:pilots_lounge/services/placeholder_images.dart';
import 'package:pilots_lounge/widgets/app_scaffold.dart';

class MechanicsPage extends StatefulWidget {
  const MechanicsPage({super.key});

  @override
  State<MechanicsPage> createState() => _MechanicsPageState();
}

class _MechanicsPageState extends State<MechanicsPage> {
  // ignore: unused_field
  GoogleMapController? _mapController;

  final List<Mechanic> _mechanics = [
    Mechanic(
      id: '1',
      name: 'Mike Johnson A&P',
      location: 'Phoenix Sky Harbor',
      lat: 33.4342,
      lng: -112.0116,
      specializations: ['Piston Engines', 'Avionics', 'Annual Inspections'],
      averageQuotes: const {
        'Annual Inspection': 800,
        'Oil Change': 150,
        '100-Hour Inspection': 600,
        'Avionics Installation': 2000,
      },
      contactInfo: 'mike.johnson@email.com',
      travels: true,
      rating: 4.8,
      reviews: [],
      lastUpdated: DateTime.now(),
      isActive: true,
    ),
    Mechanic(
      id: '2',
      name: 'Bob Wilson Aviation',
      location: 'Scottsdale Airport',
      lat: 33.6229,
      lng: -111.9102,
      specializations: ['Turbine Engines', 'Composite Repair'],
      averageQuotes: const {
        'Annual Inspection': 1200,
        'Turbine Inspection': 2500,
        'Composite Repair': 800,
      },
      contactInfo: 'bob.wilson@email.com',
      travels: false,
      rating: 4.9,
      reviews: [],
      lastUpdated: DateTime.now(),
      isActive: true,
    ),
  ];

  Set<Marker> get _markers => _mechanics.map((m) {
        return Marker(
          markerId: MarkerId(m.id),
          position: LatLng(m.lat, m.lng),
          icon: MapIcons.getMechanicIcon(),
          infoWindow: InfoWindow(
            title: m.name,
            snippet: m.location,
          ),
          onTap: () => _showMechanicDetails(m),
        );
      }).toSet();

  void _showMechanicDetails(Mechanic mechanic) {
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
              // Mechanic shop image placeholder
              Padding(
                padding: const EdgeInsets.all(16),
                child: PlaceholderImages.getMechanicPlaceholder(),
              ),
              // Mechanic details
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mechanic.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Location: ${mechanic.location}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${mechanic.rating} (${mechanic.reviews.length} reviews)',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Specializations:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...mechanic.specializations.map((spec) => 
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• $spec', style: const TextStyle(fontSize: 14)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Average Quotes:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...mechanic.averageQuotes.entries.map((entry) => 
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('${entry.key}: \$${entry.value}', style: const TextStyle(fontSize: 14)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            mechanic.travels ? Icons.directions_car : Icons.location_on,
                            color: mechanic.travels ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            mechanic.travels ? 'Travels to your location' : 'On-site only',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Contact: ${mechanic.contactInfo}',
                        style: const TextStyle(fontSize: 16),
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
                                // Contact mechanic
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('Contact'),
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
      currentIndex: 6,
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
                      itemCount: _mechanics.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: MechanicCard(mechanic: _mechanics[i]),
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

class MechanicCard extends StatelessWidget {
  final Mechanic mechanic;
  
  const MechanicCard({required this.mechanic, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        width: 300,
        constraints: const BoxConstraints(maxHeight: 160),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              mechanic.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              mechanic.location, 
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, size: 12, color: Colors.amber),
                Text('${mechanic.rating}', style: const TextStyle(fontSize: 11)),
                const SizedBox(width: 4),
                Text('(${mechanic.reviews.length} reviews)', 
                     style: const TextStyle(fontSize: 9, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Specializations: ${mechanic.specializations.take(2).join(", ")}', 
              style: const TextStyle(fontSize: 9),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              'Quotes: ${mechanic.averageQuotes.entries.take(1).map((e) => '${e.key}: \$${e.value}').join(", ")}', 
              style: const TextStyle(fontSize: 9),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  mechanic.travels ? Icons.directions_car : Icons.location_on,
                  size: 12,
                  color: mechanic.travels ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  mechanic.travels ? 'Travels' : 'On-site only',
                  style: const TextStyle(fontSize: 9),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Contact mechanic
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                ),
                child: const Text('Contact', style: TextStyle(fontSize: 11)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
