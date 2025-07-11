import 'package:flutter/material.dart';

import 'package:app_reporte_iestp_sullana/utils/utils.dart';

class CustomTextFields extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  //hinttext
  final String? hintText;
  final bool? obscureText;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final bool? enabled;

  const CustomTextFields({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.keyboardType,
    this.obscureText,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.h4(
            color: AppColors.primarySkyBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText ?? false,
          validator: validator,
          onSaved: onSaved,
          onChanged: onChanged,
          enabled: enabled,
          decoration: InputDecoration(
            border: const UnderlineInputBorder(),
            hintText: hintText,
            hintStyle: AppStyles.h5(
              color: AppColors.darkColor.withOpacity(0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
          style: AppStyles.h5(
            color: AppColors.darkColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSize.defaultPadding),
      ],
    );
  }
}
