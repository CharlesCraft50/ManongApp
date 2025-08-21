import 'package:flutter/material.dart';
import 'package:manong_application/models/service_item.dart';
import 'package:manong_application/theme/colors.dart';
import 'package:manong_application/utils/icon_mapper.dart';
import 'package:manong_application/widgets/icon_card.dart';

class ServiceCardLite extends StatelessWidget {
  final ServiceItem serviceItem;
  final Color iconColor;
  final VoidCallback onTap;

  const ServiceCardLite({
    super.key,
    required this.serviceItem,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorScheme.royalBlueLight,
        borderRadius: BorderRadius.circular(16),
        // Enhanced shadow for better CTA visibility
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: 1,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                iconCard(iconColor: iconColor, iconName: serviceItem.iconName),

                const SizedBox(height: 6),

                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      serviceItem.title,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                        letterSpacing: -0.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
