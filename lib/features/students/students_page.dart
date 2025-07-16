// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pilots_lounge/models/flight_school.dart';        // new package name
import 'package:pilots_lounge/features/students/flight_school_card.dart';
import 'package:pilots_lounge/widgets/app_scaffold.dart';
import 'package:pilots_lounge/services/firestore/data_service.dart';
import 'package:pilots_lounge/widgets/loading_overlay.dart';
import 'package:pilots_lounge/widgets/error_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pilots_lounge/widgets/centered_dialog.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
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
          infoWindow: InfoWindow(title: s.name),
        );
      }).toSet();

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
        currentIndex: 1,
        child: NetworkErrorWidget(
          onRetry: _loadFlightSchools,
          customMessage: _error,
        ),
      );
    }
    if (_schools.isEmpty && !_isLoading) {
      return AppScaffold(
        currentIndex: 1,
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
      currentIndex: 1,
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
              initialChildSize: 0.25,
              minChildSize: 0.15,
              maxChildSize: 0.6,
              builder: (_, controller) => Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
                ),
                child: ListView.builder(
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  itemCount: _schools.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.all(12),
                    child: FlightSchoolCard(school: _schools[i]),
                  ),
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
        width: 240,
        constraints: const BoxConstraints(maxHeight: 100),
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
            // ... existing code ...
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
