import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:elements_app/product/constants/app_colors.dart';
// Removed pattern painter usage per request

/// Modern, consistent game result dialog for all game types
class ModernGameResultDialog extends StatefulWidget {
  final bool success;
  final String title;
  final String subtitle;
  final int correct;
  final int wrong;
  final Duration? gameTime;
  final String? scoreText;
  final List<Widget>? additionalStats;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;
  final String playAgainText;
  final String homeText;
  final IconData? successIcon;
  final IconData? failureIcon;
  // Extra life feature for failure states
  final VoidCallback? onWatchAdForExtraLife;
  final String? watchAdText;
  final bool showExtraLifeOption;

  const ModernGameResultDialog({
    super.key,
    required this.success,
    required this.title,
    required this.subtitle,
    required this.correct,
    required this.wrong,
    this.gameTime,
    this.scoreText,
    this.additionalStats,
    required this.onPlayAgain,
    required this.onHome,
    required this.playAgainText,
    required this.homeText,
    this.successIcon,
    this.failureIcon,
    this.onWatchAdForExtraLife,
    this.watchAdText,
    this.showExtraLifeOption = false,
  });

  @override
  State<ModernGameResultDialog> createState() => _ModernGameResultDialogState();
}

class _ModernGameResultDialogState extends State<ModernGameResultDialog>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildDialogContent(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDialogContent() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860, minWidth: 380),
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.success
                  ? [
                      AppColors.purple.withValues(alpha: 1.0),
                      AppColors.pink.withValues(alpha: 0.95),
                      AppColors.turquoise.withValues(alpha: 0.9),
                    ]
                  : [
                      AppColors.darkBlue.withValues(alpha: 0.98),
                      AppColors.powderRed.withValues(alpha: 0.9),
                      AppColors.pink.withValues(alpha: 0.85),
                    ],
              stops: const [0.0, 0.6, 1.0],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (widget.success ? AppColors.purple : AppColors.darkBlue)
                    .withValues(alpha: 0.4),
                offset: const Offset(0, 12),
                blurRadius: 32,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: (widget.success ? AppColors.pink : AppColors.powderRed)
                    .withValues(alpha: 0.3),
                offset: const Offset(0, 24),
                blurRadius: 48,
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                // Decorative Elements
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -15,
                  left: -15,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // Main Content
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with Icon
                      _buildHeader(),
                      const SizedBox(height: 24),

                      // Stats Section
                      _buildStatsSection(),
                      const SizedBox(height: 28),

                      // Action Buttons
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Icon Container
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.success
                  ? [
                      Colors.amber.withValues(alpha: 0.8),
                      Colors.orange.withValues(alpha: 0.6),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.2),
                      Colors.white.withValues(alpha: 0.1),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            widget.success
                ? (widget.successIcon ?? Icons.emoji_events_rounded)
                : (widget.failureIcon ?? Icons.refresh_rounded),
            color: widget.success ? Colors.black : AppColors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 16),

        // Title
        Text(
          widget.title,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Subtitle
        Text(
          widget.subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Main Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.check_circle,
                  label: 'Doğru',
                  value: '${widget.correct}',
                  color: Colors.lightGreenAccent,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.cancel,
                  label: 'Yanlış',
                  value: '${widget.wrong}',
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),

          // Additional Stats
          if (widget.gameTime != null || widget.scoreText != null) ...[
            const SizedBox(height: 16),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Row(
              children: [
                if (widget.gameTime != null)
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.timer,
                      label: 'Süre',
                      value: _formatDuration(widget.gameTime!),
                      color: Colors.cyanAccent,
                    ),
                  ),
                if (widget.gameTime != null && widget.scoreText != null)
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                if (widget.scoreText != null)
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.star,
                      label: 'Puan',
                      value: widget.scoreText!,
                      color: Colors.amberAccent,
                    ),
                  ),
              ],
            ),
          ],

          // Custom Additional Stats
          if (widget.additionalStats != null &&
              widget.additionalStats!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            ...widget.additionalStats!,
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    // If showing extra life option (failure state), show 3 buttons
    if (widget.showExtraLifeOption &&
        !widget.success &&
        widget.onWatchAdForExtraLife != null) {
      return Column(
        children: [
          // Extra life button (full width)
          _buildActionButton(
            text: widget.watchAdText ?? 'Reklam İzle - Ek Can',
            icon: Icons.favorite,
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onWatchAdForExtraLife!();
            },
            isPrimary: true,
            isFullWidth: true,
          ),
          const SizedBox(height: 12),
          // Play again and home buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  text: widget.playAgainText,
                  icon: Icons.refresh_rounded,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onPlayAgain();
                  },
                  isPrimary: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  text: widget.homeText,
                  icon: Icons.home_rounded,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onHome();
                  },
                  isPrimary: false,
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Default 2-button layout
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            text: widget.playAgainText,
            icon: Icons.refresh_rounded,
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onPlayAgain();
            },
            isPrimary: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            text: widget.homeText,
            icon: Icons.home_rounded,
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onHome();
            },
            isPrimary: false,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    required bool isPrimary,
    bool isFullWidth = false,
  }) {
    Widget buttonContent = Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPrimary
              ? [
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.1),
                ]
              : [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.05),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.white, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: isFullWidth ? buttonContent : buttonContent,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
