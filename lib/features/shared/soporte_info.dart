import 'package:app_reporte_iestp_sullana/utils/utils.dart';
import 'package:flutter/material.dart';

class SoporteInfo extends StatelessWidget {
  final String nombreSoporte;

  const SoporteInfo({super.key, required this.nombreSoporte});

  @override
  Widget build(BuildContext context) {
    final bool tieneSoporte = nombreSoporte != 'Sin asignar';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSize.defaultPadding * 0.75),
      decoration: BoxDecoration(
        color: tieneSoporte
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: tieneSoporte
              ? Colors.green.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSize.defaultPadding * 0.5),
            decoration: BoxDecoration(
              color: tieneSoporte ? Colors.green : Colors.orange,
              shape: BoxShape.circle,
            ),
            child: Icon(
              tieneSoporte ? Icons.person : Icons.person_off,
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: AppSize.defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tieneSoporte ? 'Asignado a:' : 'Estado:',
                  style: AppStyles.h5(
                    color: AppColors.darkColor50,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: AppSize.defaultPadding * 0.25),
                Text(
                  nombreSoporte,
                  style: AppStyles.h4(
                    color: AppColors.darkColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
