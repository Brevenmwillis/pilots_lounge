// ignore: unnecessary_import
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapIcons {
  static BitmapDescriptor? _rentalIcon;
  static BitmapDescriptor? _charterIcon;
  static BitmapDescriptor? _instructorIcon;
  static BitmapDescriptor? _saleIcon;
  static BitmapDescriptor? _schoolIcon;
  static BitmapDescriptor? _mechanicIcon;
  static BitmapDescriptor? _airportIcon;

  // Initialize all icons
  static Future<void> initializeIcons() async {
    try {
      _rentalIcon = await _createCustomIcon(Icons.flight, Colors.blue);
      _charterIcon = await _createCustomIcon(Icons.airplane_ticket, Colors.green);
      _instructorIcon = await _createCustomIcon(Icons.school, Colors.orange);
      _saleIcon = await _createCustomIcon(Icons.sell, Colors.purple);
      _schoolIcon = await _createCustomIcon(Icons.account_balance, Colors.teal);
      _mechanicIcon = await _createCustomIcon(Icons.build, Colors.red);
      _airportIcon = await _createCustomIcon(Icons.place, Colors.indigo);
    } catch (e) {
      // If custom icon creation fails, use default markers
      if (kDebugMode) {
        // ignore: avoid_print
        print('Failed to create custom icons: $e');
      }
    }
  }

  // Get icon for different types
  static BitmapDescriptor getRentalIcon() => _rentalIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  static BitmapDescriptor getCharterIcon() => _charterIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
  static BitmapDescriptor getInstructorIcon() => _instructorIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
  static BitmapDescriptor getSaleIcon() => _saleIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
  static BitmapDescriptor getSchoolIcon() => _schoolIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
  static BitmapDescriptor getMechanicIcon() => _mechanicIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
  static BitmapDescriptor getAirportIcon() => _airportIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);

  // Create custom icon from Flutter icon
  static Future<BitmapDescriptor> _createCustomIcon(IconData iconData, Color color) async {
    try {
      final pictureRecorder = ui.PictureRecorder();
      final canvas = Canvas(pictureRecorder);
      const size = Size(48, 48);
      
      // Draw background circle
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(const Offset(24, 24), 24, paint);
      
      // Draw white border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(const Offset(24, 24), 22, borderPaint);
      
      // Draw icon
      // ignore: unused_local_variable
      final iconPaint = Paint()..color = Colors.white;
      final iconSize = 24.0;
      final iconOffset = Offset((size.width - iconSize) / 2, (size.height - iconSize) / 2);
      
      final iconSpan = TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          fontSize: iconSize,
          fontFamily: iconData.fontFamily,
          package: iconData.fontPackage,
          color: Colors.white,
        ),
      );
      
      final textPainter = TextPainter(
        text: iconSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, iconOffset);
      
      final picture = pictureRecorder.endRecording();
      final image = await picture.toImage(48, 48);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        throw Exception('Failed to convert image to bytes');
      }
      
      final bytes = byteData.buffer.asUint8List();
      
      // ignore: deprecated_member_use
      return BitmapDescriptor.fromBytes(bytes);
    } catch (e) {
      // Return default marker if custom icon creation fails
      // ignore: avoid_print
      print('Failed to create custom icon: $e');
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    }
  }

  // Helper method to load asset as BitmapDescriptor (for future use with custom PNG files)
  // ignore: unused_element
  static Future<BitmapDescriptor> _getBitmapDescriptorFromAssetBytes(String path) async {
    try {
      // ignore: deprecated_member_use
      return await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        path,
      );
    } catch (e) {
      // Return default marker if asset loading fails
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    }
  }

  // Alternative method using network images (if you want to load from URLs)
  static Future<BitmapDescriptor> getNetworkIcon(String imageUrl) async {
    try {
      final bytes = await _getImageBytesFromNetwork(imageUrl);
      if (bytes == null) {
        throw Exception('Failed to load network image');
      }
      // ignore: deprecated_member_use, await_only_futures
      return await BitmapDescriptor.fromBytes(bytes);
    } catch (e) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    }
  }

  static Future<Uint8List?> _getImageBytesFromNetwork(String imageUrl) async {
    try {
      final response = await NetworkAssetBundle(Uri.parse(imageUrl)).load(imageUrl);
      return response.buffer.asUint8List();
    } catch (e) {
      // If network image loading fails, use default markers
      if (kDebugMode) {
        // ignore: avoid_print
        print('Failed to load network image: $e');
      }
      return null;
    }
  }
} 
