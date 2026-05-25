import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/logo_helpers.dart';
import '../constants/image_assets.dart';
import '../theme/app_theme.dart';

class BillLogoWidget extends StatelessWidget {
  final String name;
  final double size;

  const BillLogoWidget({super.key, required this.name, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final assetPath = getBillLogoAsset(name);
    final isDark = Get.isDarkMode;

    if (assetPath != null) {
      return Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.2),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(size * 0.24),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
          border: isDark ? Border.all(color: Colors.white10) : null,
        ),
        child: Image.asset('${ImageAssets.logosPath}$assetPath', fit: BoxFit.contain),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : const Color(0xFFF3F7F6),
        borderRadius: BorderRadius.circular(size * 0.24),
        border: isDark ? Border.all(color: Colors.white10) : null,
      ),
      child: Icon(
        Icons.receipt_long_rounded,
        color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF64748B),
        size: size * 0.44,
      ),
    );
  }
}
