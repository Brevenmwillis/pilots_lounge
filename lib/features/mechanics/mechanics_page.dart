import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pilots_lounge/models/mechanic.dart';
import 'package:pilots_lounge/services/map_icons.dart';
import 'package:pilots_lounge/services/placeholder_images.dart';
import 'package:pilots_lounge/services/firestore/data_service.dart';
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
  final DataService _dataService = DataService();
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
      final mechanics = await _dataService.getMechanics();
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
          // If editing, update; else, create
          if (mechanic != null) {
            // TODO: update logic
          } else {
            // TODO: create logic
          }
          Navigator.of(context).pop();
          await _loadMechanics();
        },
      ),
    );
  }

  // ignore: unused_element
  void _deleteMechanic(Mechanic mechanic) async {
    // TODO: delete logic
    await _loadMechanics();
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
                          title: const Text('Delete Mechanic'),
                          content: const Text('Are you sure you want to delete this mechanic?'),
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
  // TODO: Add controllers and form fields for all Mechanic properties
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Mechanic', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          // TODO: Add TextFormFields for all required fields
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    // TODO: Validate and save
                    // widget.onSaved(newMechanic);
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
