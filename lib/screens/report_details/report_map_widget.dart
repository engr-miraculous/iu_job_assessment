// screens/report_details/widgets/report_map_widget.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iu_job_assessment/models/report_model.dart';
import 'package:iu_job_assessment/utils/app_colors.dart';

/// Widget to display a map with the report location
class ReportMapWidget extends StatefulWidget {
  final Report report;

  const ReportMapWidget({super.key, required this.report});

  @override
  State<ReportMapWidget> createState() => _ReportMapWidgetState();
}

class _ReportMapWidgetState extends State<ReportMapWidget> {
  final Completer<GoogleMapController> _mapController = Completer();
  Set<Marker> _markers = {};
  LatLng? _reportLocation;

  @override
  void initState() {
    super.initState();
    _setupReportLocation();
  }

  /// Setup the report location from the address
  void _setupReportLocation() {
    // For now I'm using a default location
    _reportLocation = const LatLng(13.06696, 5.24819); // The Sultan’s Palace

    _markers = {
      Marker(
        markerId: const MarkerId('report_location'),
        position: _reportLocation!,
        infoWindow: InfoWindow(
          title: 'Report Location',
          snippet: widget.report.location,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_reportLocation == null) {
      return Container(
        color: AppColors.surface,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _reportLocation!,
        zoom: 15.0,
      ),
      onMapCreated: (GoogleMapController controller) {
        _mapController.complete(controller);
      },
      markers: _markers,
      mapType: MapType.normal,
      compassEnabled: false,
      tiltGesturesEnabled: false,
      rotateGesturesEnabled: false,
      scrollGesturesEnabled: true,
      zoomGesturesEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      myLocationButtonEnabled: false,
      buildingsEnabled: true,
      onTap: (LatLng position) {
        // Show full-screen map on tap
        _showFullScreenMap();
      },
    );
  }

  /// Show full-screen map (optional feature)
  void _showFullScreenMap() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Report Location',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Map
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _reportLocation!,
                        zoom: 16.0,
                      ),
                      markers: _markers,
                      mapType: MapType.normal,
                      compassEnabled: true,
                      tiltGesturesEnabled: true,
                      rotateGesturesEnabled: true,
                      scrollGesturesEnabled: true,
                      zoomGesturesEnabled: true,
                      zoomControlsEnabled: true,
                      mapToolbarEnabled: true,
                      myLocationButtonEnabled: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
