import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../utils/logo_helpers.dart';
import '../constants/image_assets.dart';

class TransactionLogoWidget extends StatelessWidget {
  final String title;
  final bool isIncome;
  final double size;
  final bool isCircle;

  const TransactionLogoWidget({
    super.key,
    required this.title,
    this.isIncome = false,
    this.size = 50,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    final assetName = getTransactionLogoAsset(title);
    final isDark = Get.isDarkMode;

    Widget childWidget;
    if (assetName != null) {
      final pad = getLogoPadding(assetName);
      childWidget = Padding(
        padding: EdgeInsets.all(pad),
        child: Image.asset(
          '${ImageAssets.croppedPath}$assetName',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(isDark),
        ),
      );
    } else {
      childWidget = _buildFallbackIcon(isDark);
    }

    final decoration = isCircle
        ? BoxDecoration(
            color: isDark ? AppTheme.darkSurface : const Color(0xFFF3F7F6),
            shape: BoxShape.circle,
          )
        : BoxDecoration(
            color: isDark ? AppTheme.darkSurface : const Color(0xFFF3F7F6),
            borderRadius: BorderRadius.circular(12),
          );

    return Container(
      width: size,
      height: size,
      decoration: decoration,
      child: isCircle && assetName != null
          ? ClipOval(child: childWidget)
          : Center(child: childWidget),
    );
  }

  Widget _buildFallbackIcon(bool isDark) {
    return Icon(
      isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
      color: const Color(0xFF2F7E79),
      size: size * 0.44,
    );
  }
}
