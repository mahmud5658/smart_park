import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_car_parking/config/colors.dart';
import 'homepage/homepage.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _mapController = Completer();
  LatLng? _currentLocation;
  bool _showParkingList = false;
  BitmapDescriptor? _parkingMarkerIcon;
  BitmapDescriptor? _selectedMarkerIcon;
  int _selectedParkingIndex = -1;

  final List<ParkingLocation> _parkingLocations = [
    ParkingLocation(
      id: 'parking_1',
      name: 'Bashundhara Parking',
      position: const LatLng(23.8136, 90.4224),
      availableSlots: 15,
      totalSlots: 50,
      rate: '৳50/hour',
      distance: '1.2 km',
    ),
    ParkingLocation(
      id: 'parking_2',
      name: 'Gulshan Parking Plaza',
      position: const LatLng(23.7940, 90.4145),
      availableSlots: 8,
      totalSlots: 40,
      rate: '৳70/hour',
      distance: '2.5 km',
    ),
    ParkingLocation(
      id: 'parking_3',
      name: 'Dhanmondi Car Park',
      position: const LatLng(23.7455, 90.3735),
      availableSlots: 22,
      totalSlots: 60,
      rate: '৳40/hour',
      distance: '3.1 km',
    ),
    ParkingLocation(
      id: 'parking_4',
      name: 'Uttara Parking Complex',
      position: const LatLng(23.8759, 90.3795),
      availableSlots: 5,
      totalSlots: 30,
      rate: '৳60/hour',
      distance: '5.7 km',
    ),
    ParkingLocation(
      id: 'parking_5',
      name: 'Motijheel Commercial Parking',
      position: const LatLng(23.7333, 90.4174),
      availableSlots: 12,
      totalSlots: 45,
      rate: '৳55/hour',
      distance: '4.2 km',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentLocation = const LatLng(23.8103, 90.4125);
    _createMarkerIcons();
  }

  Future<void> _createMarkerIcons() async {
    try {
      final parkingIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(24, 24)),
        'assets/images/logo.png',
      );

      final selectedIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(24, 24)),
        'assets/images/logo.png',
      );

      setState(() {
        _parkingMarkerIcon = parkingIcon;
        _selectedMarkerIcon = selectedIcon;
      });
    } catch (e) {
      setState(() {
        _parkingMarkerIcon = BitmapDescriptor.defaultMarker;
        _selectedMarkerIcon =
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      });
    }
  }

  Future<void> _goToLocation(LatLng position) async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 16, tilt: 45),
      ),
    );
  }

  Set<Marker> _createMarkers() {
    if (_parkingMarkerIcon == null || _selectedMarkerIcon == null) {
      return {};
    }

    return _parkingLocations.map((parking) {
      return Marker(
        markerId: MarkerId(parking.id),
        position: parking.position,
        icon: _selectedParkingIndex == _parkingLocations.indexOf(parking)
            ? _selectedMarkerIcon!
            : _parkingMarkerIcon!,
        onTap: () {
          setState(() {
            _selectedParkingIndex = _parkingLocations.indexOf(parking);
            _goToLocation(parking.position);
          });
        },
      );
    }).toSet();
  }

  Widget _buildParkingCard(ParkingLocation parking, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedParkingIndex = index;
          _goToLocation(parking.position);
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _selectedParkingIndex == index
              ? primaryColor.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedParkingIndex == index
                ? primaryColor
                : Colors.grey[300]!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Parking status indicator
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: parking.availableSlots > 5
                      ? Colors.green
                      : parking.availableSlots > 0
                      ? Colors.orange
                      : Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              // Parking info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      parking.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.local_parking,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${parking.availableSlots}/${parking.totalSlots} slots',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.attach_money,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          parking.rate,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.directions_car,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          parking.distance,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Book button
              ElevatedButton(
                onPressed: () {
                  Get.to(HomePage());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  'Book',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/white_logo.png",
              width: 36,
              height: 36,
            ),
            const SizedBox(width: 12),
            const Text(
              "Smart Park",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 20,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation ?? const LatLng(23.8103, 90.4125),
              zoom: 14,
            ),
            markers: _createMarkers(),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            buildingsEnabled: true,
            compassEnabled: true,
            mapToolbarEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _mapController.complete(controller);
            },
          ),

          // Loading indicator if markers not ready
          if (_parkingMarkerIcon == null || _selectedMarkerIcon == null)
            const Center(child: CircularProgressIndicator()),

          // Search Bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search parking in Bangladesh...',
                  prefixIcon: const Icon(Icons.search, color: primaryColor),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.tune, color: primaryColor),
                    onPressed: () {},
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),

          // Parking List Toggle Button
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'parkingToggle',
              onPressed: () {
                setState(() {
                  _showParkingList = !_showParkingList;
                });
              },
              backgroundColor: primaryColor,
              child: Icon(
                _showParkingList ? Icons.close : Icons.list,
                color: Colors.white,
              ),
            ),
          ),

          // Current Location Button
          Positioned(
            bottom: 90,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'currentLocation',
              onPressed: () async {
                if (_currentLocation != null) {
                  _goToLocation(_currentLocation!);
                }
              },
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.my_location,
                color: primaryColor,
              ),
            ),
          ),

          // Parking List Bottom Sheet
          if (_showParkingList)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      spreadRadius: 2,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Nearby Parking",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Chip(
                            backgroundColor: primaryColor.withOpacity(0.1),
                            label: Text(
                              "${_parkingLocations.length} spots",
                              style: const TextStyle(color: primaryColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Parking list
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListView.builder(
                          itemCount: _parkingLocations.length,
                          itemBuilder: (context, index) {
                            return _buildParkingCard(
                                _parkingLocations[index], index);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ParkingLocation {
  final String id;
  final String name;
  final LatLng position;
  final int availableSlots;
  final int totalSlots;
  final String rate;
  final String distance;

  ParkingLocation({
    required this.id,
    required this.name,
    required this.position,
    required this.availableSlots,
    required this.totalSlots,
    required this.rate,
    required this.distance,
  });
}