import 'package:elements_app/feature/model/info.dart';
import 'package:elements_app/feature/provider/admob_provider.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/feature/view/info/subInfo/infoDetail/info_detail_view.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/constants/assets_constants.dart';
import 'package:elements_app/product/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:elements_app/product/extensions/color_extension.dart';
import 'package:provider/provider.dart';

@immutable
final class WhatIsContainer extends StatelessWidget {
  final Info info;
  final VoidCallback? onTap;

  const WhatIsContainer({
    super.key,
    required this.info,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'what_is_${info.enTitle}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () => _navigateToDetail(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: context.dynamicWidth(0.04),
              vertical: context.dynamicHeight(0.01),
            ),
            height: context.dynamicHeight(0.085),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  info.colors?.toColor() ?? AppColors.darkBlue,
                  info.colors?.toColor().withOpacity(0.9) ??
                      AppColors.darkBlue.withOpacity(0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: info.shColor!.toColor().withOpacity(0.3),
                  offset: const Offset(0, 8),
                  blurRadius: 24,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final isTr = context.select((LocalizationProvider p) => p.isTr);

    return Stack(
      children: [
        // Background Pattern
        Positioned.fill(
          child: _buildPattern(),
        ),

        // Main Content
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.dynamicWidth(0.04),
            vertical: context.dynamicHeight(0.01),
          ),
          child: Row(
            children: [
              // Icon with Container
              _buildIcon(context),
              SizedBox(width: context.dynamicWidth(0.04)),

              // Title
              Expanded(
                child: _buildTitle(context, isTr),
              ),

              // Arrow Icon with Animation
              _buildArrowIcon(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPattern() {
    return CustomPaint(
      painter: _WhatIsPatternPainter(
        color: Colors.white.withOpacity(0.05),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
      width: context.dynamicWidth(0.12),
      height: context.dynamicWidth(0.12),
      padding: EdgeInsets.all(context.dynamicWidth(0.025)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: SvgPicture.asset(
        AssetConstants.instance.svgQuestionTwo,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTitle(BuildContext context, bool isTr) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isTr ? info.trTitle! : info.enTitle!,
          style: context.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          isTr ? info.trDesc1 ?? '' : info.enDesc1 ?? '',
          style: context.textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildArrowIcon(BuildContext context) {
    return Container(
      width: context.dynamicWidth(0.1),
      height: context.dynamicWidth(0.1),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.arrow_forward_ios_rounded,
        color: Colors.white.withOpacity(0.9),
        size: 20,
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    context.read<AdmobProvider>().onRouteChanged();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InfoDetailView(info: info),
      ),
    );
  }
}

class _WhatIsPatternPainter extends CustomPainter {
  final Color color;

  _WhatIsPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    // Draw diagonal lines
    for (int i = 0; i < size.width + size.height; i += 20) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(0, i.toDouble()),
        paint,
      );
    }

    // Draw subtle dots
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < size.width; i += 30) {
      for (int j = 0; j < size.height; j += 30) {
        canvas.drawCircle(
          Offset(i.toDouble(), j.toDouble()),
          1,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
