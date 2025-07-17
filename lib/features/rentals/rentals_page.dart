// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pilots_lounge/models/aircraft.dart';
import 'package:pilots_lounge/services/firestore/firestore_service.dart';
import 'package:pilots_lounge/services/map_icons.dart';
import 'package:pilots_lounge/services/placeholder_images.dart';
import 'package:pilots_lounge/widgets/app_scaffold.dart';
import 'package:pilots_lounge/widgets/arrow_navigation.dart';
import 'package:pilots_lounge/widgets/loading_overlay.dart';
import 'package:pilots_lounge/widgets/error_widgets.dart';

class RentalsPage extends StatefulWidget {
  const RentalsPage({super.key});

  @override
  State<RentalsPage> createState() => _RentalsPageState();
}

class _RentalsPageState extends State<RentalsPage> {
  // ignore: unused_field
  GoogleMapController? _mapController;
  final FirestoreService _firestoreService = FirestoreService();
  final ScrollController _scrollController = ScrollController();
  List<Aircraft> _aircraft = [];
  bool _isLoading = true;
  String? _error;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAircraft();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToPrevious() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _scrollToIndex(_currentIndex);
    }
  }

  void _scrollToNext() {
    if (_currentIndex < _aircraft.length - 1) {
      _currentIndex++;
      _scrollToIndex(_currentIndex);
    }
  }

  void _scrollToIndex(int index) {
    if (_scrollController.hasClients) {
      final itemWidth = 292.0; // 280 (card width) + 12 (padding)
      _scrollController.animateTo(
        index * itemWidth,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _loadAircraft() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final aircraft = await _firestoreService.getAircraftForRent();
      setState(() {
        _aircraft = aircraft;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load aircraft: $e';
        _isLoading = false;
      });
    }
  }

  Set<Marker> get _markers => _aircraft.map((a) {
        return Marker(
          markerId: MarkerId(a.id),
          position: LatLng(a.lat, a.lng),
          icon: MapIcons.getRentalIcon(),
          infoWindow: InfoWindow(
            title: '${a.make} ${a.model}',
            snippet: '\$${a.price}/hr',
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
                        'Registration: ${aircraft.registration}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Year: ${aircraft.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Location: ${aircraft.location}',
                        style: const TextStyle(fontSize: 16),
                      ),
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
                      const Text(
                        'Avionics:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...aircraft.avionics.map((avionic) => 
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• $avionic', style: const TextStyle(fontSize: 14)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Specifications:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...aircraft.specs.entries.map((spec) => 
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• ${spec.key}: ${spec.value}', style: const TextStyle(fontSize: 14)),
                        ),
                      ),
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
                          child: const Text('Book This Aircraft'),
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
        currentIndex: 0,
        child: NetworkErrorWidget(
          onRetry: _loadAircraft,
          customMessage: _error,
        ),
      );
    }

    if (_aircraft.isEmpty && !_isLoading) {
      return AppScaffold(
        currentIndex: 0,
        child: EmptyState(
          title: 'No Aircraft Available',
          message: 'There are currently no aircraft available for rent in your area.',
          icon: Icons.flight,
          onAction: _loadAircraft,
          actionText: 'Refresh',
        ),
      );
    }

    return AppScaffold(
      currentIndex: 0,
      child: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Loading aircraft...',
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
                    // Header with navigation
                    ArrowNavigation(
                      title: 'Aircraft Rentals',
                      itemCount: _aircraft.length,
                      onPrevious: _aircraft.length > 1 ? _scrollToPrevious : null,
                      onNext: _aircraft.length > 1 ? _scrollToNext : null,
                    ),
                    // Cards
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _aircraft.length,
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: AircraftCard(aircraft: _aircraft[i]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
                    // Header with navigation
                    ArrowNavigation(
                      title: 'Aircraft Rentals',
                      itemCount: _aircraft.length,
                      onPrevious: _aircraft.length > 1 ? _scrollToPrevious : null,
                      onNext: _aircraft.length > 1 ? _scrollToNext : null,
                    ),
          ],
        ),
      ),
    );
  }
}

class AircraftCard extends StatelessWidget {
  final Aircraft aircraft;
  
  const AircraftCard({required this.aircraft, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        width: 280,
        height: 180, // Fixed height to prevent overflow
        padding: const EdgeInsets.all(12),
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
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'RENTAL',
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
