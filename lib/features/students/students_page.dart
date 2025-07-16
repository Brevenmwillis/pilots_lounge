// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pilots_lounge/models/flight_school.dart';
import 'package:pilots_lounge/widgets/app_scaffold.dart';
import 'package:pilots_lounge/services/firestore/firestore_service.dart';
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
  final FirestoreService _firestoreService = FirestoreService();
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
      final schools = await _firestoreService.getFlightSchools();
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
          Navigator.of(context).pop();
          await _loadFlightSchools();
        },
      ),
    );
  }

  // ignore: unused_element
  void _deleteFlightSchool(FlightSchool school) async {
    try {
      await FirestoreService().deleteFlightSchool(school.id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Flight school deleted successfully!')));
      await _loadFlightSchools();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting flight school: $e')));
    }
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
                            Navigator.of(context).pop();
                            // Refresh the page data
                            if (context.mounted) {
                              final state = context.findAncestorStateOfType<_StudentsPageState>();
                              state?._loadFlightSchools();
                            }
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
                        try {
                          await FirestoreService().deleteFlightSchool(school.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Flight school deleted successfully!')));
                            final state = context.findAncestorStateOfType<_StudentsPageState>();
                            state?._loadFlightSchools();
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting flight school: $e')));
                          }
                        }
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
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _priceController = TextEditingController();
  final _averageGraduationCostController = TextEditingController();
  
  final List<String> _curriculum = [];
  final List<String> _planesAvailable = [];
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.school != null) {
      _nameController.text = widget.school!.name;
      _locationController.text = widget.school!.location;
      _latController.text = widget.school!.lat.toString();
      _lngController.text = widget.school!.lng.toString();
      _priceController.text = widget.school!.price.toString();
      _averageGraduationCostController.text = widget.school!.averageGraduationCost.toString();
      _curriculum.addAll(widget.school!.curriculum);
      _planesAvailable.addAll(widget.school!.planesAvailable);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _priceController.dispose();
    _averageGraduationCostController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in to create listings')));
        return;
      }

      final school = FlightSchool(
        id: widget.school?.id ?? '',
        name: _nameController.text,
        location: _locationController.text,
        lat: double.tryParse(_latController.text) ?? 0.0,
        lng: double.tryParse(_lngController.text) ?? 0.0,
        rating: widget.school?.rating ?? 0.0,
        price: double.tryParse(_priceController.text) ?? 0.0,
        curriculum: List.from(_curriculum),
        planesAvailable: List.from(_planesAvailable),
        averageGraduationCost: double.tryParse(_averageGraduationCostController.text) ?? 0.0,
        reviews: widget.school?.reviews ?? [],
        lastUpdated: DateTime.now(),
        isActive: true,
      );

      if (widget.school != null) {
        // Update existing
        await FirestoreService().updateFlightSchool(school.id, school.toFirestore());
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Flight school updated successfully!')));
      } else {
        // Create new
        await FirestoreService().createFlightSchool(school);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Flight school created successfully!')));
      }

      await widget.onSaved(school);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addCurriculum() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Curriculum Item'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Curriculum item'),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              setState(() => _curriculum.add(value));
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final controller = TextEditingController();
              if (controller.text.isNotEmpty) {
                setState(() => _curriculum.add(controller.text));
              }
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addPlane() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Available Aircraft'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Aircraft type'),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              setState(() => _planesAvailable.add(value));
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final controller = TextEditingController();
              if (controller.text.isNotEmpty) {
                setState(() => _planesAvailable.add(controller.text));
              }
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.school != null ? 'Edit Flight School' : 'Create Flight School',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Basic Information
              const Text('Basic Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name *'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location *'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      decoration: const InputDecoration(labelText: 'Latitude'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _lngController,
                      decoration: const InputDecoration(labelText: 'Longitude'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Hourly Rate *'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v?.isEmpty == true || double.tryParse(v!) == null ? 'Valid price required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _averageGraduationCostController,
                      decoration: const InputDecoration(labelText: 'Avg Graduation Cost *'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v?.isEmpty == true || double.tryParse(v!) == null ? 'Valid cost required' : null,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Curriculum
              Row(
                children: [
                  const Text('Curriculum', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addCurriculum,
                  ),
                ],
              ),
              if (_curriculum.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...(_curriculum.map((item) => Chip(
                  label: Text(item),
                  onDeleted: () => setState(() => _curriculum.remove(item)),
                ))),
              ],
              
              const SizedBox(height: 16),
              
              // Available Aircraft
              Row(
                children: [
                  const Text('Available Aircraft', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addPlane,
                  ),
                ],
              ),
              if (_planesAvailable.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...(_planesAvailable.map((plane) => Chip(
                  label: Text(plane),
                  onDeleted: () => setState(() => _planesAvailable.remove(plane)),
                ))),
              ],
              
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(widget.school != null ? 'Update' : 'Create'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
