import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/extensions/context_extensions.dart';
import 'package:elements_app/feature/model/quiz/quiz_models.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/feature/provider/purchase_provider.dart';
import 'package:provider/provider.dart';
import 'package:elements_app/product/widget/common/modern_game_result_dialog.dart';

/// Modern quiz header with progress and stats
class QuizHeader extends StatelessWidget {
  final QuizSession session;
  final VoidCallback? onClose;

  const QuizHeader({super.key, required this.session, this.onClose});

  String _localizedDifficulty(BuildContext context, String difficulty) {
    final isTr = context.read<LocalizationProvider>().isTr;
    final d = difficulty.toLowerCase();
    if (isTr) {
      if (d == 'easy' || d == 'kolay') return 'Kolay';
      if (d == 'medium' || d == 'orta') return 'Orta';
      if (d == 'hard' || d == 'zor') return 'Zor';
      return difficulty;
    } else {
      if (d == 'easy' || d == 'kolay') return 'Easy';
      if (d == 'medium' || d == 'orta') return 'Medium';
      if (d == 'hard' || d == 'zor') return 'Hard';
      return difficulty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTr = context.watch<LocalizationProvider>().isTr;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkBlue,
            AppColors.darkBlue.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBlue.withValues(alpha: 0.3),
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
                    isTr
                        ? session.type.turkishTitle
                        : session.type.englishTitle,
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
                    color: _getDifficultyColor().withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getDifficultyIcon(),
                        color: _getDifficultyColor(),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _localizedDifficulty(context, session.type.difficulty),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: _getDifficultyColor(),
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
                  width: 220, // Sabit genişlik
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${session.currentQuestionIndex + 1}/${session.questions.length}',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: AppColors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '%${(session.progress * 100).toInt()}',
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
                          value: session.progress,
                          backgroundColor: AppColors.white.withValues(
                            alpha: 0.2,
                          ),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getDifficultyColor(),
                          ),
                          minHeight: 3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Stats Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildCompactStatItem(
                      icon: Icons.check_circle,
                      value: session.correctAnswers.toString(),
                      color: AppColors.glowGreen,
                    ),
                    const SizedBox(width: 6),
                    _buildCompactStatItem(
                      icon: Icons.cancel,
                      value: session.wrongAnswers.toString(),
                      color: AppColors.powderRed,
                    ),
                    const SizedBox(width: 6),
                    _buildCompactStatItem(
                      icon: Icons.favorite,
                      value: session.remainingLives.toString(),
                      color: AppColors.pink,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDifficultyIcon() {
    switch (session.type) {
      case QuizType.symbol:
        return Icons.star_border;
      case QuizType.group:
        return Icons.star_half;
      case QuizType.number:
        return Icons.star;
    }
  }

  Color _getDifficultyColor() {
    switch (session.type) {
      case QuizType.symbol:
        return AppColors.glowGreen;
      case QuizType.group:
        return AppColors.yellow;
      case QuizType.number:
        return AppColors.powderRed;
    }
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

/// Modern question display card
class QuestionCard extends StatelessWidget {
  final QuizQuestion question;
  final QuizState state;

  const QuestionCard({super.key, required this.question, required this.state});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // İkon boyutunu ekran genişliğine göre ayarla
        final iconSize = constraints.maxWidth * 0.12;
        final fontSize = constraints.maxWidth * 0.055;
        final questionColor = _getQuestionTypeColor();

        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth * 0.05,
            vertical: constraints.maxHeight * 0.02,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth * 0.05,
            vertical: constraints.maxHeight * 0.03,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.darkBlue.withValues(alpha: 0.95),
                AppColors.darkBlue.withValues(alpha: 0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(constraints.maxWidth * 0.05),
            boxShadow: [
              BoxShadow(
                color: questionColor.withValues(alpha: 0.2),
                offset: const Offset(0, 8),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(
              color: questionColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Question type icon with animation
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 500),
                    tween: Tween(begin: 0.8, end: 1.0),
                    builder: (context, value, child) => Transform.scale(
                      scale: value,
                      child: Container(
                        width: iconSize,
                        height: iconSize,
                        padding: EdgeInsets.all(iconSize * 0.2),
                        decoration: BoxDecoration(
                          color: questionColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(iconSize * 0.3),
                          border: Border.all(
                            color: questionColor.withValues(alpha: 0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: questionColor.withValues(alpha: 0.2),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Icon(question.type.icon, color: questionColor),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.025),

                  // Question text with animation
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) => Transform.scale(
                      scale: value,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth * 0.9,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth * 0.045,
                          vertical: constraints.maxHeight * 0.025,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(
                            constraints.maxWidth * 0.035,
                          ),
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.darkBlue.withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Text(
                          question.questionText,
                          style: context.textTheme.headlineMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: fontSize,
                            height: 1.3,
                            letterSpacing: 0.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),

                  if (question.additionalInfo != null) ...[
                    SizedBox(height: constraints.maxHeight * 0.02),
                    // Additional info with animation
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 700),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth * 0.85,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: constraints.maxWidth * 0.03,
                            vertical: constraints.maxHeight * 0.01,
                          ),
                          decoration: BoxDecoration(
                            color: questionColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              constraints.maxWidth * 0.02,
                            ),
                            border: Border.all(
                              color: questionColor.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            question.additionalInfo!,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: AppColors.white.withValues(alpha: 0.8),
                              fontStyle: FontStyle.italic,
                              fontSize: fontSize * 0.5,
                              height: 1.2,
                              letterSpacing: 0.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getQuestionTypeColor() {
    switch (question.type) {
      case QuizType.symbol:
        return AppColors.glowGreen;
      case QuizType.group:
        return AppColors.yellow;
      case QuizType.number:
        return AppColors.powderRed;
    }
  }
}

/// Modern answer options grid
class AnswerOptionsGrid extends StatelessWidget {
  final QuizQuestion question;
  final String? selectedAnswer;
  final QuizState state;
  final Function(String) onAnswerSelected;

  const AnswerOptionsGrid({
    super.key,
    required this.question,
    this.selectedAnswer,
    required this.state,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Dinamik grid boyutları
        final spacing = constraints.maxWidth * 0.04;
        final optionWidth = (constraints.maxWidth - spacing * 3) / 2;
        final optionHeight = optionWidth * 0.85; // Biraz daha yüksek

        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth * 0.02,
            vertical: constraints.maxHeight * 0.02,
          ),
          child: Center(
            child: Wrap(
              spacing: spacing,
              runSpacing: spacing * 1.2, // Dikey boşluk biraz daha fazla
              alignment: WrapAlignment.center,
              children: question.options.map((option) {
                return SizedBox(
                  width: optionWidth,
                  height: optionHeight,
                  child: _buildAnswerOption(context, option, constraints),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnswerOption(
    BuildContext context,
    String option,
    BoxConstraints constraints,
  ) {
    final isSelected = selectedAnswer == option;
    final isCorrect = question.correctAnswer == option;
    final showResult =
        state == QuizState.correct || state == QuizState.incorrect;

    // Dinamik boyutlar
    final fontSize = constraints.maxWidth * 0.035;
    final iconSize = constraints.maxWidth * 0.05;
    final borderRadius = constraints.maxWidth * 0.03;
    final padding = constraints.maxWidth * 0.03;

    Color backgroundColor = AppColors.darkBlue.withValues(alpha: 0.7);
    Color borderColor = AppColors.white.withValues(alpha: 0.3);
    Color textColor = AppColors.white;
    Color glowColor = AppColors.white.withValues(alpha: 0.1);

    if (showResult) {
      if (isCorrect) {
        backgroundColor = AppColors.glowGreen.withValues(alpha: 0.15);
        borderColor = AppColors.glowGreen;
        textColor = AppColors.glowGreen;
        glowColor = AppColors.glowGreen.withValues(alpha: 0.2);
      } else if (isSelected && !isCorrect) {
        backgroundColor = AppColors.powderRed.withValues(alpha: 0.15);
        borderColor = AppColors.powderRed;
        textColor = AppColors.powderRed;
        glowColor = AppColors.powderRed.withValues(alpha: 0.2);
      }
    } else if (isSelected) {
      backgroundColor = AppColors.purple.withValues(alpha: 0.25);
      borderColor = AppColors.purple;
      textColor = AppColors.purple;
      glowColor = AppColors.purple.withValues(alpha: 0.2);
    }

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.95, end: 1.0),
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: glowColor,
                offset: Offset(0, constraints.maxHeight * 0.01),
                blurRadius: constraints.maxHeight * 0.04,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadius),
            child: InkWell(
              borderRadius: BorderRadius.circular(borderRadius),
              onTap: state == QuizState.loaded
                  ? () => onAnswerSelected(option)
                  : null,
              splashColor: borderColor.withValues(alpha: 0.1),
              highlightColor: borderColor.withValues(alpha: 0.05),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: padding * 1.2,
                  vertical: padding,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (showResult) ...[
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: isCorrect
                            ? Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.glowGreen,
                                size: iconSize * 1.2,
                                key: const ValueKey('correct'),
                              )
                            : isSelected
                            ? Icon(
                                Icons.cancel_rounded,
                                color: AppColors.powderRed,
                                size: iconSize * 1.2,
                                key: const ValueKey('wrong'),
                              )
                            : const SizedBox.shrink(),
                      ),
                      SizedBox(height: padding * 0.5),
                    ],
                    Expanded(
                      child: Center(
                        child: Text(
                          option,
                          style: context.textTheme.titleMedium?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                            fontSize: fontSize,
                            letterSpacing: 0.2,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (isSelected && !showResult) ...[
                      SizedBox(height: padding * 0.5),
                      Icon(
                        Icons.radio_button_checked_rounded,
                        color: AppColors.purple,
                        size: iconSize * 0.8,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Quiz result dialog
class QuizResultDialog extends StatelessWidget {
  final QuizSession session;
  final VoidCallback onRestart;
  final VoidCallback onHome;
  final VoidCallback? onWatchAdForExtraLife;

  const QuizResultDialog({
    super.key,
    required this.session,
    required this.onRestart,
    required this.onHome,
    this.onWatchAdForExtraLife,
  });

  @override
  Widget build(BuildContext context) {
    final isWin = session.state == QuizState.completed;
    final score = (session.scorePercentage * 100).toInt();
    final isTr = context.watch<LocalizationProvider>().isTr;

    // Check if user is premium
    final isPremium = context.watch<PurchaseProvider>().isPremium;

    return ModernGameResultDialog(
      success: isWin,
      title: isWin
          ? (isTr ? '🎉 Quiz Tamamlandı!' : '🎉 Quiz Completed!')
          : (isTr ? 'Tekrar Deneyin!' : 'Try Again!'),
      subtitle: isWin
          ? (isTr ? 'Harika iş çıkardın!' : 'Great job!')
          : (isTr ? 'Daha iyisini yapabilirsin!' : 'You can do better!'),
      correct: session.correctAnswers,
      wrong: session.wrongAnswers,
      gameTime: session.duration,
      scoreText: '%$score',
      showExtraLifeOption:
          !isWin && onWatchAdForExtraLife != null && !isPremium,
      watchAdText: isTr ? 'Reklam İzle - Ek Can' : 'Watch Ad - Extra Life',
      onWatchAdForExtraLife: onWatchAdForExtraLife,
      onPlayAgain: onRestart,
      onHome: onHome,
      playAgainText: isTr ? 'Tekrar Oyna' : 'Play Again',
      homeText: isTr ? 'Ana Sayfa' : 'Home',
      successIcon: Icons.emoji_events_rounded,
      failureIcon: Icons.refresh_rounded,
    );
  }
}
