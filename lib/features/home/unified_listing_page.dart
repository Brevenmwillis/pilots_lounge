import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:pilots_lounge/models/aircraft.dart';
import 'package:pilots_lounge/models/instructor.dart';
import 'package:pilots_lounge/models/mechanic.dart';
import 'package:pilots_lounge/services/firestore/firestore_service.dart';
import 'package:pilots_lounge/widgets/app_scaffold.dart';

enum ListingType { rental, charter, instructor, mechanic }

class UnifiedListingPage extends StatefulWidget {
  final ListingType listingType;
  
  const UnifiedListingPage({required this.listingType, super.key});

  @override
  State<UnifiedListingPage> createState() => _UnifiedListingPageState();
}

class _UnifiedListingPageState extends State<UnifiedListingPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Common fields
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _contactInfoController = TextEditingController();

  // Aircraft-specific fields
  final _registrationController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _priceController = TextEditingController();
  final _bookingWebsiteController = TextEditingController();
  final _insuranceRequirementsController = TextEditingController();
  final _insuranceDeductibleController = TextEditingController();

  // Instructor-specific fields
  String _selectedInstructorType = 'CFI';
  final List<String> _endorsements = [];
  final List<String> _preferredLocations = [];
  bool _contactThroughApp = true;

  // Mechanic-specific fields
  final List<String> _specializations = [];
  final Map<String, double> _averageQuotes = {};
  bool _travels = false;

  // Common lists
  final List<String> _avionics = [];
  final Map<String, String> _specs = {};
  final List<String> _paymentMethods = [];
  bool _internationalFlights = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _contactInfoController.dispose();
    _registrationController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _priceController.dispose();
    _bookingWebsiteController.dispose();
    _insuranceRequirementsController.dispose();
    _insuranceDeductibleController.dispose();
    super.dispose();
  }

  String get _pageTitle {
    switch (widget.listingType) {
      case ListingType.rental:
        return 'Create Aircraft Rental';
      case ListingType.charter:
        return 'Create Charter Service';
      case ListingType.instructor:
        return 'Create Instructor Listing';
      case ListingType.mechanic:
        return 'Create Mechanic Listing';
    }
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

      switch (widget.listingType) {
        case ListingType.rental:
        case ListingType.charter:
          await _saveAircraft(user.uid);
          break;
        case ListingType.instructor:
          await _saveInstructor(user.uid);
          break;
        case ListingType.mechanic:
          await _saveMechanic(user.uid);
          break;
      }

      if (mounted) {
        context.go('/profile');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing created successfully!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAircraft(String userId) async {
    final aircraft = Aircraft(
      id: '',
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
      rating: 0.0,
      reviews: [],
      ownerId: userId,
      bookingWebsite: _bookingWebsiteController.text,
      paymentMethods: List.from(_paymentMethods),
      insuranceRequirements: _insuranceRequirementsController.text,
      insuranceDeductible: double.tryParse(_insuranceDeductibleController.text) ?? 0.0,
      internationalFlights: _internationalFlights,
      lastUpdated: DateTime.now(),
      isActive: true,
      type: widget.listingType == ListingType.rental ? 'rental' : 'charter',
    );

    await FirestoreService().createAircraftListing(aircraft);
  }

  Future<void> _saveInstructor(String userId) async {
    final instructor = Instructor(
      id: '',
      name: _nameController.text,
      type: _selectedInstructorType,
      location: _locationController.text,
      lat: double.tryParse(_latController.text) ?? 0.0,
      lng: double.tryParse(_lngController.text) ?? 0.0,
      preferredLocations: List.from(_preferredLocations),
      endorsements: List.from(_endorsements),
      rating: 0.0,
      reviews: [],
      contactInfo: _contactInfoController.text.isEmpty ? null : _contactInfoController.text,
      contactThroughApp: _contactThroughApp,
      lastUpdated: DateTime.now(),
      isActive: true,
    );

    await FirestoreService().createInstructor(instructor);
  }

  Future<void> _saveMechanic(String userId) async {
    final mechanic = Mechanic(
      id: '',
      name: _nameController.text,
      location: _locationController.text,
      lat: double.tryParse(_latController.text) ?? 0.0,
      lng: double.tryParse(_lngController.text) ?? 0.0,
      specializations: List.from(_specializations),
      averageQuotes: Map.from(_averageQuotes),
      contactInfo: _contactInfoController.text,
      travels: _travels,
      rating: 0.0,
      reviews: [],
      lastUpdated: DateTime.now(),
      isActive: true,
    );

    await FirestoreService().createMechanic(mechanic);
  }

  void _addItem(List<String> list, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $title'),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(labelText: title),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              setState(() => list.add(value));
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
                setState(() => list.add(controller.text));
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
    return AppScaffold(
      currentIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_pageTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/listing-type-selection'),
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Common fields
                const Text('Basic Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                if (widget.listingType == ListingType.instructor || widget.listingType == ListingType.mechanic) ...[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name *'),
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                ],
                
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Location *'),
                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                
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

                // Aircraft-specific fields
                if (widget.listingType == ListingType.rental || widget.listingType == ListingType.charter) ...[
                  const Text('Aircraft Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _registrationController,
                    decoration: const InputDecoration(labelText: 'Registration *'),
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  
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
                  const SizedBox(height: 16),
                  
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
                  const SizedBox(height: 16),
                  
                  // Avionics
                  Row(
                    children: [
                      const Text('Avionics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _addItem(_avionics, 'Avionic'),
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
                        onPressed: () => _addItem(_paymentMethods, 'Payment Method'),
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
                ],

                // Instructor-specific fields
                if (widget.listingType == ListingType.instructor) ...[
                  const Text('Instructor Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: _selectedInstructorType,
                    decoration: const InputDecoration(labelText: 'Type *'),
                    items: const [
                      DropdownMenuItem(value: 'CFI', child: Text('CFI')),
                      DropdownMenuItem(value: 'DPE', child: Text('DPE')),
                    ],
                    onChanged: (value) => setState(() => _selectedInstructorType = value!),
                  ),
                  const SizedBox(height: 16),
                  
                  // Endorsements
                  Row(
                    children: [
                      const Text('Endorsements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _addItem(_endorsements, 'Endorsement'),
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
                        onPressed: () => _addItem(_preferredLocations, 'Location'),
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
                ],

                // Mechanic-specific fields
                if (widget.listingType == ListingType.mechanic) ...[
                  const Text('Mechanic Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // Specializations
                  Row(
                    children: [
                      const Text('Specializations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _addItem(_specializations, 'Specialization'),
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
                ],

                const SizedBox(height: 32),
                
                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Create Listing'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 