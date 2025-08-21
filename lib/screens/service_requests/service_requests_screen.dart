import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logging/logging.dart';
import 'package:manong_application/api/manong_api_service.dart';
import 'package:manong_application/main.dart';
import 'package:manong_application/models/service_request.dart';
import 'package:manong_application/providers/bottom_nav_provider.dart';
import 'package:manong_application/theme/colors.dart';
import 'package:manong_application/utils/get_location.dart';
import 'package:manong_application/widgets/app_bar_search.dart';
import 'package:manong_application/widgets/service_request_card.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart' as latlong;

class ServiceRequestsScreen extends StatefulWidget {
  const ServiceRequestsScreen({super.key});
  @override
  State<ServiceRequestsScreen> createState() => _ServiceRequestsScreenState();
}

class _ServiceRequestsScreenState extends State<ServiceRequestsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final distance = latlong.Distance();

  late ManongApiService manongApiService;
  late Logger logger;
  late BottomNavProvider navProvider;

  List<ServiceRequest> serviceRequest = [];
  String _searchQuery = '';
  int statusIndex = 0;

  LatLng? _currentLatLng;
  double? meters;

  bool isLoading = true;
  String? _error;

  static const statuses = [
    'All',
    'Pending',
    'Accepted',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _initializeComponents();
    _fetchServiceRequests();
    _getCurrentLocation();
  }

  void _initializeComponents() {
    logger = Logger('service_requests_list');
    manongApiService = ManongApiService();
    navProvider = Provider.of<BottomNavProvider>(
      navigatorKey.currentContext!,
      listen: false,
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      final result = await getCurrentLocation(navigatorKey.currentContext!);

      if (result != null && mounted) {
        final position = result.position;

        setState(() {
          _currentLatLng = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (e) {
      logger.severe('Error getting location: $e');
    }
  }

  void _onStatusChanged(int index) {
    if (index != statusIndex) {
      setState(() {
        statusIndex = index;
      });
    }
  }

  Widget _buildStatusChip({
    required String title,
    required int index,
    required bool active,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6, left: 6),
      child: FilterChip(
        label: Text(title),
        selected: active,
        onSelected: (_) => _onStatusChanged(index),
        selectedColor: AppColorScheme.royalBlue,
        backgroundColor: AppColorScheme.royalBlueLight,
        labelStyle: TextStyle(
          color: active ? Colors.white : Colors.grey.shade700,
          fontWeight: active ? FontWeight.w600 : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildStatusRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          statuses.length,
          (index) => _buildStatusChip(
            title: statuses[index],
            index: index,
            active: statusIndex == index,
          ),
        ),
      ),
    );
  }

  Future<void> _fetchServiceRequests() async {
    if (!mounted) return;

    try {
      setState(() {
        isLoading = true;
        _error = null;
      });

      final response = await manongApiService.fetchServiceRequests();

      if (!mounted) return;

      if (response == null) {
        throw Exception('No response from server');
      }

      final requests = response['service_requests'] as List<dynamic>?;

      if (requests == null) {
        logger.warning("Service requests list is null");
        if (mounted) {
          setState(() {
            serviceRequest = [];
            isLoading = false;
          });
        }
        return;
      }

      final parsedRequests = requests
          .map((json) => ServiceRequest.fromJson(json as Map<String, dynamic>))
          .toList();

      if (mounted) {
        setState(() {
          serviceRequest = parsedRequests;
          isLoading = false;
        });
      }

      logger.info('Fetched ${parsedRequests.length} service requests');
    } catch (e) {
      logger.severe('Error fetching service requests $e');

      if (mounted) {
        setState(() {
          serviceRequest = [];
          isLoading = false;
          _error = 'Failed to load service requests. Please try again.';
        });
      }
    }
  }

  List<ServiceRequest> _getFilteredRequests() {
    List<ServiceRequest> filtered = statusIndex == 0
        ? List.from(serviceRequest)
        : serviceRequest
              .where((req) => req.status == statuses[statusIndex])
              .toList();

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((req) {
        final manong = req.manong?.name?.toLowerCase() ?? '';
        final service = req.serviceItem?.title.toLowerCase() ?? '';
        final subService = req.subServiceItem?.title.toLowerCase() ?? '';
        final urgency = req.urgencyLevel?.level.toLowerCase() ?? '';

        final matches =
            manong.contains(query) ||
            service.contains(query) ||
            subService.contains(query) ||
            urgency.contains(query);

        return matches;
      }).toList();
    }

    return filtered;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.trim();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
  }

  Widget _buildResultsInfo(int count) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '($count result${count != 1 ? 's' : ''})',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  double? _calculateDistance(ServiceRequest request) {
    if (_currentLatLng == null ||
        request.manong?.latitude == null ||
        request.manong?.longitude == null) {
      return null;
    }

    return distance.as(
      latlong.LengthUnit.Meter,
      latlong.LatLng(_currentLatLng!.latitude, _currentLatLng!.longitude),
      latlong.LatLng(request.manong!.latitude!, request.manong!.longitude!),
    );
  }

  Widget _buildEmptyState() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 45, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchServiceRequests,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorScheme.royalBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isEmpty ? Icons.inbox_outlined : Icons.search_off,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'No service requests found'
                : 'No results found for "$_searchQuery"',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: _clearSearch,
              child: const Text(
                'Clear search',
                style: TextStyle(color: AppColorScheme.royalBlue),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServiceRequestsList(List<ServiceRequest> filteredRequests) {
    return RefreshIndicator(
      color: AppColorScheme.royalBlue,
      backgroundColor: AppColorScheme.backgroundGrey,
      onRefresh: _fetchServiceRequests,
      child: Scrollbar(
        controller: _scrollController,
        child: ListView.builder(
          itemCount: filteredRequests.length,
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          itemBuilder: (context, index) {
            ServiceRequest serviceRequestItem = filteredRequests[index];

            final meters = _calculateDistance(serviceRequestItem);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ServiceRequestCard(
                serviceRequestItem: serviceRequestItem,
                meters: meters,
                onTap: () {
                  if (serviceRequestItem.manong?.id != null) {
                    Navigator.pushNamed(
                      context,
                      '/route-tracking',
                      arguments: {
                        'currentLatLng': LatLng(
                          serviceRequestItem.latitude,
                          serviceRequestItem.longitude,
                        ),
                        'manongLatLng': LatLng(
                          serviceRequestItem.manong!.latitude!,
                          serviceRequestItem.manong!.longitude!,
                        ),
                        'manongName': serviceRequestItem.manong!.name,
                      },
                    );
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredRequests = _getFilteredRequests();

    return Scaffold(
      backgroundColor: AppColorScheme.backgroundGrey,
      appBar: AppBarSearch(
        title: 'My Requests',
        onBackTap: () {
          navProvider.changeIndex(0);
        },
        controller: _searchController,
        onChanged: _onSearchChanged,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _buildStatusRow(),
          const SizedBox(height: 8),
          _buildResultsInfo(filteredRequests.length),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColorScheme.royalBlue,
                        ),
                      )
                    : filteredRequests.isEmpty
                    ? _buildEmptyState()
                    : Padding(
                        padding: const EdgeInsets.all(12),
                        child: _buildServiceRequestsList(filteredRequests),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
