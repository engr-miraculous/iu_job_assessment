/// Represents a geographic location with coordinates and address
class LocationData {
  final double latitude;
  final double longitude;
  final String address;
  final String? formattedAddress;
  final String? locality; // City
  final String? administrativeArea; // State
  final String? country;
  final String? postalCode;

  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.formattedAddress,
    this.locality,
    this.administrativeArea,
    this.country,
    this.postalCode,
  });

  LocationData copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? formattedAddress,
    String? locality,
    String? administrativeArea,
    String? country,
    String? postalCode,
  }) {
    return LocationData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      formattedAddress: formattedAddress ?? this.formattedAddress,
      locality: locality ?? this.locality,
      administrativeArea: administrativeArea ?? this.administrativeArea,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
    );
  }

  /// Get a display-friendly address
  String get displayAddress {
    return formattedAddress ?? address;
  }

  /// Get a short address for display in compact spaces
  String get shortAddress {
    if (locality != null && administrativeArea != null) {
      return '$locality, $administrativeArea';
    }
    return address;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationData &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          address == other.address;

  @override
  int get hashCode => Object.hash(latitude, longitude, address);

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lng: $longitude, address: $address)';
  }
}

/// Represents a place suggestion from search
class PlaceSuggestion {
  final String placeId;
  final String description;
  final String? mainText;
  final String? secondaryText;

  const PlaceSuggestion({
    required this.placeId,
    required this.description,
    this.mainText,
    this.secondaryText,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaceSuggestion &&
          runtimeType == other.runtimeType &&
          placeId == other.placeId;

  @override
  int get hashCode => placeId.hashCode;
}

/// State for location picker
class LocationPickerState {
  final LocationData? selectedLocation;
  final LocationData? currentLocation;
  final List<PlaceSuggestion> searchSuggestions;
  final bool isLoading;
  final bool isSearching;
  final String? error;

  const LocationPickerState({
    this.selectedLocation,
    this.currentLocation,
    this.searchSuggestions = const [],
    this.isLoading = false,
    this.isSearching = false,
    this.error,
  });

  LocationPickerState copyWith({
    LocationData? selectedLocation,
    LocationData? currentLocation,
    List<PlaceSuggestion>? searchSuggestions,
    bool? isLoading,
    bool? isSearching,
    String? error,
  }) {
    return LocationPickerState(
      selectedLocation: selectedLocation ?? this.selectedLocation,
      currentLocation: currentLocation ?? this.currentLocation,
      searchSuggestions: searchSuggestions ?? this.searchSuggestions,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      error: error ?? this.error,
    );
  }

  /// Clear error state
  LocationPickerState clearError() {
    return copyWith(error: null);
  }

  /// Clear search suggestions
  LocationPickerState clearSuggestions() {
    return copyWith(searchSuggestions: []);
  }
}
