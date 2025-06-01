// lib/action_card.dart
import 'package:app_reporte_iestp_sullana/utils/utils.dart';
import 'package:flutter/material.dart';

class ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  final double cardWidth;
  final double cardHeight;

  const ActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.cardWidth = 130,
    this.cardHeight = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primarySkyBlue,
      borderRadius: BorderRadius.circular(AppSize.defaultRadius * 2),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.3),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSize.defaultRadius * 2),
        onTap: onTap,
        child: Container(
          width: cardWidth,
          height: cardHeight,
          padding: EdgeInsets.all(AppSize.defaultPadding),
          child: Column(
            // ** IMPORTANTE: Volvemos a MainAxisAlignment.center o start/end **
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: AppSize.defaultIconSize * 0.7,
              ),

              SizedBox(height: AppSize.defaultPaddingHorizontal * 0.5),
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.h5(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ).copyWith(letterSpacing: -0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
