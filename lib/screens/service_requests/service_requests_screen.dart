import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logging/logging.dart';
import 'package:manong_application/api/service_request_api_service.dart';
import 'package:manong_application/main.dart';
import 'package:manong_application/models/payment_status.dart';
import 'package:manong_application/models/service_request.dart';
import 'package:manong_application/providers/bottom_nav_provider.dart';
import 'package:manong_application/theme/colors.dart';
import 'package:manong_application/utils/get_location.dart';
import 'package:manong_application/widgets/app_bar_search.dart';
import 'package:manong_application/widgets/empty_state_widget.dart';
import 'package:manong_application/widgets/error_state_widget.dart';
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

  late ServiceRequestApiService manongApiService;
  late Logger logger;
  late BottomNavProvider navProvider;

  List<ServiceRequest> serviceRequest = [];
  String _searchQuery = '';
  int statusIndex = 0;

  LatLng? _currentLatLng;
  double? meters;

  bool isLoading = true;
  String? _error;

  String _dateSortOrder = 'Descending';
  final List<String> _sortOptions = ['Descending', 'Ascending'];

  // Requests Pages
  int _currentPage = 1;
  final int _limit = 10; // items per page
  bool _isLoadingMore = false;
  bool _hasMore = true;

  static const statuses = [
    'To Pay',
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupScrollListener();
    });
  }

  void _initializeComponents() {
    logger = Logger('ServiceRequestScreen');
    manongApiService = ServiceRequestApiService();
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

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          _hasMore) {
        _fetchMoreServiceRequests();
      }
    });
  }

  Future<void> _fetchMoreServiceRequests() async {
    if (_isLoadingMore || !_hasMore) return; // lock to prevent multiple calls

    setState(() => _isLoadingMore = true);

    try {
      final response = await manongApiService.fetchServiceRequests(
        page: _currentPage,
        limit: _limit,
      );

      if (response == null) {
        setState(() => _hasMore = false);
        return;
      }

      final requests = (response as List<dynamic>)
          .map((json) => ServiceRequest.fromJson(json as Map<String, dynamic>))
          .toList();

      setState(() {
        serviceRequest.addAll(requests);
        _currentPage++;
        _isLoadingMore = false;
        if (requests.length < _limit) _hasMore = false;
      });
    } catch (e) {
      logger.severe('Error fetching more service requests $e');
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _fetchServiceRequests({bool loadMore = false}) async {
    if (!mounted || (!_hasMore && loadMore)) return;

    try {
      if (loadMore) {
        setState(() {
          _isLoadingMore = true;
        });
      } else {
        setState(() {
          isLoading = true;
          _error = null;
          _currentPage = 1;
          _hasMore = true;
        });
      }

      setState(() {
        isLoading = true;
        _error = null;
      });

      if (loadMore) _isLoadingMore = true;

      final response = await manongApiService.fetchServiceRequests(
        page: _currentPage,
        limit: _limit,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
        _error = null;
      });

      if (response == null) {
        throw Exception('No response from server');
      }

      final requests = response['data'] as List<dynamic>?;

      if (requests == null || requests.isEmpty) {
        setState(() {
          if (loadMore)
            _hasMore = false;
          else
            serviceRequest = [];
          _isLoadingMore = false;
        });

        return;
      }

      final parsedRequests = requests
          .map((json) => ServiceRequest.fromJson(json as Map<String, dynamic>))
          .toList();

      setState(() {
        if (loadMore) {
          serviceRequest.addAll(parsedRequests);
          _isLoadingMore = false;
        } else {
          serviceRequest = parsedRequests;
          isLoading = false;
        }
        if (parsedRequests.length < _limit) _hasMore = false;
      });

      _currentPage++;

      logger.info('Fetched ${parsedRequests.length} service requests');
    } catch (e) {
      logger.severe('Error fetching service requests $e');

      if (mounted) {
        setState(() {
          if (!loadMore) {
            serviceRequest = [];
            isLoading = false;
            _error = 'Failed to load service requests. Please try again.';
          } else {
            _isLoadingMore = false;
          }
        });
      }
    }
  }

  List<ServiceRequest> _getFilteredRequests() {
    List<ServiceRequest> filtered = statusIndex == 0
        ? serviceRequest
              .where((req) => req.paymentStatus == PaymentStatus.unpaid)
              .toList()
        : serviceRequest
              .where(
                (req) =>
                    req.status!.toLowerCase() ==
                    statuses[statusIndex].toLowerCase(),
              )
              .where((req) => req.paymentStatus != PaymentStatus.unpaid)
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

    filtered.sort((a, b) {
      final aDate = a.createdAt ?? DateTime.fromMicrosecondsSinceEpoch(0);
      final bDate = b.createdAt ?? DateTime.fromMicrosecondsSinceEpoch(0);

      if (_dateSortOrder == 'Descending') {
        return bDate.compareTo(aDate);
      } else {
        return aDate.compareTo(bDate);
      }
    });

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DropdownButton<String>(
            dropdownColor: Colors.white,
            value: _dateSortOrder,
            items: _sortOptions.map((option) {
              return DropdownMenuItem(value: option, child: Text(option));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _dateSortOrder = value;
                });
              }
            },
          ),
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
      ErrorStateWidget(errorText: _error!, onPressed: _fetchServiceRequests);
    }

    return EmptyStateWidget(
      searchQuery: _searchQuery,
      emptyMessage: 'No service requests found',
      onPressed: _clearSearch,
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
          itemCount: filteredRequests.length + (_isLoadingMore ? 1 : 0),
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          itemBuilder: (context, index) {
            if (index >= filteredRequests.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(
                    color: AppColorScheme.royalBlue,
                  ),
                ),
              );
            }
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
                  } else {
                    Navigator.pushNamed(
                      context,
                      '/manong-list',
                      arguments: {
                        'serviceRequest': serviceRequestItem,
                        'subServiceItem': serviceRequestItem.subServiceItem,
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
          const SizedBox(height: 4),
          _buildResultsInfo(filteredRequests.length),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 4),
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
