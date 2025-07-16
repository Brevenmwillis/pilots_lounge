// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pilots_lounge/models/aircraft.dart';
import 'package:pilots_lounge/services/firestore/data_service.dart';
import 'package:pilots_lounge/services/map_icons.dart';
import 'package:pilots_lounge/services/placeholder_images.dart';
import 'package:pilots_lounge/widgets/app_scaffold.dart';
import 'package:pilots_lounge/widgets/loading_overlay.dart';
import 'package:pilots_lounge/widgets/error_widgets.dart';

class ChartersPage extends StatefulWidget {
  const ChartersPage({super.key});

  @override
  State<ChartersPage> createState() => _ChartersPageState();
}

class _ChartersPageState extends State<ChartersPage> {
  GoogleMapController? _mapController;
  final DataService _dataService = DataService();
  List<Aircraft> _charters = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCharters();
  }

  Future<void> _loadCharters() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final charters = await _dataService.getCharterAircraft();
      setState(() {
        _charters = charters;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load charters: $e';
        _isLoading = false;
      });
    }
  }

  Set<Marker> get _markers => _charters.map((a) {
        return Marker(
          markerId: MarkerId(a.id),
          position: LatLng(a.lat, a.lng),
          icon: MapIcons.getCharterIcon(),
          infoWindow: InfoWindow(
            title: '${a.make} ${a.model}',
            snippet: '\$${a.price}/hr',
          ),
          onTap: () => _showCharterDetails(a),
        );
      }).toSet();

  void _showCharterDetails(Aircraft aircraft) {
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
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: PlaceholderImages.getCharterPlaceholder(),
              ),
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
                      Text('Registration: ${aircraft.registration}', style: const TextStyle(fontSize: 16)),
                      Text('Year: ${aircraft.year}', style: const TextStyle(fontSize: 16)),
                      Text('Location: ${aircraft.location}', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            '\$${aircraft.price}/hr',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 20),
                              Text(
                                aircraft.rating.toString(),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Avionics:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...aircraft.avionics.map((avionic) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('• $avionic', style: const TextStyle(fontSize: 14)),
                      )),
                      const SizedBox(height: 16),
                      const Text('Specifications:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...aircraft.specs.entries.map((spec) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('• ${spec.key}: ${spec.value}', style: const TextStyle(fontSize: 14)),
                      )),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            // TODO: Implement booking functionality
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Book This Charter'),
                        ),
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
    if (_error != null) {
      return AppScaffold(
        currentIndex: 2,
        child: NetworkErrorWidget(
          onRetry: _loadCharters,
          customMessage: _error,
        ),
      );
    }
    if (_charters.isEmpty && !_isLoading) {
      return AppScaffold(
        currentIndex: 2,
        child: EmptyState(
          title: 'No Charters Available',
          message: 'There are currently no charter aircraft available.',
          icon: Icons.flight_takeoff,
          onAction: _loadCharters,
          actionText: 'Refresh',
        ),
      );
    }
    return AppScaffold(
      currentIndex: 2,
      child: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Loading charters...',
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          const Text('Available Charters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Text('${_charters.length} charters', style: TextStyle(fontSize: 14, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: controller,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _charters.length,
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: CharterCard(aircraft: _charters[i]),
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
    );
  }
}

class CharterCard extends StatelessWidget {
  final Aircraft aircraft;
  const CharterCard({required this.aircraft, super.key});
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
                    '${aircraft.make} ${aircraft.model}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'CHARTER',
                    style: TextStyle(color: Colors.white, fontSize: 9),
                  ),
                ),
              ],
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
                Text(
                  '\$${aircraft.price}/hr',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.green,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    Text(
                      aircraft.rating.toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${aircraft.year} • ${aircraft.registration}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
} 
