import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';

class LocationStep extends StatelessWidget {
  final String location;
  final LatLng? selectedLocation;
  final Set<Marker> markers;
  final Function(LatLng) onMapTap;
  final Function(String) onLocationChanged;
  final Function() onResetLocation;

  const LocationStep({
    Key? key,
    required this.location,
    required this.selectedLocation,
    required this.markers,
    required this.onMapTap,
    required this.onLocationChanged,
    required this.onResetLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location Details',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Provide the location details of your land',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
        SizedBox(height: 32),

        // Location field
        TextFormField(
          initialValue: location,
          decoration: InputDecoration(
            labelText: 'Location Address',
            hintText: 'Enter the full address of your property',
            prefixIcon: Icon(Icons.location_on, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          onChanged: onLocationChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a location address';
            }
            return null;
          },
        ),
        SizedBox(height: 32),

        // Interactive Google Maps
        Container(
          height: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: selectedLocation ??
                        LatLng(36.8065, 10.1815), // Default to Tunis
                    zoom: 14,
                  ),
                  onTap: onMapTap,
                  markers: markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  mapType: MapType.normal,
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedLocation != null
                                    ? 'Location Selected'
                                    : 'Select Location',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                selectedLocation != null
                                    ? '${selectedLocation!.latitude.toStringAsFixed(6)}, ${selectedLocation!.longitude.toStringAsFixed(6)}'
                                    : 'Tap on the map to select your land location',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (selectedLocation != null)
                          IconButton(
                            icon: Icon(Icons.refresh, color: Colors.red),
                            onPressed: onResetLocation,
                            tooltip: 'Reset selection',
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),

        // Map location note
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700]),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Select the exact location of your land on the map by clicking on it. You can zoom in for better precision.',
                  style: TextStyle(color: Colors.blue[800]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}