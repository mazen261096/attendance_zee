import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';
import '../resources/app_strings.dart';

class CuriousZeeLogo extends StatelessWidget {
  final double fontSize;

  const CuriousZeeLogo({super.key, this.fontSize = 28});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: fontSize.h,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
        children: [
          TextSpan(
            text: "${AppStrings.appNamePart1.tr()} ",
            // Uses default text color from Theme (contrasts with background)
          ),
          TextSpan(
            text: AppStrings.appNamePart2.tr(),
            style: const TextStyle(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
