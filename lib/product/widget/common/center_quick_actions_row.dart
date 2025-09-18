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
          child: _SquareAction(
            title: statisticsTitle,
            subtitle: statisticsSubtitle,
            icon: Icons.analytics_rounded,
            gradientColors: statisticsGradient,
            onTap: onStatisticsTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SquareAction(
            title: achievementsTitle,
            subtitle: achievementsSubtitle,
            icon: Icons.emoji_events_rounded,
            gradientColors: achievementsGradient,
            footer: achievementsFooter,
            onTap: onAchievementsTap,
          ),
        ),
      ],
    );
  }
}

class _SquareAction extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  final Widget? footer;

  const _SquareAction({
    required this.title,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
    this.subtitle,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Ink(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Base gradient background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Subtle radial highlight for depth
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.10),
                            Colors.transparent,
                          ],
                          radius: 1.0,
                          center: const Alignment(-0.7, -0.8),
                        ),
                      ),
                    ),
                  ),
                  // Decorative top-right soft circle
                  Positioned(
                    right: -30,
                    top: -30,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  // Content
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.16),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors.first.withValues(alpha: 0.22),
                          blurRadius: 26,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.28),
                              width: 1,
                            ),
                          ),
                          child: Icon(icon, color: AppColors.white, size: 22),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        if (footer != null) ...[
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [footer!],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MiniChip extends StatelessWidget {
  final String text;
  const MiniChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.24),
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
