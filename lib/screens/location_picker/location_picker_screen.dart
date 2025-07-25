import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iu_job_assessment/models/location_model.dart';
import 'package:iu_job_assessment/providers/location_picker_provider.dart';
import 'package:iu_job_assessment/screens/location_picker/location_error_widget.dart';
import 'package:iu_job_assessment/utils/app_colors.dart';

/// Full-screen location picker with type-ahead address and map search functionality
class LocationPickerScreen extends ConsumerStatefulWidget {
  final LocationData? initialLocation;

  const LocationPickerScreen({super.key, this.initialLocation});

  @override
  ConsumerState<LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _searchDebouncer;
  final Completer<GoogleMapController> _mapController = Completer();
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();

    // Initialize location picker
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationPickerProvider.notifier).initializeLocation();
    });

    // Set up search debouncing
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchDebouncer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebouncer?.cancel();
    _searchDebouncer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        ref
            .read(locationPickerProvider.notifier)
            .searchPlaces(_searchController.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Update markers when location changes
    _updateMarkers();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer(
        builder: (context, ref, child) {
          final state = ref.watch(locationPickerProvider);

          // Show error widget if there's an error
          if (state.error != null && state.currentLocation == null) {
            return SafeArea(
              child: Center(child: LocationErrorWidget(error: state.error!)),
            );
          }

          return Stack(
            children: [
              // Map area
              _buildMapArea(),

              // Search overlay
              _buildSearchOverlay(),

              // My location button
              _buildMyLocationButton(),

              // Selected location info
              _buildSelectedLocationInfo(),

              // Confirm button
              _buildConfirmButton(),

              // Loading overlay
              if (state.isLoading)
                Container(
                  color: AppColors.black.withAlpha(25),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Build floating my location button
  Widget _buildMyLocationButton() {
    return Positioned(
      top: 200,
      right: 16,
      child: FloatingActionButton.small(
        onPressed: () async {
          final state = ref.read(locationPickerProvider);
          if (state.currentLocation != null) {
            final controller = await _mapController.future;
            await controller.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(
                    state.currentLocation!.latitude,
                    state.currentLocation!.longitude,
                  ),
                  zoom: 16.0,
                ),
              ),
            );
          }
        },
        backgroundColor: AppColors.background,
        child: Icon(Icons.my_location, color: AppColors.primary),
      ),
    );
  }

  /// Build the map area with Google Maps
  Widget _buildMapArea() {
    return Consumer(
      builder: (context, ref, child) {
        // Default camera position (The Sultan’s Palace)
        const CameraPosition initialPosition = CameraPosition(
          target: LatLng(13.06696, 5.24819),
          zoom: 14.0,
        );

        return GoogleMap(
          initialCameraPosition: initialPosition,
          onMapCreated: (GoogleMapController controller) {
            _mapController.complete(controller);
            _moveToCurrentLocation();
          },
          onTap: (LatLng position) {
            // Clear search focus when tapping map
            _searchFocusNode.unfocus();
            ref.read(locationPickerProvider.notifier).clearSearchSuggestions();

            // Select location from map tap
            ref
                .read(locationPickerProvider.notifier)
                .selectLocationFromMap(position.latitude, position.longitude);
          },
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false, // I'll add custom button
          mapType: MapType.normal,
          compassEnabled: true,
          tiltGesturesEnabled: false,
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
        );
      },
    );
  }

  /// Move map camera to current location
  Future<void> _moveToCurrentLocation() async {
    final state = ref.read(locationPickerProvider);
    if (state.currentLocation != null) {
      final controller = await _mapController.future;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              state.currentLocation!.latitude,
              state.currentLocation!.longitude,
            ),
            zoom: 16.0,
          ),
        ),
      );
    }
  }

  /// Update markers when location changes
  void _updateMarkers() {
    final state = ref.watch(locationPickerProvider);

    if (state.selectedLocation != null) {
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: LatLng(
            state.selectedLocation!.latitude,
            state.selectedLocation!.longitude,
          ),
          infoWindow: InfoWindow(
            title: 'Selected Location',
            snippet: state.selectedLocation!.shortAddress,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      };
    } else {
      _markers = {};
    }
  }

  /// Build search overlay at the top
  Widget _buildSearchOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withAlpha(25),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button and search
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textPrimary,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Search for a location...',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    ref
                                        .read(locationPickerProvider.notifier)
                                        .clearSearchSuggestions();
                                  },
                                  icon: const Icon(
                                    Icons.clear,
                                    color: AppColors.textSecondary,
                                  ),
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.background,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search suggestions
              Consumer(
                builder: (context, ref, child) {
                  final state = ref.watch(locationPickerProvider);

                  if (state.searchSuggestions.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Container(
                    constraints: const BoxConstraints(maxHeight: 300),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border(top: BorderSide(color: AppColors.surface)),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: state.searchSuggestions.length,
                      separatorBuilder: (context, index) =>
                          Divider(height: 1, color: AppColors.surface),
                      itemBuilder: (context, index) {
                        final suggestion = state.searchSuggestions[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.textSecondary,
                          ),
                          title: Text(
                            suggestion.mainText ?? suggestion.description,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: suggestion.secondaryText != null
                              ? Text(
                                  suggestion.secondaryText!,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                )
                              : null,
                          onTap: () {
                            _searchController.text = suggestion.description;
                            _searchFocusNode.unfocus();
                            ref
                                .read(locationPickerProvider.notifier)
                                .selectLocationFromSearch(suggestion);
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build selected location info card
  Widget _buildSelectedLocationInfo() {
    return Positioned(
      bottom: 100,
      left: 16,
      right: 16,
      child: Consumer(
        builder: (context, ref, child) {
          final state = ref.watch(locationPickerProvider);

          if (state.selectedLocation == null) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withAlpha(25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'Tap on the map to select a location',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            );
          }

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withAlpha(25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Selected Location',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  state.selectedLocation!.displayAddress,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (state.selectedLocation!.shortAddress !=
                    state.selectedLocation!.displayAddress)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      state.selectedLocation!.shortAddress,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build confirm location button
  Widget _buildConfirmButton() {
    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: Consumer(
        builder: (context, ref, child) {
          final isLocationSelected = ref.watch(isLocationSelectedProvider);
          final state = ref.watch(locationPickerProvider);

          return ElevatedButton(
            onPressed: (isLocationSelected && !state.isLoading)
                ? () => _confirmLocation(context, ref)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state.isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.background,
                      ),
                    ),
                  )
                else
                  const Icon(Icons.check, color: AppColors.background),
                const SizedBox(width: 8),
                Text(
                  state.isLoading ? 'Loading...' : 'Confirm Location',
                  style: const TextStyle(
                    color: AppColors.background,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Confirm location selection and return to previous screen
  void _confirmLocation(BuildContext context, WidgetRef ref) {
    final selectedLocation = ref.read(locationPickerProvider).selectedLocation;
    if (selectedLocation != null) {
      Navigator.of(context).pop(selectedLocation);
    }
  }
}
