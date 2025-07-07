import 'package:app_reporte_iestp_sullana/utils/utils.dart';
import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSize.defaultPadding * 0.75),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 18),
          SizedBox(width: AppSize.defaultPadding * 0.75),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppStyles.h5(
                    color: AppColors.darkColor50,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: AppSize.defaultPadding * 0.25),
                Text(value, style: AppStyles.h4(color: AppColors.darkColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
