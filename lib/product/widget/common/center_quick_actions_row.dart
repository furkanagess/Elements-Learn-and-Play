import 'package:flutter/material.dart';
import 'package:elements_app/product/constants/app_colors.dart';

class CenterQuickActionsRow extends StatelessWidget {
  final String statisticsTitle;
  final String? statisticsSubtitle;
  final List<Color> statisticsGradient;
  final VoidCallback onStatisticsTap;

  final String achievementsTitle;
  final String? achievementsSubtitle;
  final List<Color> achievementsGradient;
  final VoidCallback onAchievementsTap;
  final Widget? achievementsFooter;

  const CenterQuickActionsRow({
    super.key,
    required this.statisticsTitle,
    this.statisticsSubtitle,
    required this.statisticsGradient,
    required this.onStatisticsTap,
    required this.achievementsTitle,
    this.achievementsSubtitle,
    required this.achievementsGradient,
    required this.onAchievementsTap,
    this.achievementsFooter,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ModernActionCard(
            title: statisticsTitle,
            subtitle: statisticsSubtitle,
            icon: Icons.analytics_rounded,
            primaryColor: statisticsGradient.first,
            shadowColor: statisticsGradient.length > 1
                ? statisticsGradient.last
                : statisticsGradient.first,
            onTap: onStatisticsTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ModernActionCard(
            title: achievementsTitle,
            subtitle: achievementsSubtitle,
            icon: Icons.emoji_events_rounded,
            primaryColor: achievementsGradient.first,
            shadowColor: achievementsGradient.length > 1
                ? achievementsGradient.last
                : achievementsGradient.first,
            footer: achievementsFooter,
            onTap: onAchievementsTap,
          ),
        ),
      ],
    );
  }
}

class _ModernActionCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color primaryColor;
  final Color shadowColor;
  final VoidCallback onTap;
  final Widget? footer;

  const _ModernActionCard({
    required this.title,
    required this.icon,
    required this.primaryColor,
    required this.shadowColor,
    required this.onTap,
    this.subtitle,
    this.footer,
  });

  @override
  State<_ModernActionCard> createState() => _ModernActionCardState();
}

class _ModernActionCardState extends State<_ModernActionCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _scaleController.forward(),
            onTapUp: (_) => _handleTap(),
            onTapCancel: () => _scaleController.reverse(),
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: widget.primaryColor.withValues(
                  alpha: 0.15,
                ), // Element color background
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.primaryColor.withValues(
                    alpha: 0.4,
                  ), // Element color border
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.primaryColor.withValues(
                      alpha: 0.3,
                    ), // Element color shadow
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon Container (similar to other modern cards)
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: widget.primaryColor.withValues(
                          alpha: 0.6,
                        ), // Card color
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.primaryColor.withValues(alpha: 0.8),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.shadowColor.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(widget.icon, color: Colors.white, size: 24),
                    ),
                    const SizedBox(height: 12),

                    // Title
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // Footer (for achievements badge count)
                    if (widget.footer != null) ...[
                      const SizedBox(height: 8),
                      widget.footer!,
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MiniChip extends StatelessWidget {
  final String text;
  const MiniChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
