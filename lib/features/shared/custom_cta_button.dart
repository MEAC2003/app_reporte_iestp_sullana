import 'package:flutter/material.dart';
import 'package:app_reporte_iestp_sullana/utils/utils.dart';

class CustomCTAButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const CustomCTAButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.defaultPadding * 2,
        vertical: AppSize.defaultPadding,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 60.h,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: const WidgetStatePropertyAll(
              AppColors.primaryColor,
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSize.defaultRadius * 3),
              ),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: AppStyles.h3(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
