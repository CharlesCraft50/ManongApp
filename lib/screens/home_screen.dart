
import 'package:flutter/material.dart';
import 'package:manong_application/api/service-item.dart';
import 'package:manong_application/models/service_item.dart';
import 'package:manong_application/theme/colors.dart';
import 'package:manong_application/widgets/gradient_text.dart';
import 'package:manong_application/widgets/manong_icon.dart';
import 'package:manong_application/widgets/service_card.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ServiceItem> _allServices = [];
  List<ServiceItem> _filteredServices = [];
  String _searchQuery = '';

  final TextEditingController _firstSearchController = TextEditingController();
  final TextEditingController _secondSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchServiceItems().then((services) {
      setState(() {
        _allServices = services;
        _filteredServices = services;
      });
    });
  }

  void _filterServices(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      _searchQuery = query;
      _filteredServices = _allServices.where((service) {
        return service.title.toLowerCase().contains(lowerQuery) ||
                service.description.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  void _changeSecondSearch(String query) {
    _secondSearchController.text = query;
    _filterServices(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            snap: false,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final top = constraints.biggest.height;
                final collapsed = top <= kToolbarHeight + MediaQuery.of(context).padding.top;

                return FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColorScheme.royalBlue,
                          AppColorScheme.deepNavyBlue,
                        ],
                      ),
                    ),

                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ManongIcon(),
                                SizedBox(width: 4),
                                GradientText(
                                  text: 'Manong App',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColorScheme.goldLight,
                                      AppColorScheme.gold,
                                      AppColorScheme.goldDeep,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Your trusted on-demand service platform.\nConnect with skilled professionals for all your home needs!',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[100],
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.location_on, color: Colors.grey[400], size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Available in Metro Manila',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(width: 24),
                                Icon(Icons.access_time, color: Colors.grey[400], size: 16),
                                SizedBox(width: 4),
                                Text(
                                  '24/7 Service',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: TextField(
                                controller: _firstSearchController,
                                onChanged: _changeSecondSearch,
                                decoration: InputDecoration(
                                  hintText: 'Search services...',
                                  prefixIcon: Icon(Icons.search),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
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
                  ),

                  title: collapsed 
                  ? Padding(
                    padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                    child: Row(
                        children: [
                          ManongIcon(),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _secondSearchController,
                              onChanged: _filterServices,
                              decoration: InputDecoration(
                                hintText: 'Search services...',
                                prefixIcon: Icon(Icons.search),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, color: Colors.grey[800]),
                          ),
                        ]
                    ),
                  ) : null,
                  centerTitle: true,
                  
                );
              },
            ),
            backgroundColor: AppColorScheme.royalBlue,
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Choose Your Service',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Professional help is just a tap away",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 18),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            sliver: _allServices.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _filteredServices.isEmpty
                    ? SliverToBoxAdapter(
                        child: Center(child: Text('No matching services found')),
                      )
                    : SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final service = _filteredServices[index];
                            final cardColor = AppColorScheme
                                .serviceColors[index % AppColorScheme.serviceColors.length];
                            return ServiceCard(
                              service: service,
                              iconColor: cardColor,
                              onTap: () {
                                print('Tapped on ${service.title}');
                              },
                            );
                          },
                          childCount: _filteredServices.length,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.680,
                        ),
                      ),
          )

        ],
      ),
    );
  }
}