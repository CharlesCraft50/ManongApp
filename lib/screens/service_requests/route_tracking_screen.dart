import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logging/logging.dart';
import 'package:manong_application/widgets/my_app_bar.dart';

class RouteTrackingScreen extends StatefulWidget {
  final LatLng? currentLatLng;
  final LatLng? manongLatLng;
  final String? manongName;

  const RouteTrackingScreen({
    super.key,
    this.currentLatLng,
    this.manongLatLng,
    this.manongName,
  });

  @override
  State<RouteTrackingScreen> createState() => _RouteTrackingScreenState();
}

class _RouteTrackingScreenState extends State<RouteTrackingScreen> {
  GoogleMapController? mapController;
  String? _manongName;
  LatLng? _currentLatLng;
  LatLng? _manongLatLng;
  late Logger logger;

  List<LatLng> polylineCoordinates = [];
  Set<Polyline> polylines = {};

  bool isLoading = true;
  String? _error;
  bool _argumentsInitialized = false;

  String googleAPIKey = dotenv.env['GOOGLE_API_KEY']!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_argumentsInitialized) {
      logger.info(widget.currentLatLng);
      _currentLatLng = widget.currentLatLng;
      _manongLatLng = widget.manongLatLng;
      _manongName = widget.manongName;

      _argumentsInitialized = true;

      if (_currentLatLng != null && _manongLatLng != null) {
        _getPolyline();
      } else {
        setState(() {
          _error = 'Invalid location data provided';
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeComponents();
  }

  void _initializeComponents() {
    logger = Logger('map_screen');
  }

  void _getPolyline() async {
    try {
      setState(() {
        isLoading = true;
        _error = null;
      });

      if (!mounted) return;

      logger.info('Manong $_manongName');

      PolylinePoints polylinePoints = PolylinePoints(apiKey: googleAPIKey);

      PolylineRequest request = PolylineRequest(
        origin: PointLatLng(
          _currentLatLng!.latitude,
          _currentLatLng!.longitude,
        ),
        destination: PointLatLng(
          _manongLatLng!.latitude,
          _manongLatLng!.longitude,
        ),
        mode: TravelMode.driving,
      );

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: request,
      );

      if (result.points.isNotEmpty) {
        polylineCoordinates.clear();
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }

        setState(() {
          polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              points: polylineCoordinates,
              color: Colors.blue,
              width: 5,
              patterns: [],
            ),
          );
          isLoading = false;
        });

        // Adjust camera to show both markers
        _fitCameraToBounds();

        logger.info(
          'Polyline created with ${polylineCoordinates.length} points',
        );
      } else {
        logger.warning('No route found');
      }

      if (result.points.isEmpty) {
        setState(() {
          isLoading = false;
        });
        logger.warning('No polyline points returned.');
        return;
      }
    } catch (e) {
      setState(() {
        _error = 'Error getting route: ${e.toString()}';
        isLoading = false;
      });
      logger.severe('Error getting polyline: $e');
    }
  }

  void _fitCameraToBounds() {
    if (mapController == null) return;

    double minLat = _currentLatLng!.latitude < _manongLatLng!.latitude
        ? _currentLatLng!.latitude
        : _manongLatLng!.latitude;
    double maxLat = _currentLatLng!.latitude > _manongLatLng!.latitude
        ? _currentLatLng!.latitude
        : _manongLatLng!.latitude;
    double minLng = _currentLatLng!.longitude < _manongLatLng!.longitude
        ? _currentLatLng!.longitude
        : _manongLatLng!.longitude;
    double maxLng = _currentLatLng!.longitude > _manongLatLng!.longitude
        ? _currentLatLng!.longitude
        : _manongLatLng!.longitude;

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100.0));
  }

  Widget _buildGoogleMap() {
    if (_currentLatLng == null || _manongLatLng == null) {
      return const Center(child: Text('Location data not available'));
    }
    return SafeArea(
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentLatLng!,
          zoom: 12,
        ),
        onMapCreated: (controller) {
          mapController = controller;
          if (polylineCoordinates.isNotEmpty) {
            _fitCameraToBounds();
          }
        },
        markers: {
          Marker(
            markerId: MarkerId('origin'),
            position: _currentLatLng!,
            infoWindow: const InfoWindow(title: "You"),
          ),
          Marker(
            markerId: MarkerId('destination'),
            position: _manongLatLng!,
            infoWindow: InfoWindow(title: "Manong $_manongName"),
          ),
        },
        polylines: polylines,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Loading route...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  _error ?? 'Unknown error occurred',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _getPolyline,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(title: 'Manong $_manongName is on the way...'),
      body: Stack(
        children: [
          _buildGoogleMap(),
          if (isLoading) _buildLoadingOverlay(),
          if (_error != null && !isLoading) _buildErrorOverlay(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }
}
