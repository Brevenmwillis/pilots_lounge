import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pilots_lounge/models/flight_school.dart';
import 'package:pilots_lounge/services/map_icons.dart';
import 'package:pilots_lounge/services/placeholder_images.dart';
import 'package:pilots_lounge/services/firestore/data_service.dart';
import 'package:pilots_lounge/widgets/loading_overlay.dart';
import 'package:pilots_lounge/widgets/error_widgets.dart';
import 'package:pilots_lounge/widgets/app_scaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pilots_lounge/widgets/centered_dialog.dart';

class FlightSchoolsPage extends StatefulWidget {
  const FlightSchoolsPage({super.key});

  @override
  State<FlightSchoolsPage> createState() => _FlightSchoolsPageState();
}

class _FlightSchoolsPageState extends State<FlightSchoolsPage> {
  // ignore: unused_field
  GoogleMapController? _mapController;
  final DataService _dataService = DataService();
  List<FlightSchool> _schools = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFlightSchools();
  }

  Future<void> _loadFlightSchools() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final schools = await _dataService.getFlightSchools();
      setState(() {
        _schools = schools;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load flight schools: $e';
        _isLoading = false;
      });
    }
  }

  Set<Marker> get _markers => _schools.map((s) {
        return Marker(
          markerId: MarkerId(s.id),
          position: LatLng(s.lat, s.lng),
          icon: MapIcons.getSchoolIcon(),
          infoWindow: InfoWindow(
            title: s.name,
            snippet: 'Avg: \$${s.averageGraduationCost}',
          ),
          onTap: () => _showSchoolDetails(s),
        );
      }).toSet();

  void _showSchoolDetails(FlightSchool school) {
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
              // School image placeholder
              Padding(
                padding: const EdgeInsets.all(16),
                child: PlaceholderImages.getSchoolPlaceholder(),
              ),
              // School details
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        school.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Average Cost: \$${school.averageGraduationCost}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Location: ${school.location}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${school.rating} (${school.reviews.length} reviews)',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Curriculum:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...school.curriculum.map((course) => 
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• $course', style: const TextStyle(fontSize: 14)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Available Aircraft:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...school.planesAvailable.map((plane) => 
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• $plane', style: const TextStyle(fontSize: 14)),
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
                                // View detailed pricing breakdown
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('View Pricing'),
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

  void _showFlightSchoolForm({FlightSchool? school}) {
    CenteredDialog.show(
      context: context,
      child: FlightSchoolForm(
        school: school,
        onSaved: (newSchool) async {
          // If editing, update; else, create
          if (school != null) {
            // TODO: update logic
          } else {
            // TODO: create logic
          }
          Navigator.of(context).pop();
          await _loadFlightSchools();
        },
      ),
    );
  }

  // ignore: unused_element
  void _deleteFlightSchool(FlightSchool school) async {
    // TODO: delete logic
    await _loadFlightSchools();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return AppScaffold(
        currentIndex: 5,
        child: NetworkErrorWidget(
          onRetry: _loadFlightSchools,
          customMessage: _error,
        ),
      );
    }
    if (_schools.isEmpty && !_isLoading) {
      return AppScaffold(
        currentIndex: 5,
        child: EmptyState(
          title: 'No Flight Schools Found',
          message: 'There are currently no flight schools available.',
          icon: Icons.school,
          onAction: _loadFlightSchools,
          actionText: 'Refresh',
        ),
      );
    }
    return AppScaffold(
      currentIndex: 5,
      child: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Loading flight schools...',
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
                        itemCount: _schools.length,
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: FlightSchoolCard(school: _schools[i]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              right: 24,
              child: FloatingActionButton(
                onPressed: () => _showFlightSchoolForm(),
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FlightSchoolCard extends StatelessWidget {
  final FlightSchool school;
  
  const FlightSchoolCard({required this.school, super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isOwner = user != null && user.uid == school.id; // Adjust if ownerId is used
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    school.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isOwner) ...[
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () {
                      CenteredDialog.show(
                        context: context,
                        child: FlightSchoolForm(
                          school: school,
                          onSaved: (updatedSchool) async {
                            // TODO: update logic
                            Navigator.of(context).pop();
                          },
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Flight School'),
                          content: const Text('Are you sure you want to delete this flight school?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        // TODO: delete logic
                      }
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Avg Cost: \$${school.averageGraduationCost}',
              style: const TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              school.location, 
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, size: 12, color: Colors.amber),
                Text('${school.rating}', style: const TextStyle(fontSize: 11)),
                const SizedBox(width: 4),
                Text('(${school.reviews.length} reviews)', 
                     style: const TextStyle(fontSize: 9, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Curriculum: ${school.curriculum.take(2).join(", ")}', 
              style: const TextStyle(fontSize: 9),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              'Aircraft: ${school.planesAvailable.take(2).join(", ")}', 
              style: const TextStyle(fontSize: 9),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // View detailed pricing breakdown
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                ),
                child: const Text('View Pricing', style: TextStyle(fontSize: 11)),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 

class FlightSchoolForm extends StatefulWidget {
  final FlightSchool? school;
  final Future<void> Function(FlightSchool) onSaved;
  const FlightSchoolForm({this.school, required this.onSaved, super.key});
  @override
  State<FlightSchoolForm> createState() => _FlightSchoolFormState();
}

class _FlightSchoolFormState extends State<FlightSchoolForm> {
  // TODO: Add controllers and form fields for all FlightSchool properties
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Flight School', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          // TODO: Add TextFormFields for all required fields
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    // TODO: Validate and save
                    // widget.onSaved(newSchool);
                  },
                  child: const Text('Save'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 
