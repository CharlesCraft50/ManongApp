import 'package:flutter/material.dart';
import 'package:manong_application/api/service-item.dart';
import 'package:manong_application/theme/colors.dart';
import 'package:manong_application/widgets/home_header.dart';
import 'package:manong_application/widgets/service_card.dart';

class HomeScreenBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
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

                  Expanded(
                    child: FutureBuilder(
                      future: fetchServiceItems(),
                      builder: (context, snapshot) {
                        if(snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if(snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }

                        final services = snapshot.data;

                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.680,
                          ),
                          itemCount: services!.length,
                          itemBuilder: (context, index) {
                            final service = services[index];
                            
                            final cardColor = AppColorScheme.serviceColors[index % AppColorScheme.serviceColors.length];
                            
                            return ServiceCard(service: service, iconColor: cardColor, onTap: () {
                              print('Tapped on ${service.title}');
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      );
  }
}
