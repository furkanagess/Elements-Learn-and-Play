import 'package:flutter/material.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/extensions/context_extensions.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/feature/provider/puzzle_provider.dart';
import 'package:provider/provider.dart';

/// Modern puzzle header with progress and stats
class PuzzleHeader extends StatelessWidget {
  final VoidCallback? onClose;

  const PuzzleHeader({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    final isTr = context.watch<LocalizationProvider>().isTr;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.purple, AppColors.purple.withValues(alpha: 0.8)],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top row with close button, title and difficulty
            Row(
              children: [
                if (onClose != null)
                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: onClose,
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isTr ? 'Kelime Bulmacası' : 'Word Puzzle',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.turquoise.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.spellcheck,
                        color: AppColors.turquoise,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isTr ? 'Kelime' : 'Word',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.turquoise,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress and Stats Row
            Row(
              children: [
                // Progress Section
                SizedBox(
                  width: 220, // Fixed width
                  child: Consumer<PuzzleProvider>(
                    builder: (context, provider, child) {
                      final progress =
                          provider.wordRoundIndex / provider.wordTotalRounds;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${provider.wordRoundIndex + 1}/${provider.wordTotalRounds}',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: AppColors.white.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '%${(progress * 100).toInt()}',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: AppColors.white.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress.clamp(0, 1),
                              backgroundColor: AppColors.white.withValues(
                                alpha: 0.2,
                              ),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.turquoise,
                              ),
                              minHeight: 3,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const Spacer(),

                // Stats Section
                Consumer<PuzzleProvider>(
                  builder: (context, provider, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildCompactStatItem(
                          icon: Icons.check_circle,
                          value: provider.wordCorrect.toString(),
                          color: AppColors.glowGreen,
                        ),
                        const SizedBox(width: 6),
                        _buildCompactStatItem(
                          icon: Icons.cancel,
                          value: provider.wordWrong.toString(),
                          color: AppColors.powderRed,
                        ),
                        const SizedBox(width: 6),
                        _buildCompactStatItem(
                          icon: Icons.favorite,
                          value: provider.wordAttemptsLeft.toString(),
                          color: AppColors.pink,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStatItem({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 3),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
