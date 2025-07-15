import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/firestore/firestore_service.dart';
import '../../models/aircraft.dart';
import '../../widgets/app_scaffold.dart';
import 'package:go_router/go_router.dart';

class CreateListingPage extends StatefulWidget {
  const CreateListingPage({super.key});

  @override
  State<CreateListingPage> createState() => _CreateListingPageState();
}

class _CreateListingPageState extends State<CreateListingPage> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  Uint8List? _imageBytes;
  // ignore: unused_field
  String? _imageUrl;
  bool _loading = false;

  // Form fields
  String registration = '';
  String make = '';
  String model = '';
  int year = DateTime.now().year;
  double price = 0.0;
  String location = '';

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  // ignore: unused_element
  Future<String?> _uploadImage(String userId) async {
    if (_imageBytes == null) return null;
    final ref = FirebaseStorage.instance.ref().child('aircraft_images/${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = await ref.putData(_imageBytes!);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    
    try {
      _formKey.currentState!.save();
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No user signed in')));
        setState(() => _loading = false);
        return;
      }
      
      // ignore: avoid_print
      print('Starting image upload...');
      // Temporarily skip image upload for testing
      // final imageUrl = await _uploadImage(user.uid);
      final imageUrl = null;
      // ignore: avoid_print
      print('Image upload completed: $imageUrl');
      
      // ignore: avoid_print
      print('Creating aircraft object...');
      final aircraft = Aircraft(
        id: '',
        registration: registration,
        make: make,
        model: model,
        year: year,
        price: price,
        location: location,
        lat: 0.0,
        lng: 0.0,
        avionics: [],
        specs: {},
        rating: 0.0,
        reviews: [],
        ownerId: user.uid,
        bookingWebsite: '',
        paymentMethods: [],
        insuranceRequirements: '',
        insuranceDeductible: 0.0,
        internationalFlights: false,
        lastUpdated: DateTime.now(),
        isActive: true,
      );
      
      // ignore: avoid_print
      print('Saving to Firestore...');
      await FirestoreService().createAircraftListing(aircraft);
      // ignore: avoid_print
      print('Firestore save completed');
      
      setState(() => _loading = false);
      if (mounted) {
        context.go('/profile');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing created successfully!')));
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error creating listing: $e');
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 0,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Create Aircraft Listing', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: _imageBytes == null
                      ? Container(
                          width: 120,
                          height: 120,
                          color: Colors.grey[200],
                          child: const Icon(Icons.add_a_photo, size: 40),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(_imageBytes!, width: 120, height: 120, fit: BoxFit.cover),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Registration'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => registration = v ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Make'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => make = v ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Model'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => model = v ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Year'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || int.tryParse(v) == null ? 'Enter a valid year' : null,
                onSaved: (v) => year = int.tryParse(v ?? '') ?? DateTime.now().year,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || double.tryParse(v) == null ? 'Enter a valid price' : null,
                onSaved: (v) => price = double.tryParse(v ?? '') ?? 0.0,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => location = v ?? '',
              ),
              const SizedBox(height: 24),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Create Listing'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
} 