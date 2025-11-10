import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';
import '../services/places_service.dart';
import '../utils/preferences_helper.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  LatLng? currentLocation;
  Set<Marker> markers = {};
  double searchRadiusKm = 2.0;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _getCurrentLocation();
  }

  Future<void> _loadPreferences() async {
    searchRadiusKm = await PreferencesHelper.getRadius() ?? 2.0;
    setState(() {});
  }

  Future<void> _getCurrentLocation() async {
    currentLocation = await LocationService.getCurrentLocation();
    if (currentLocation != null) {
      await _fetchNearbyPlaces();
      setState(() {});
    }
  }

  Future<void> _fetchNearbyPlaces() async {
    if (currentLocation == null) return;
    final places = await PlacesService.getNearbyPlaces(
      currentLocation!.latitude,
      currentLocation!.longitude,
      searchRadiusKm,
    );
    setState(() {
      markers = places
          .map((place) => Marker(
        markerId: MarkerId(place['place_id']),
        position: LatLng(place['lat'], place['lng']),
        infoWindow: InfoWindow(title: place['name']),
      ))
          .toSet();
    });
  }

  void _openSettings() async {
    final newRadius = await showDialog<double>(
      context: context,
      builder: (context) {
        double tempRadius = searchRadiusKm;
        return AlertDialog(
          title: const Text('Configurar radio (km)'),
          content: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${tempRadius.toStringAsFixed(1)} km'),
                Slider(
                  value: tempRadius,
                  min: 0.5,
                  max: 10,
                  divisions: 20,
                  label: '${tempRadius.toStringAsFixed(1)} km',
                  onChanged: (value) => setState(() => tempRadius = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, tempRadius),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (newRadius != null) {
      await PreferencesHelper.setRadius(newRadius);
      setState(() => searchRadiusKm = newRadius);
      _fetchNearbyPlaces();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puntos de interés cercanos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          )
        ],
      ),
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        onMapCreated: (controller) => mapController = controller,
        initialCameraPosition: CameraPosition(
          target: currentLocation!,
          zoom: 14,
        ),
        markers: markers,
        myLocationEnabled: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchNearbyPlaces,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
