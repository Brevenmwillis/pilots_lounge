import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pilots_lounge/models/aircraft.dart';
import 'package:pilots_lounge/services/map_icons.dart';
import 'package:pilots_lounge/services/placeholder_images.dart';
import 'package:pilots_lounge/services/firestore/data_service.dart';
import 'package:pilots_lounge/services/firestore/firestore_service.dart';
import 'package:pilots_lounge/widgets/loading_overlay.dart';
import 'package:pilots_lounge/widgets/error_widgets.dart';
import 'package:pilots_lounge/widgets/app_scaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pilots_lounge/widgets/centered_dialog.dart';

class AirplanesSalePage extends StatefulWidget {
  const AirplanesSalePage({super.key});

  @override
  State<AirplanesSalePage> createState() => _AirplanesSalePageState();
}

class _AirplanesSalePageState extends State<AirplanesSalePage> {
  // ignore: unused_field
  GoogleMapController? _mapController;
  final DataService _dataService = DataService();
  List<Aircraft> _aircraftForSale = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAircraftForSale();
  }

  Future<void> _loadAircraftForSale() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final aircraft = await _dataService.getAircraftForSale();
      setState(() {
        _aircraftForSale = aircraft;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load aircraft for sale: $e';
        _isLoading = false;
      });
    }
  }

  Set<Marker> get _markers => _aircraftForSale.map((a) {
        return Marker(
          markerId: MarkerId(a.id),
          position: LatLng(a.lat, a.lng),
          icon: MapIcons.getSaleIcon(),
          infoWindow: InfoWindow(
            title: '${a.make} ${a.model}',
            snippet: '\$${a.price}',
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
              // Aircraft image placeholder
              Padding(
                padding: const EdgeInsets.all(16),
                child: PlaceholderImages.getSalePlaceholder(),
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
                        '\$${aircraft.price}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Location: ${aircraft.location}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Year: ${aircraft.year}',
                        style: const TextStyle(fontSize: 16),
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
                      ...aircraft.specs.entries.map((entry) => 
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('${entry.key}: ${entry.value}', style: const TextStyle(fontSize: 14)),
                        ),
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
                        'Payment Methods:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...aircraft.paymentMethods.map((method) => 
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• $method', style: const TextStyle(fontSize: 14)),
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
                                // Connect with mechanics for pre-buy
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('Pre-Buy Inspection'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Contact seller
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Contact Seller'),
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

  void _showAircraftForm({Aircraft? aircraft}) {
    CenteredDialog.show(
      context: context,
      child: AircraftForm(
        aircraft: aircraft,
        onSaved: (newAircraft) async {
          Navigator.of(context).pop();
          await _loadAircraftForSale();
        },
      ),
    );
  }

  // ignore: unused_element
  void _deleteAircraft(Aircraft aircraft) async {
    try {
      await FirestoreService().deleteAircraftListing(aircraft.id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing deleted successfully!')));
      await _loadAircraftForSale();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting listing: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return AppScaffold(
        currentIndex: 4,
        child: NetworkErrorWidget(
          onRetry: _loadAircraftForSale,
          customMessage: _error,
        ),
      );
    }
    if (_aircraftForSale.isEmpty && !_isLoading) {
      return AppScaffold(
        currentIndex: 4,
        child: EmptyState(
          title: 'No Aircraft for Sale',
          message: 'There are currently no aircraft for sale available.',
          icon: Icons.airplanemode_active,
          onAction: _loadAircraftForSale,
          actionText: 'Refresh',
        ),
      );
    }
    return AppScaffold(
      currentIndex: 4,
      child: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Loading aircraft for sale...',
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
                        itemCount: _aircraftForSale.length,
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: AircraftSaleCard(aircraft: _aircraftForSale[i]),
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
                onPressed: () => _showAircraftForm(),
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AircraftSaleCard extends StatelessWidget {
  final Aircraft aircraft;
  
  const AircraftSaleCard({required this.aircraft, super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isOwner = user != null && user.uid == aircraft.ownerId;
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
                    '${aircraft.make} ${aircraft.model}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isOwner) ...[
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () {
                      // Open edit form
                      CenteredDialog.show(
                        context: context,
                        child: AircraftForm(
                          aircraft: aircraft,
                          onSaved: (updatedAircraft) async {
                            Navigator.of(context).pop();
                            // Refresh the page data
                            if (context.mounted) {
                              final state = context.findAncestorStateOfType<_AirplanesSalePageState>();
                              state?._loadAircraftForSale();
                            }
                          },
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18),
                    onPressed: () async {
                      // Confirm and delete
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Listing'),
                          content: const Text('Are you sure you want to delete this listing?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        try {
                          await FirestoreService().deleteAircraftListing(aircraft.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing deleted successfully!')));
                            final state = context.findAncestorStateOfType<_AirplanesSalePageState>();
                            state?._loadAircraftForSale();
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting listing: $e')));
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
              '\$${aircraft.price}',
              style: const TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.bold),
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
                const Icon(Icons.star, size: 12, color: Colors.amber),
                Text('${aircraft.rating}', style: const TextStyle(fontSize: 11)),
                const SizedBox(width: 4),
                Text('(${aircraft.reviews.length} reviews)', 
                     style: const TextStyle(fontSize: 9, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'TT: ${aircraft.specs['TT']} | SMOH: ${aircraft.specs['SMOH']}', 
              style: const TextStyle(fontSize: 9),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Connect with mechanics for pre-buy
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                    child: const Text('Pre-Buy', style: TextStyle(fontSize: 11)),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Contact seller
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                    child: const Text('Contact', style: TextStyle(fontSize: 11)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 

class AircraftForm extends StatefulWidget {
  final Aircraft? aircraft;
  final Future<void> Function(Aircraft) onSaved;
  const AircraftForm({this.aircraft, required this.onSaved, super.key});
  @override
  State<AircraftForm> createState() => _AircraftFormState();
}

class _AircraftFormState extends State<AircraftForm> {
  final _formKey = GlobalKey<FormState>();
  final _registrationController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _bookingWebsiteController = TextEditingController();
  final _insuranceRequirementsController = TextEditingController();
  final _insuranceDeductibleController = TextEditingController();
  
  final List<String> _avionics = [];
  final Map<String, String> _specs = {};
  final List<String> _paymentMethods = [];
  
  bool _internationalFlights = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.aircraft != null) {
      _registrationController.text = widget.aircraft!.registration;
      _makeController.text = widget.aircraft!.make;
      _modelController.text = widget.aircraft!.model;
      _yearController.text = widget.aircraft!.year.toString();
      _priceController.text = widget.aircraft!.price.toString();
      _locationController.text = widget.aircraft!.location;
      _latController.text = widget.aircraft!.lat.toString();
      _lngController.text = widget.aircraft!.lng.toString();
      _bookingWebsiteController.text = widget.aircraft!.bookingWebsite;
      _insuranceRequirementsController.text = widget.aircraft!.insuranceRequirements;
      _insuranceDeductibleController.text = widget.aircraft!.insuranceDeductible.toString();
      _avionics.addAll(widget.aircraft!.avionics);
      _specs.addAll(widget.aircraft!.specs);
      _paymentMethods.addAll(widget.aircraft!.paymentMethods);
      _internationalFlights = widget.aircraft!.internationalFlights;
    }
  }

  @override
  void dispose() {
    _registrationController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _bookingWebsiteController.dispose();
    _insuranceRequirementsController.dispose();
    _insuranceDeductibleController.dispose();
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

      final aircraft = Aircraft(
        id: widget.aircraft?.id ?? '',
        registration: _registrationController.text,
        make: _makeController.text,
        model: _modelController.text,
        year: int.parse(_yearController.text),
        price: double.parse(_priceController.text),
        location: _locationController.text,
        lat: double.tryParse(_latController.text) ?? 0.0,
        lng: double.tryParse(_lngController.text) ?? 0.0,
        avionics: List.from(_avionics),
        specs: Map.from(_specs),
        rating: widget.aircraft?.rating ?? 0.0,
        reviews: widget.aircraft?.reviews ?? [],
        ownerId: user.uid,
        bookingWebsite: _bookingWebsiteController.text,
        paymentMethods: List.from(_paymentMethods),
        insuranceRequirements: _insuranceRequirementsController.text,
        insuranceDeductible: double.tryParse(_insuranceDeductibleController.text) ?? 0.0,
        internationalFlights: _internationalFlights,
        lastUpdated: DateTime.now(),
        isActive: true,
        type: 'sale',
      );

      if (widget.aircraft != null) {
        // Update existing
        await FirestoreService().updateAircraftListing(aircraft.id, aircraft.toFirestore());
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing updated successfully!')));
      } else {
        // Create new
        await FirestoreService().createAircraftListing(aircraft);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing created successfully!')));
      }

      await widget.onSaved(aircraft);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addAvionic() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Avionic'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Avionic name'),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              setState(() => _avionics.add(value));
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
                setState(() => _avionics.add(controller.text));
              }
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addSpec() {
    String key = '', value = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Specification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Specification name'),
              onChanged: (v) => key = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Value'),
              onChanged: (v) => value = v,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (key.isNotEmpty && value.isNotEmpty) {
                setState(() => _specs[key] = value);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addPaymentMethod() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Payment Method'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Payment method'),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              setState(() => _paymentMethods.add(value));
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
                setState(() => _paymentMethods.add(controller.text));
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
                widget.aircraft != null ? 'Edit Aircraft Listing' : 'Create Aircraft Listing',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Basic Information
              const Text('Basic Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _registrationController,
                decoration: const InputDecoration(labelText: 'Registration *'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _makeController,
                      decoration: const InputDecoration(labelText: 'Make *'),
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(labelText: 'Model *'),
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      decoration: const InputDecoration(labelText: 'Year *'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v?.isEmpty == true || int.tryParse(v!) == null ? 'Valid year required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Price *'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v?.isEmpty == true || double.tryParse(v!) == null ? 'Valid price required' : null,
                    ),
                  ),
                ],
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
              
              // Avionics
              Row(
                children: [
                  const Text('Avionics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addAvionic,
                  ),
                ],
              ),
              if (_avionics.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...(_avionics.map((avionic) => Chip(
                  label: Text(avionic),
                  onDeleted: () => setState(() => _avionics.remove(avionic)),
                ))),
              ],
              
              const SizedBox(height: 16),
              
              // Specifications
              Row(
                children: [
                  const Text('Specifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addSpec,
                  ),
                ],
              ),
              if (_specs.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...(_specs.entries.map((entry) => Chip(
                  label: Text('${entry.key}: ${entry.value}'),
                  onDeleted: () => setState(() => _specs.remove(entry.key)),
                ))),
              ],
              
              const SizedBox(height: 16),
              
              // Payment Methods
              Row(
                children: [
                  const Text('Payment Methods', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addPaymentMethod,
                  ),
                ],
              ),
              if (_paymentMethods.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...(_paymentMethods.map((method) => Chip(
                  label: Text(method),
                  onDeleted: () => setState(() => _paymentMethods.remove(method)),
                ))),
              ],
              
              const SizedBox(height: 16),
              
              // Additional Information
              const Text('Additional Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bookingWebsiteController,
                decoration: const InputDecoration(labelText: 'Booking Website'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _insuranceRequirementsController,
                decoration: const InputDecoration(labelText: 'Insurance Requirements'),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _insuranceDeductibleController,
                decoration: const InputDecoration(labelText: 'Insurance Deductible'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text('International Flights Available'),
                value: _internationalFlights,
                onChanged: (value) => setState(() => _internationalFlights = value ?? false),
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
                        : Text(widget.aircraft != null ? 'Update' : 'Create'),
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
