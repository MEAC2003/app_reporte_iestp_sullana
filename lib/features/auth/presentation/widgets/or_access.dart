import 'package:app_reporte_iestp_sullana/utils/utils.dart';
import 'package:flutter/material.dart';

class OrAccess extends StatelessWidget {
  const OrAccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 54.w),
      child: Row(
        children: [
          Expanded(
            child: Divider(color: Colors.black, thickness: 0.5.w),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Text('O', style: AppStyles.h4(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Divider(color: Colors.black, thickness: 0.5.w),
          ),
        ],
      ),
    );
  }
}
