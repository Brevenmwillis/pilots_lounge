import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pilots_lounge/models/instructor.dart';
import 'package:pilots_lounge/services/map_icons.dart';
import 'package:pilots_lounge/services/placeholder_images.dart';
import 'package:pilots_lounge/widgets/app_scaffold.dart';

class InstructorsPage extends StatefulWidget {
  const InstructorsPage({super.key});

  @override
  State<InstructorsPage> createState() => _InstructorsPageState();
}

class _InstructorsPageState extends State<InstructorsPage> {
  // ignore: unused_field
  GoogleMapController? _mapController;
  String _selectedType = 'All';

  final List<Instructor> _instructors = [
    Instructor(
      id: '1',
      name: 'John Smith',
      type: 'CFI',
      location: 'Phoenix Sky Harbor',
      lat: 33.4342,
      lng: -112.0116,
      preferredLocations: ['Phoenix', 'Scottsdale', 'Mesa'],
      endorsements: ['Private Pilot', 'Instrument Rating', 'Commercial Pilot'],
      rating: 4.8,
      reviews: [],
      contactInfo: 'john.smith@email.com',
      contactThroughApp: true,
      lastUpdated: DateTime.now(),
      isActive: true,
    ),
    Instructor(
      id: '2',
      name: 'Sarah Johnson',
      type: 'DPE',
      location: 'Scottsdale Airport',
      lat: 33.6229,
      lng: -111.9102,
      preferredLocations: ['Scottsdale', 'Phoenix'],
      endorsements: ['Private Pilot', 'Instrument Rating', 'Commercial Pilot', 'Multi-Engine'],
      rating: 4.9,
      reviews: [],
      contactInfo: null,
      contactThroughApp: true,
      lastUpdated: DateTime.now(),
      isActive: true,
    ),
  ];

  List<Instructor> get _filteredInstructors {
    if (_selectedType == 'All') return _instructors;
    return _instructors.where((i) => i.type == _selectedType).toList();
  }

  Set<Marker> get _markers => _filteredInstructors.map((i) {
        return Marker(
          markerId: MarkerId(i.id),
          position: LatLng(i.lat, i.lng),
          icon: MapIcons.getInstructorIcon(),
          infoWindow: InfoWindow(
            title: i.name,
            snippet: '${i.type} - ${i.location}',
          ),
          onTap: () => _showInstructorDetails(i),
        );
      }).toSet();

  void _showInstructorDetails(Instructor instructor) {
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
              // Instructor image placeholder
              Padding(
                padding: const EdgeInsets.all(16),
                child: PlaceholderImages.getInstructorPlaceholder(),
              ),
              // Instructor details
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              instructor.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: instructor.type == 'DPE' ? Colors.orange : Colors.blue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              instructor.type,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Location: ${instructor.location}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${instructor.rating} (${instructor.reviews.length} reviews)',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Endorsements:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...instructor.endorsements.map((endorsement) => 
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• $endorsement', style: const TextStyle(fontSize: 14)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Preferred Locations:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...instructor.preferredLocations.map((location) => 
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• $location', style: const TextStyle(fontSize: 14)),
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
                                // Handle contact
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(
                                instructor.contactThroughApp ? 'Contact via App' : 'Contact',
                              ),
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
      currentIndex: 3,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('Filter: ', style: TextStyle(fontSize: 16)),
                DropdownButton<String>(
                  value: _selectedType,
                  items: ['All', 'CFI', 'DPE'].map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                ),
              ],
            ),
          ),
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
                      itemCount: _filteredInstructors.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: InstructorCard(instructor: _filteredInstructors[i]),
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

class InstructorCard extends StatelessWidget {
  final Instructor instructor;
  
  const InstructorCard({required this.instructor, super.key});

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
            Row(
              children: [
                Expanded(
                  child: Text(
                    instructor.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: instructor.type == 'DPE' ? Colors.orange : Colors.blue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    instructor.type,
                    style: const TextStyle(color: Colors.white, fontSize: 9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              instructor.location, 
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, size: 12, color: Colors.amber),
                Text('${instructor.rating}', style: const TextStyle(fontSize: 11)),
                const SizedBox(width: 4),
                Text('(${instructor.reviews.length} reviews)', 
                     style: const TextStyle(fontSize: 9, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Endorsements: ${instructor.endorsements.take(2).join(", ")}', 
              style: const TextStyle(fontSize: 9),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              'Preferred: ${instructor.preferredLocations.take(2).join(", ")}', 
              style: const TextStyle(fontSize: 9),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Contact through app or show contact info
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                ),
                child: Text(
                  instructor.contactThroughApp ? 'Contact via App' : 'Contact',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
