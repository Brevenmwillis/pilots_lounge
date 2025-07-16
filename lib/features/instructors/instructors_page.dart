import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pilots_lounge/models/instructor.dart';
import 'package:pilots_lounge/services/map_icons.dart';
import 'package:pilots_lounge/services/placeholder_images.dart';
import 'package:pilots_lounge/services/firestore/firestore_service.dart';
import 'package:pilots_lounge/widgets/loading_overlay.dart';
import 'package:pilots_lounge/widgets/error_widgets.dart';
import 'package:pilots_lounge/widgets/app_scaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pilots_lounge/widgets/centered_dialog.dart';

class InstructorsPage extends StatefulWidget {
  const InstructorsPage({super.key});

  @override
  State<InstructorsPage> createState() => _InstructorsPageState();
}

class _InstructorsPageState extends State<InstructorsPage> {
  // ignore: unused_field
  GoogleMapController? _mapController;
  String _selectedType = 'All';
  final FirestoreService _firestoreService = FirestoreService();
  List<Instructor> _instructors = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInstructors();
  }

  Future<void> _loadInstructors() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final instructors = await _firestoreService.getInstructors(type: _selectedType);
      setState(() {
        _instructors = instructors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load instructors: $e';
        _isLoading = false;
      });
    }
  }

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

  void _showInstructorForm({Instructor? instructor}) {
    CenteredDialog.show(
      context: context,
      child: InstructorForm(
        instructor: instructor,
        onSaved: (newInstructor) async {
          Navigator.of(context).pop();
          await _loadInstructors();
        },
      ),
    );
  }

  // ignore: unused_element
  void _deleteInstructor(Instructor instructor) async {
    try {
      await FirestoreService().deleteInstructor(instructor.id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Instructor deleted successfully!')));
      await _loadInstructors();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting instructor: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return AppScaffold(
        currentIndex: 3,
        child: NetworkErrorWidget(
          onRetry: _loadInstructors,
          customMessage: _error,
        ),
      );
    }
    if (_instructors.isEmpty && !_isLoading) {
      return AppScaffold(
        currentIndex: 3,
        child: EmptyState(
          title: 'No Instructors Found',
          message: 'There are currently no instructors available.',
          icon: Icons.school,
          onAction: _loadInstructors,
          actionText: 'Refresh',
        ),
      );
    }
    return AppScaffold(
      currentIndex: 3,
      child: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Loading instructors...',
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
                    onChanged: (value) async {
                      setState(() {
                        _selectedType = value!;
                      });
                      await _loadInstructors();
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
            Positioned(
              bottom: 24,
              right: 24,
              child: FloatingActionButton(
                onPressed: () => _showInstructorForm(),
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InstructorCard extends StatelessWidget {
  final Instructor instructor;
  
  const InstructorCard({required this.instructor, super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isOwner = user != null && user.uid == instructor.id; // Adjust if ownerId is used
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
                if (isOwner) ...[
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () {
                      CenteredDialog.show(
                        context: context,
                        child: InstructorForm(
                          instructor: instructor,
                          onSaved: (updatedInstructor) async {
                            Navigator.of(context).pop();
                            // Refresh the page data
                            if (context.mounted) {
                              final state = context.findAncestorStateOfType<_InstructorsPageState>();
                              state?._loadInstructors();
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
                          title: const Text('Delete Instructor'),
                          content: const Text('Are you sure you want to delete this instructor?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        try {
                          await FirestoreService().deleteInstructor(instructor.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Instructor deleted successfully!')));
                            final state = context.findAncestorStateOfType<_InstructorsPageState>();
                            state?._loadInstructors();
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting instructor: $e')));
                          }
                        }
                      }
                    },
                  ),
                ],
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

class InstructorForm extends StatefulWidget {
  final Instructor? instructor;
  final Future<void> Function(Instructor) onSaved;
  const InstructorForm({this.instructor, required this.onSaved, super.key});
  @override
  State<InstructorForm> createState() => _InstructorFormState();
}

class _InstructorFormState extends State<InstructorForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _contactInfoController = TextEditingController();
  
  final List<String> _endorsements = [];
  final List<String> _preferredLocations = [];
  
  String _selectedType = 'CFI';
  bool _contactThroughApp = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.instructor != null) {
      _nameController.text = widget.instructor!.name;
      _locationController.text = widget.instructor!.location;
      _latController.text = widget.instructor!.lat.toString();
      _lngController.text = widget.instructor!.lng.toString();
      _contactInfoController.text = widget.instructor!.contactInfo ?? '';
      _selectedType = widget.instructor!.type;
      _contactThroughApp = widget.instructor!.contactThroughApp;
      _endorsements.addAll(widget.instructor!.endorsements);
      _preferredLocations.addAll(widget.instructor!.preferredLocations);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _contactInfoController.dispose();
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

      final instructor = Instructor(
        id: widget.instructor?.id ?? '',
        name: _nameController.text,
        type: _selectedType,
        location: _locationController.text,
        lat: double.tryParse(_latController.text) ?? 0.0,
        lng: double.tryParse(_lngController.text) ?? 0.0,
        preferredLocations: List.from(_preferredLocations),
        endorsements: List.from(_endorsements),
        rating: widget.instructor?.rating ?? 0.0,
        reviews: widget.instructor?.reviews ?? [],
        contactInfo: _contactInfoController.text.isEmpty ? null : _contactInfoController.text,
        contactThroughApp: _contactThroughApp,
        lastUpdated: DateTime.now(),
        isActive: true,
      );

      if (widget.instructor != null) {
        // Update existing
        await FirestoreService().updateInstructor(instructor.id, instructor.toFirestore());
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Instructor updated successfully!')));
      } else {
        // Create new
        await FirestoreService().createInstructor(instructor);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Instructor created successfully!')));
      }

      await widget.onSaved(instructor);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addEndorsement() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Endorsement'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Endorsement'),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              setState(() => _endorsements.add(value));
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
                setState(() => _endorsements.add(controller.text));
              }
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addPreferredLocation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Preferred Location'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Location'),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              setState(() => _preferredLocations.add(value));
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
                setState(() => _preferredLocations.add(controller.text));
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
                widget.instructor != null ? 'Edit Instructor' : 'Create Instructor',
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
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Type *'),
                items: const [
                  DropdownMenuItem(value: 'CFI', child: Text('CFI')),
                  DropdownMenuItem(value: 'DPE', child: Text('DPE')),
                ],
                onChanged: (value) => setState(() => _selectedType = value!),
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
              
              const SizedBox(height: 16),
              
              // Endorsements
              Row(
                children: [
                  const Text('Endorsements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addEndorsement,
                  ),
                ],
              ),
              if (_endorsements.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...(_endorsements.map((endorsement) => Chip(
                  label: Text(endorsement),
                  onDeleted: () => setState(() => _endorsements.remove(endorsement)),
                ))),
              ],
              
              const SizedBox(height: 16),
              
              // Preferred Locations
              Row(
                children: [
                  const Text('Preferred Locations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addPreferredLocation,
                  ),
                ],
              ),
              if (_preferredLocations.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...(_preferredLocations.map((location) => Chip(
                  label: Text(location),
                  onDeleted: () => setState(() => _preferredLocations.remove(location)),
                ))),
              ],
              
              const SizedBox(height: 16),
              
              // Contact Information
              const Text('Contact Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contactInfoController,
                decoration: const InputDecoration(labelText: 'Contact Information'),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text('Contact through app'),
                value: _contactThroughApp,
                onChanged: (value) => setState(() => _contactThroughApp = value ?? true),
              ),
              
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(widget.instructor != null ? 'Update' : 'Create'),
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
