import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pilots_lounge/models/flight_school.dart';        // new package name
import 'package:pilots_lounge/features/students/flight_school_card.dart';
import 'package:pilots_lounge/widgets/app_scaffold.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  // ignore: unused_field
  GoogleMapController? _mapController;

  final List<FlightSchool> _schools = [
    FlightSchool(
      id: '1',
      name: 'ATP – Scottsdale',
      lat: 33.6229,
      lng: -111.9102,
      rating: 4.6,
      price: 175,
      location: 'Scottsdale, AZ',
      curriculum: ['Private Pilot', 'Instrument Rating', 'Commercial Pilot'],
      planesAvailable: ['Cessna 172', 'Piper Arrow'],
      averageGraduationCost: 85000.0,
      reviews: [],
      lastUpdated: DateTime.now(),
    ),
    FlightSchool(
      id: '2',
      name: 'Chandler Flight School',
      lat: 33.2692,
      lng: -111.8108,
      rating: 4.8,
      price: 160,
      location: 'Chandler, AZ',
      curriculum: ['Private Pilot', 'Instrument Rating'],
      planesAvailable: ['Cessna 152', 'Cessna 172'],
      averageGraduationCost: 75000.0,
      reviews: [],
      lastUpdated: DateTime.now(),
    ),
    FlightSchool(
      id: '3',
      name: 'Mesa Gateway Aviation',
      lat: 33.3076,
      lng: -111.6556,
      rating: 4.5,
      price: 180,
      location: 'Mesa, AZ',
      curriculum: ['Private Pilot', 'Commercial Pilot', 'Multi-Engine'],
      planesAvailable: ['Cessna 172', 'Piper Seminole'],
      averageGraduationCost: 90000.0,
      reviews: [],
      lastUpdated: DateTime.now(),
    ),
  ];

  Set<Marker> get _markers => _schools.map((s) {
        return Marker(
          markerId: MarkerId(s.id),
          position: LatLng(s.lat, s.lng),
          infoWindow: InfoWindow(title: s.name),
        );
      }).toSet();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 1,
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
        ],
      ),
    );
  }
}
