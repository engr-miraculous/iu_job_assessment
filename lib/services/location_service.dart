import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:iu_job_assessment/models/location_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

/// Service for handling real location operations
class LocationService {
  static const LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  const LocationService._internal();

  // This should not be on mobile, but somwhere on the server for security.
  static const String _googlePlacesApiKey =
      'AIzaSyD7emBLlRin5F7q3iRZ4mCrIBd25uhv8y8';
  static const String _placesBaseUrl =
      'https://maps.googleapis.com/maps/api/place';

  /// Get current device location
  Future<LocationData?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 0,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Reverse geocode to get address
      return await reverseGeocode(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  /// Reverse geocode coordinates to address
  Future<LocationData?> reverseGeocode(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        // Function to count non-empty components
        int countAddressComponents(Placemark placemark) {
          int count = 0;
          if (placemark.thoroughfare?.isNotEmpty == true) count++;
          if (placemark.subThoroughfare?.isNotEmpty == true) count++;
          if (placemark.subLocality?.isNotEmpty == true) count++;
          if (placemark.subAdministrativeArea?.isNotEmpty == true) count++;
          if (placemark.street?.isNotEmpty == true) count++;
          if (placemark.subLocality?.isNotEmpty == true) count++;
          if (placemark.locality?.isNotEmpty == true) count++;
          if (placemark.subAdministrativeArea?.isNotEmpty == true) count++;
          if (placemark.administrativeArea?.isNotEmpty == true) count++;
          if (placemark.postalCode?.isNotEmpty == true) count++;
          if (placemark.country?.isNotEmpty == true) count++;
          return count;
        }

        // Sort by descending number of components
        final placemark = placemarks.reduce(
          (a, b) =>
              countAddressComponents(a) >= countAddressComponents(b) ? a : b,
        );

        // Build formatted address
        List<String> addressParts = [];
        if (placemark.street?.isNotEmpty == true) {
          addressParts.add(placemark.street!);
        }
        if (placemark.locality?.isNotEmpty == true) {
          addressParts.add(placemark.locality!);
        }
        if (placemark.administrativeArea?.isNotEmpty == true) {
          addressParts.add(placemark.administrativeArea!);
        }
        if (placemark.country?.isNotEmpty == true) {
          addressParts.add(placemark.country!);
        }

        final address = addressParts.join(', ');

        return LocationData(
          latitude: latitude,
          longitude: longitude,
          address: address,
          formattedAddress: address,
          locality: placemark.locality,
          administrativeArea: placemark.administrativeArea,
          country: placemark.country,
          postalCode: placemark.postalCode,
        );
      }

      return LocationData(
        latitude: latitude,
        longitude: longitude,
        address: 'Unknown location',
      );
    } catch (e) {
      debugPrint('Error reverse geocoding: $e');
      return LocationData(
        latitude: latitude,
        longitude: longitude,
        address:
            'Lat: ${latitude.toStringAsFixed(4)}, Lng: ${longitude.toStringAsFixed(4)}',
      );
    }
  }

  /// Search for places using Google Places API
  Future<List<PlaceSuggestion>> searchPlaces(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      // Using Nigeria as the region bias
      final String url =
          '$_placesBaseUrl/autocomplete/json'
          '?input=${Uri.encodeComponent(query)}'
          '&key=$_googlePlacesApiKey'
          '&components=country:ng' // Restricting to Nigeria
          '&language=en';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final predictions = data['predictions'] as List;

        return predictions.map((prediction) {
          final description = prediction['description'] as String;
          final structuredFormatting = prediction['structured_formatting'];

          return PlaceSuggestion(
            placeId: prediction['place_id'] as String,
            description: description,
            mainText: structuredFormatting?['main_text'] as String?,
            secondaryText: structuredFormatting?['secondary_text'] as String?,
          );
        }).toList();
      } else {
        debugPrint('Places API error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error searching places: $e');
      return [];
    }
  }

  /// Get place details from place ID
  Future<LocationData?> getPlaceDetails(String placeId) async {
    try {
      final String url =
          '$_placesBaseUrl/details/json'
          '?place_id=$placeId'
          '&key=$_googlePlacesApiKey'
          '&fields=geometry,formatted_address,address_components';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = data['result'];

        if (result != null) {
          final geometry = result['geometry'];
          final location = geometry['location'];
          final addressComponents = result['address_components'] as List;

          // Extract address components
          String? locality;
          String? administrativeArea;
          String? country;
          String? postalCode;

          for (final component in addressComponents) {
            final types = component['types'] as List;
            final longName = component['long_name'] as String;

            if (types.contains('locality')) {
              locality = longName;
            } else if (types.contains('administrative_area_level_1')) {
              administrativeArea = longName;
            } else if (types.contains('country')) {
              country = longName;
            } else if (types.contains('postal_code')) {
              postalCode = longName;
            }
          }

          return LocationData(
            latitude: location['lat'].toDouble(),
            longitude: location['lng'].toDouble(),
            address: result['formatted_address'] as String,
            formattedAddress: result['formatted_address'] as String,
            locality: locality,
            administrativeArea: administrativeArea,
            country: country,
            postalCode: postalCode,
          );
        }
      } else {
        debugPrint('Place details API error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting place details: $e');
    }
    return null;
  }

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Check if location permission is granted
  Future<bool> isLocationPermissionGranted() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  // Get current position with proper error handling
  Future<Position> getCurrentPosition() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceException('Location services are disabled');
    }

    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationServiceException('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationServiceException(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // Get current position
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 0,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      throw LocationServiceException('Failed to get current location: $e');
    }
  }
}

// Custom exception for location service errors
class LocationServiceException implements Exception {
  final String message;

  LocationServiceException(this.message);

  @override
  String toString() => 'LocationServiceException: $message';
}
