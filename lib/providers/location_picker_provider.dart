import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iu_job_assessment/models/location_model.dart';
import 'package:iu_job_assessment/services/location_service.dart';

/// Provider for location picker functionality
class LocationPickerProvider extends StateNotifier<LocationPickerState> {
  final LocationService _locationService;

  LocationPickerProvider(this._locationService)
    : super(const LocationPickerState());

  /// Initialize with current location
  Future<void> initializeLocation() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Check and request permission first
      final hasPermission = await _locationService
          .isLocationPermissionGranted();
      if (!hasPermission) {
        final granted = await _locationService.requestLocationPermission();
        if (!granted) {
          state = state.copyWith(
            error: 'Location permission is required to use this feature',
            isLoading: false,
          );
          return;
        }
      }

      final currentLocation = await _locationService.getCurrentLocation();
      state = state.copyWith(
        currentLocation: currentLocation,
        selectedLocation: currentLocation,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to get current location: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  /// Select location by tapping on map
  Future<void> selectLocationFromMap(double latitude, double longitude) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final locationData = await _locationService.reverseGeocode(
        latitude,
        longitude,
      );
      if (locationData != null) {
        state = state.copyWith(
          selectedLocation: locationData,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: 'Could not get address for this location',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to get address: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  /// Search for places
  Future<void> searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      state = state.clearSuggestions();
      return;
    }

    state = state.copyWith(isSearching: true, error: null);

    try {
      final suggestions = await _locationService.searchPlaces(query);
      state = state.copyWith(
        searchSuggestions: suggestions,
        isSearching: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Search failed: ${e.toString()}',
        isSearching: false,
        searchSuggestions: [],
      );
    }
  }

  /// Select location from search suggestion
  Future<void> selectLocationFromSearch(PlaceSuggestion suggestion) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final locationData = await _locationService.getPlaceDetails(
        suggestion.placeId,
      );
      if (locationData != null) {
        state = state.copyWith(
          selectedLocation: locationData,
          searchSuggestions: [],
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: 'Could not get details for this place',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to get place details: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  /// Clear search suggestions
  void clearSearchSuggestions() {
    state = state.clearSuggestions();
  }

  /// Clear error
  void clearError() {
    state = state.clearError();
  }

  /// Reset to initial state
  void reset() {
    state = const LocationPickerState();
  }
}

/// Providers for location picker
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final locationPickerProvider =
    StateNotifierProvider<LocationPickerProvider, LocationPickerState>((ref) {
      final locationService = ref.watch(locationServiceProvider);
      return LocationPickerProvider(locationService);
    });

/// Provider for checking if location is selected and valid
final isLocationSelectedProvider = Provider<bool>((ref) {
  final state = ref.watch(locationPickerProvider);
  return state.selectedLocation != null;
});

/// Provider for selected location display text
final selectedLocationTextProvider = Provider<String>((ref) {
  final state = ref.watch(locationPickerProvider);
  return state.selectedLocation?.displayAddress ?? '';
});
