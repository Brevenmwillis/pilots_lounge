import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pilots_lounge/models/mechanic.dart';
import 'package:pilots_lounge/services/map_icons.dart';
import 'package:pilots_lounge/services/placeholder_images.dart';
import 'package:pilots_lounge/services/firestore/firestore_service.dart';
import 'package:pilots_lounge/widgets/loading_overlay.dart';
import 'package:pilots_lounge/widgets/error_widgets.dart';
import 'package:pilots_lounge/widgets/app_scaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pilots_lounge/widgets/centered_dialog.dart';

class MechanicsPage extends StatefulWidget {
  const MechanicsPage({super.key});

  @override
  State<MechanicsPage> createState() => _MechanicsPageState();
}

class _MechanicsPageState extends State<MechanicsPage> {
  // ignore: unused_field
  GoogleMapController? _mapController;
  final FirestoreService _firestoreService = FirestoreService();
  List<Mechanic> _mechanics = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMechanics();
  }

  Future<void> _loadMechanics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final mechanics = await _firestoreService.getMechanics();
      setState(() {
        _mechanics = mechanics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load mechanics: $e';
        _isLoading = false;
      });
    }
  }

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

  void _showMechanicForm({Mechanic? mechanic}) {
    CenteredDialog.show(
      context: context,
      child: MechanicForm(
        mechanic: mechanic,
        onSaved: (newMechanic) async {
          Navigator.of(context).pop();
          await _loadMechanics();
        },
      ),
    );
  }

  // ignore: unused_element
  void _deleteMechanic(Mechanic mechanic) async {
    try {
      await FirestoreService().deleteMechanic(mechanic.id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mechanic deleted successfully!')));
      await _loadMechanics();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting mechanic: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return AppScaffold(
        currentIndex: 6,
        child: NetworkErrorWidget(
          onRetry: _loadMechanics,
          customMessage: _error,
        ),
      );
    }
    if (_mechanics.isEmpty && !_isLoading) {
      return AppScaffold(
        currentIndex: 6,
        child: EmptyState(
          title: 'No Mechanics Found',
          message: 'There are currently no mechanics available.',
          icon: Icons.build,
          onAction: _loadMechanics,
          actionText: 'Refresh',
        ),
      );
    }
    return AppScaffold(
      currentIndex: 6,
      child: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Loading mechanics...',
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
            Positioned(
              bottom: 24,
              right: 24,
              child: FloatingActionButton(
                onPressed: () => _showMechanicForm(),
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MechanicCard extends StatelessWidget {
  final Mechanic mechanic;
  
  const MechanicCard({required this.mechanic, super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isOwner = user != null && user.uid == mechanic.id; // Adjust if ownerId is used
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
                    mechanic.name,
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
                        child: MechanicForm(
                          mechanic: mechanic,
                          onSaved: (updatedMechanic) async {
                            Navigator.of(context).pop();
                            // Refresh the page data
                            if (context.mounted) {
                              final state = context.findAncestorStateOfType<_MechanicsPageState>();
                              state?._loadMechanics();
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
                          title: const Text('Delete Mechanic'),
                          content: const Text('Are you sure you want to delete this mechanic?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        try {
                          await FirestoreService().deleteMechanic(mechanic.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mechanic deleted successfully!')));
                            final state = context.findAncestorStateOfType<_MechanicsPageState>();
                            state?._loadMechanics();
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting mechanic: $e')));
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

class MechanicForm extends StatefulWidget {
  final Mechanic? mechanic;
  final Future<void> Function(Mechanic) onSaved;
  const MechanicForm({this.mechanic, required this.onSaved, super.key});
  @override
  State<MechanicForm> createState() => _MechanicFormState();
}

class _MechanicFormState extends State<MechanicForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _contactInfoController = TextEditingController();
  
  final List<String> _specializations = [];
  final Map<String, double> _averageQuotes = {};
  
  bool _travels = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.mechanic != null) {
      _nameController.text = widget.mechanic!.name;
      _locationController.text = widget.mechanic!.location;
      _latController.text = widget.mechanic!.lat.toString();
      _lngController.text = widget.mechanic!.lng.toString();
      _contactInfoController.text = widget.mechanic!.contactInfo;
      _travels = widget.mechanic!.travels;
      _specializations.addAll(widget.mechanic!.specializations);
      _averageQuotes.addAll(widget.mechanic!.averageQuotes);
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

      final mechanic = Mechanic(
        id: widget.mechanic?.id ?? '',
        name: _nameController.text,
        location: _locationController.text,
        lat: double.tryParse(_latController.text) ?? 0.0,
        lng: double.tryParse(_lngController.text) ?? 0.0,
        specializations: List.from(_specializations),
        averageQuotes: Map.from(_averageQuotes),
        contactInfo: _contactInfoController.text,
        travels: _travels,
        rating: widget.mechanic?.rating ?? 0.0,
        reviews: widget.mechanic?.reviews ?? [],
        lastUpdated: DateTime.now(),
        isActive: true,
      );

      if (widget.mechanic != null) {
        // Update existing
        await FirestoreService().updateMechanic(mechanic.id, mechanic.toFirestore());
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mechanic updated successfully!')));
      } else {
        // Create new
        await FirestoreService().createMechanic(mechanic);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mechanic created successfully!')));
      }

      await widget.onSaved(mechanic);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addSpecialization() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Specialization'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Specialization'),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              setState(() => _specializations.add(value));
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
                setState(() => _specializations.add(controller.text));
              }
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addQuote() {
    String service = '', price = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Average Quote'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Service'),
              onChanged: (v) => service = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              onChanged: (v) => price = v,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (service.isNotEmpty && price.isNotEmpty) {
                final priceValue = double.tryParse(price);
                if (priceValue != null) {
                  setState(() => _averageQuotes[service] = priceValue);
                }
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
                widget.mechanic != null ? 'Edit Mechanic' : 'Create Mechanic',
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
              
              const SizedBox(height: 16),
              
              // Specializations
              Row(
                children: [
                  const Text('Specializations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addSpecialization,
                  ),
                ],
              ),
              if (_specializations.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...(_specializations.map((spec) => Chip(
                  label: Text(spec),
                  onDeleted: () => setState(() => _specializations.remove(spec)),
                ))),
              ],
              
              const SizedBox(height: 16),
              
              // Average Quotes
              Row(
                children: [
                  const Text('Average Quotes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addQuote,
                  ),
                ],
              ),
              if (_averageQuotes.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...(_averageQuotes.entries.map((entry) => Chip(
                  label: Text('${entry.key}: \$${entry.value}'),
                  onDeleted: () => setState(() => _averageQuotes.remove(entry.key)),
                ))),
              ],
              
              const SizedBox(height: 16),
              
              // Contact Information
              const Text('Contact Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contactInfoController,
                decoration: const InputDecoration(labelText: 'Contact Information *'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text('Travels to customer location'),
                value: _travels,
                onChanged: (value) => setState(() => _travels = value ?? false),
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
                        : Text(widget.mechanic != null ? 'Update' : 'Create'),
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
