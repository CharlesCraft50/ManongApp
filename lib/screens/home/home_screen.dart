import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:manong_application/api/service_item_api_service.dart';
import 'package:manong_application/models/service_item.dart';
import 'package:manong_application/providers/bottom_nav_provider.dart';
import 'package:manong_application/theme/colors.dart';
import 'package:manong_application/utils/color_utils.dart';
import 'package:manong_application/widgets/gradient_header_container.dart';
import 'package:manong_application/widgets/manong_icon.dart';
import 'package:manong_application/widgets/manong_representational_icon.dart';
import 'package:manong_application/widgets/service_card_lite.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final String? token;
  const HomeScreen({super.key, this.token});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Logger logger;
  List<ServiceItem> _allServiceItems = [];
  List<ServiceItem> _filteredServiceItems = [];
  bool _isLoading = true;
  String? _error;
  late ServiceItemApiService serviceItemApiService;

  final TextEditingController _firstSearchController = TextEditingController();
  final TextEditingController _secondSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    logger = Logger('HomeScreen');
    serviceItemApiService = ServiceItemApiService();
    _loadServiceItems();
  }

  Future<void> _loadServiceItems() async {
    try {
      if (!mounted) return;

      setState(() {
        _isLoading = true;
        _error = null;
      });

      final serviceItems = await serviceItemApiService
          .fetchServiceItemsCacheFirst();

      // Add this mounted check before setState
      if (!mounted) return;

      setState(() {
        _allServiceItems = serviceItems;
        _filteredServiceItems = serviceItems;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _filterServiceItems(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredServiceItems = _allServiceItems.where((service) {
        bool titleMatches = service.title.toLowerCase().contains(lowerQuery);

        bool subServiceMatches = false;
        if (service.subServiceItems != null ||
            service.subServiceItems!.isNotEmpty) {
          subServiceMatches = service.subServiceItems!.any(
            (subService) => subService.title.toLowerCase().contains(lowerQuery),
          );
        }

        return titleMatches || subServiceMatches;
      }).toList();
    });
  }

  void _changeSecondSearch(String query) {
    _secondSearchController.text = query;
    _filterServiceItems(query);
  }

  Widget _buildServiceGrid() {
    if (_isLoading) {
      return SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 100),
          child: Center(
            child: CircularProgressIndicator(
              color: AppColorScheme.royalBlueDark,
            ),
          ),
        ),
      );
    }
    if (_error != null) {
      return SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 100),
          child: Center(
            child: Column(
              children: [
                Text(
                  'Error loading services. Please try again.',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadServiceItems,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorScheme.royalBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (_filteredServiceItems.isEmpty) {
      /* empty state */
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Wrap(
          spacing: 4,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: _filteredServiceItems.map((serviceItem) {
            // Find the original index in _allServices
            final originalIndex = _allServiceItems.indexOf(serviceItem);
            final cardColor =
                AppColorScheme.serviceColors[originalIndex %
                    AppColorScheme.serviceColors.length];

            return SizedBox(
              width: (MediaQuery.of(context).size.width - 48 - 12) / 4,
              height: 100,
              child: ServiceCardLite(
                serviceItem: serviceItem,
                iconColor: colorFromHex(serviceItem.iconColor),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/sub-service-list',
                    arguments: {
                      'serviceItem': serviceItem,
                      'iconColor': colorFromHex(serviceItem.iconColor),
                    },
                  );
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorScheme.backgroundGrey,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 170,
            floating: false,
            pinned: true,
            snap: false,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final top = constraints.biggest.height;
                final collapsed =
                    top <= kToolbarHeight + MediaQuery.of(context).padding.top;

                return FlexibleSpaceBar(
                  background: GradientHeaderContainer(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    // borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                    children: [
                      Center(
                        child: Text(
                          'Mannongapp.ph',
                          style: TextStyle(
                            color: AppColorScheme.royalBlueLight,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 130,
                            padding: const EdgeInsets.only(
                              bottom: 24,
                              left: 14,
                            ),
                            child: Text(
                              'Home services, anytime you need.',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColorScheme.backgroundGrey,
                                height: 1.3,
                              ),
                            ),
                          ),
                          Flexible(child: manongRepresentationalIcon()),
                        ],
                      ),
                    ],
                  ),

                  title: collapsed
                      ? Padding(
                          padding: const EdgeInsets.only(
                            top: 20,
                            left: 20,
                            right: 20,
                          ),
                          child: Row(
                            children: [
                              manongIcon(size: 40, fit: BoxFit.contain),
                              const SizedBox(width: 4),
                              Expanded(
                                child: TextField(
                                  controller: _secondSearchController,
                                  onChanged: _filterServiceItems,
                                  decoration: InputDecoration(
                                    hintText: 'Search services...',
                                    prefixIcon: Icon(Icons.search),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 0,
                                      horizontal: 16,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () =>
                                    FlutterSecureStorage()
                                        .read(key: 'token')
                                        .toString()
                                        .isEmpty
                                    ? Navigator.pushNamed(context, '/register')
                                    : Provider.of<BottomNavProvider>(
                                        context,
                                        listen: false,
                                      ).changeIndex(1),
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : null,
                  centerTitle: true,
                );
              },
            ),
            backgroundColor: AppColorScheme.royalBlueDark,
          ),

          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Choose Your Service',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Professional help is just a tap away",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: _firstSearchController,
                      onChanged: _changeSecondSearch,
                      decoration: InputDecoration(
                        hintText: 'Search services...',
                        prefixIcon: Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          _buildServiceGrid(),
        ],
      ),
    );
  }
}
