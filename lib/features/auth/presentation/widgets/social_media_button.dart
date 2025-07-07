import 'package:app_reporte_iestp_sullana/utils/utils.dart';
import 'package:flutter/material.dart';

class SocialMediaButton extends StatelessWidget {
  final String imgPath;
  final String text;
  final VoidCallback onPressed;
  const SocialMediaButton({
    super.key,
    required this.text,
    required this.imgPath,
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
        child: ElevatedButton.icon(
          style: ButtonStyle(
            backgroundColor: const WidgetStatePropertyAll(
              AppColors.primarySkyBlue,
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSize.defaultRadius * 3),
              ),
            ),
          ),
          onPressed: onPressed,
          icon: Image.asset(imgPath, width: 24.w, height: 24.h),
          label: Text(
            text,
            style: AppStyles.h4(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
