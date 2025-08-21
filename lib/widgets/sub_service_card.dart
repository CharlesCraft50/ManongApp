import 'package:flutter/material.dart';
import 'package:manong_application/models/sub_service_item.dart';
import 'package:manong_application/theme/colors.dart';
import 'package:manong_application/utils/icon_mapper.dart';
import 'package:manong_application/widgets/icon_card.dart';

class SubServiceCard extends StatelessWidget {
  final SubServiceItem subServiceItem;
  final VoidCallback onTap;
  final Color iconColor;

  const SubServiceCard({
    super.key,
    required this.subServiceItem,
    required this.onTap,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColorScheme.royalBlueLight,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                offset: Offset(0, 4),
                blurRadius: 4,
              ),
            ],
          ),
          padding: EdgeInsets.all(12),
          child: ListTile(
            leading: iconCard(
              iconColor: iconColor,
              iconName: subServiceItem.iconName,
            ),
            title: Text(
              subServiceItem.title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            // subtitle: Text(subService.description ?? '', style: TextStyle(
            //   fontSize: 14,
            //   color: Colors.grey[700],
            // ),),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.arrow_forward_ios)],
            ),
          ),
        ),
      ),
    );
  }
}
