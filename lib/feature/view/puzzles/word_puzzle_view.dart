import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:elements_app/feature/provider/puzzle_provider.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/ads/rewarded_helper.dart';
import 'package:elements_app/product/widget/ads/interstitial_ad_widget.dart';
import 'package:elements_app/core/services/pattern/pattern_service.dart';
import 'package:elements_app/feature/view/tests/tests_home_view.dart';
import 'package:elements_app/product/widget/common/modern_game_result_dialog.dart';

class WordPuzzleView extends StatefulWidget {
  const WordPuzzleView({super.key});

  @override
  State<WordPuzzleView> createState() => _WordPuzzleViewState();
}

class _WordPuzzleViewState extends State<WordPuzzleView>
    with TickerProviderStateMixin {
  final PatternService _pattern = PatternService();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _feedbackController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _feedbackAnimation;
  bool _resultShown = false;
  bool _showFeedback = false;
  bool _isCorrect = false;
  String _correctWord = '';
  PuzzleProvider? _providerRef;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
    _feedbackAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _feedbackController, curve: Curves.elasticOut),
    );
    _fadeController.forward();
    _slideController.forward();
    // Start session if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isTr = context.read<LocalizationProvider>().isTr;
      _providerRef = context.read<PuzzleProvider>();
      _providerRef!.addListener(_onProviderChanged);
      if (!_providerRef!.wordSessionActive &&
          !_providerRef!.wordSessionCompleted &&
          !_providerRef!.wordSessionFailed) {
        _providerRef!.startWordSession(turkish: isTr);
      }
    });
  }

  void _onProviderChanged() {
    if (!_resultShown && _providerRef != null) {
      if (_providerRef!.wordSessionCompleted ||
          _providerRef!.wordSessionFailed) {
        _resultShown = true;
        final isTr = context.read<LocalizationProvider>().isTr;
        _showResultDialog(
          isTr: isTr,
          success: _providerRef!.wordSessionCompleted,
          correct: _providerRef!.wordCorrect,
          wrong: _providerRef!.wordWrong,
        );
      }
      if (_resultShown && _providerRef!.wordSessionActive) {
        _resultShown = false;
      }
    }
  }

  void _showWordFeedback(bool isCorrect, String correctWord) {
    if (_showFeedback) return;
    setState(() {
      _showFeedback = true;
      _isCorrect = isCorrect;
      _correctWord = isCorrect ? '' : correctWord;
    });

    _feedbackController.forward().then((_) async {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      await _feedbackController.reverse();
      if (!mounted) return;
      setState(() {
        _showFeedback = false;
      });
      // Load next word after feedback is hidden
      final provider = context.read<PuzzleProvider>();
      if (provider.wordSessionActive) {
        await provider.loadNextWord();
      }
    });
  }

  @override
  void dispose() {
    _providerRef?.removeListener(_onProviderChanged);
    _fadeController.dispose();
    _slideController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Background pattern - static, no rebuilds needed
            Positioned.fill(
              child: CustomPaint(
                painter: _pattern.getPatternPainter(
                  type: PatternType.atomic,
                  color: Colors.white,
                  opacity: 0.02,
                ),
              ),
            ),
            // Main content with modern layout like quiz view
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    // Puzzle Header - Similar to QuizHeader
                    Container(
                      height: MediaQuery.of(context).size.height * 0.16,
                      child: _PuzzleHeader(
                        onClose: () => _handlePuzzleExit(
                          context,
                          context.read<PuzzleProvider>(),
                        ),
                      ),
                    ),
                    // Main puzzle content - Similar to quiz content
                    Expanded(
                      child: _PuzzleContent(
                        fadeAnimation: _fadeAnimation,
                        slideAnimation: _slideAnimation,
                        onWordSubmitted: _showWordFeedback,
                        showFeedback: _showFeedback,
                        isCorrect: _isCorrect,
                        correctWord: _correctWord,
                        feedbackAnimation: _feedbackAnimation,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePuzzleExit(BuildContext context, PuzzleProvider provider) {
    final isTr = context.read<LocalizationProvider>().isTr;
    if (provider.wordSessionActive) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.darkBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            isTr ? 'Bulmacadan Çık' : 'Exit Puzzle',
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            isTr
                ? 'Bulmacayı şimdi bırakırsanız ilerlemeniz kaybolacak. Emin misiniz?'
                : 'If you exit now, your progress will be lost. Are you sure?',
            style: TextStyle(color: AppColors.white.withValues(alpha: 0.8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                isTr ? 'İptal' : 'Cancel',
                style: TextStyle(color: AppColors.white.withValues(alpha: 0.7)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _navigateToHome(context, provider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.powderRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isTr ? 'Çık' : 'Exit',
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      _navigateToHome(context, provider);
    }
  }

  void _navigateToHome(BuildContext context, PuzzleProvider provider) {
    provider.resetWordSessionFlags();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => TestsHomeView()),
      (route) => false,
    );
  }

  void _showResultDialog({
    required bool isTr,
    required bool success,
    required int correct,
    required int wrong,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return ModernGameResultDialog(
          success: success,
          title: success
              ? (isTr ? '🎉 Tamamlandı!' : '🎉 Completed!')
              : (isTr ? 'Tekrar Dene!' : 'Try Again!'),
          subtitle: success
              ? (isTr ? 'Harika iş çıkardın!' : 'Great job!')
              : (isTr ? 'Daha iyisini yapabilirsin!' : 'You can do better!'),
          correct: correct,
          wrong: wrong,
          showExtraLifeOption: !success,
          watchAdText: isTr ? 'Reklam İzle - Ek Can' : 'Watch Ad - Extra Life',
          onWatchAdForExtraLife: () async {
            Navigator.of(context).pop();
            final rewardEarned = await RewardedHelper.showRewardedAd(
              context: context,
            );
            if (rewardEarned && context.mounted) {
              context.read<PuzzleProvider>().continueWordAfterReward();
            } else if (context.mounted) {
              // Ad failed or user didn't earn reward, show failure dialog again
              _showResultDialog(
                isTr: isTr,
                success: success,
                correct: correct,
                wrong: wrong,
              );
            }
          },
          onPlayAgain: () async {
            Navigator.of(context).pop();
            // Show ad after dialog is closed
            await Future.delayed(const Duration(milliseconds: 500));
            await InterstitialAdManager.instance.showAdOnAction();
            context.read<PuzzleProvider>().resetWordSessionFlags();
            final isTr = context.read<LocalizationProvider>().isTr;
            context.read<PuzzleProvider>().startWordSession(turkish: isTr);
          },
          onHome: () async {
            Navigator.of(context).pop();
            // Show ad after dialog is closed
            await Future.delayed(const Duration(milliseconds: 500));
            await InterstitialAdManager.instance.showAdOnAction();
            _navigateToHome(context, context.read<PuzzleProvider>());
          },
          playAgainText: isTr ? 'Yeniden Oyna' : 'Play Again',
          homeText: isTr ? 'Ana Sayfa' : 'Home',
          successIcon: Icons.emoji_events_rounded,
          failureIcon: Icons.refresh_rounded,
        );
      },
    );
  }
}

class _SlotTile extends StatelessWidget {
  final int index;
  final Function(bool isCorrect, String correctWord) onWordSubmitted;
  const _SlotTile({required this.index, required this.onWordSubmitted});

  @override
  Widget build(BuildContext context) {
    final status = context.select<PuzzleProvider, PuzzleRoundStatus>(
      (p) => p.wordRoundStatus,
    );
    final isPlaying = status == PuzzleRoundStatus.playing;
    final letter = context.select<PuzzleProvider, String?>((p) {
      final slots = p.currentWordRound?.slots;
      if (slots == null || index >= slots.length) return null;
      return slots[index];
    });
    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (details) {
        if (!isPlaying) return false;
        final slots = context.read<PuzzleProvider>().currentWordRound?.slots;
        if (slots == null || index >= slots.length) return false;
        return slots[index] == null;
      },
      onAcceptWithDetails: (details) {
        if (!isPlaying) return;
        HapticFeedback.lightImpact();
        final provider = context.read<PuzzleProvider>();
        final letter = details.data['letter'] as String;
        final letterChipIndex = details.data['index'] as int;
        provider.placeLetter(index, letter, letterChipIndex: letterChipIndex);
        Future.delayed(const Duration(milliseconds: 10), () {
          final now = provider.currentWordRound;
          if (now != null && now.isFilled) {
            final isCorrect = provider.submitWord();
            final correctWord = now.elementName;
            onWordSubmitted(isCorrect, correctWord);
          }
        });
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;
        return GestureDetector(
          onTap: isPlaying
              ? () => context.read<PuzzleProvider>().clearSlot(index)
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 48,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: letter != null
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.turquoise.withValues(alpha: 0.8),
                        AppColors.turquoise.withValues(alpha: 0.6),
                      ],
                    )
                  : isHighlighted
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.turquoise.withValues(alpha: 0.3),
                        AppColors.turquoise.withValues(alpha: 0.2),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.15),
                        Colors.white.withValues(alpha: 0.08),
                      ],
                    ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: letter != null
                    ? AppColors.turquoise.withValues(alpha: 0.8)
                    : isHighlighted
                    ? AppColors.turquoise.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.3),
                width: isHighlighted ? 2.0 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: letter != null
                      ? AppColors.turquoise.withValues(alpha: 0.2)
                      : isHighlighted
                      ? AppColors.turquoise.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.1),
                  blurRadius: isHighlighted ? 12 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              letter ?? '',
              style: TextStyle(
                color: letter != null
                    ? AppColors.white
                    : isHighlighted
                    ? AppColors.turquoise
                    : Colors.white.withValues(alpha: 0.6),
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 1,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LetterChip extends StatelessWidget {
  final String letter;
  final int index;
  final bool isUsed;
  final VoidCallback onTap;

  const _LetterChip({
    required this.letter,
    required this.index,
    required this.isUsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = context.select<PuzzleProvider, PuzzleRoundStatus>(
      (p) => p.wordRoundStatus,
    );
    final isRoundActive = status == PuzzleRoundStatus.playing;
    final canUse = isRoundActive && !isUsed;

    return Draggable<Map<String, dynamic>>(
      data: {'letter': letter, 'index': index},
      maxSimultaneousDrags: canUse ? null : 0,
      feedback: _buildChip(48, active: true),
      childWhenDragging: _buildChip(44, active: false, dimmed: true),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canUse ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: _buildChip(44, active: canUse),
        ),
      ),
    );
  }

  Widget _buildChip(double size, {required bool active, bool dimmed = false}) {
    final colors = active
        ? [
            AppColors.purple.withValues(alpha: 0.8),
            AppColors.purple.withValues(alpha: 0.6),
          ]
        : [
            Colors.white.withValues(alpha: dimmed ? 0.05 : 0.12),
            Colors.white.withValues(alpha: dimmed ? 0.02 : 0.06),
          ];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size + 6,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active
              ? AppColors.purple.withValues(alpha: 0.85)
              : Colors.white.withValues(alpha: dimmed ? 0.15 : 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: active
                ? AppColors.purple.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            letter,
            style: TextStyle(
              color: active
                  ? AppColors.white
                  : Colors.white.withValues(alpha: dimmed ? 0.3 : 0.5),
              fontWeight: FontWeight.w700,
              fontSize: size * 0.42,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 2),
        ],
      ),
    );
  }
}

/// Modern puzzle header similar to QuizHeader
/// Modern puzzle header similar to QuizHeader

/// Modern puzzle header similar to QuizHeader
class _PuzzleHeader extends StatelessWidget {
  final VoidCallback? onClose;

  const _PuzzleHeader({this.onClose});

  @override
  Widget build(BuildContext context) {
    final isTr = context.watch<LocalizationProvider>().isTr;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
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
                        style: const TextStyle(
                          color: AppColors.turquoise,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Progress and Stats Row
            Row(
              children: [
                // Progress Section
                SizedBox(
                  width: 220,
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
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '%${(progress * 100).toInt()}',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
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

/// Optimized puzzle content widget that only rebuilds when round changes
class _PuzzleContent extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final Function(bool isCorrect, String correctWord) onWordSubmitted;
  final bool showFeedback;
  final bool isCorrect;
  final String correctWord;
  final Animation<double> feedbackAnimation;

  const _PuzzleContent({
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.onWordSubmitted,
    required this.showFeedback,
    required this.isCorrect,
    required this.correctWord,
    required this.feedbackAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final hasRound = context.select<PuzzleProvider, bool>(
      (p) => p.currentWordRound != null && !p.isLoading,
    );

    if (!hasRound) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.white),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: _buildInfoCard(context),
        ),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSlotsCard(context, onWordSubmitted),
                      const SizedBox(height: 16),
                      _buildLettersCard(context, onWordSubmitted),
                      const SizedBox(height: 16),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.1),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                        child: showFeedback
                            ? _buildFeedbackCard(context)
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              // Actions positioned higher
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.background.withValues(alpha: 0.6),
                    ],
                  ),
                ),
                child: _buildActions(context, onWordSubmitted),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final isTr = context.read<LocalizationProvider>().isTr;

    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkBlue.withValues(alpha: 0.8),
            AppColors.darkBlue.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.turquoise.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.turquoise.withValues(alpha: 0.1),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Info icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.turquoise.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.turquoise.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.info_outline,
              color: AppColors.turquoise,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          // Info text
          Expanded(
            child: Text(
              isTr
                  ? 'Element adını harflerden oluştur'
                  : 'Form the element name from letters',
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
                height: 1.2,
              ),
            ),
          ),
          // Hint indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.purple,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  isTr ? 'İpucu' : 'Hint',
                  style: const TextStyle(
                    color: AppColors.purple,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(BuildContext context) {
    final isTr = context.read<LocalizationProvider>().isTr;
    final primaryColor = isCorrect ? AppColors.glowGreen : AppColors.powderRed;
    final secondaryColor = isCorrect ? AppColors.turquoise : AppColors.pink;
    final icon = isCorrect ? Icons.check_circle : Icons.cancel;
    final title = isCorrect
        ? (isTr ? 'Doğru!' : 'Correct!')
        : (isTr ? 'Yanlış!' : 'Wrong!');
    final subtitle = isCorrect
        ? (isTr ? 'Tebrikler!' : 'Great job!')
        : (isTr ? 'Doğru cevap: $correctWord' : 'Correct answer: $correctWord');

    return ScaleTransition(
      scale: feedbackAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor.withValues(alpha: 0.9),
              secondaryColor.withValues(alpha: 0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.6),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.3),
              offset: const Offset(0, 8),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            // Status icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: AppColors.white, size: 28),
            ),
            const SizedBox(width: 16),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Animated checkmark or X
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCorrect ? Icons.emoji_events : Icons.refresh,
                      color: AppColors.white,
                      size: 18,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotsCard(
    BuildContext context,
    Function(bool, String) onWordSubmitted,
  ) {
    final slots = context.select<PuzzleProvider, List<String?>?>(
      (p) => p.currentWordRound?.slots,
    );
    if (slots == null || slots.isEmpty) {
      return const SizedBox.shrink();
    }

    const double slotWidth = 48;
    const double spacing = 12;

    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth =
              slots.length * slotWidth + (slots.length - 1) * spacing;
          final available = math.max(constraints.maxWidth - 32, slotWidth);
          final width = math.min(totalWidth, available);

          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.darkBlue.withValues(alpha: 0.72),
                  AppColors.darkBlue.withValues(alpha: 0.54),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.turquoise.withValues(alpha: 0.32),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.turquoise.withValues(alpha: 0.14),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              child: SizedBox(
                width: width,
                child: Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  alignment: WrapAlignment.center,
                  children: List.generate(
                    slots.length,
                    (i) =>
                        _SlotTile(index: i, onWordSubmitted: onWordSubmitted),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLettersCard(
    BuildContext context,
    Function(bool, String) onWordSubmitted,
  ) {
    final letters = context.select<PuzzleProvider, List<String>>(
      (p) => p.currentWordRound?.shuffled ?? const <String>[],
    );
    final allLetters = letters.toList();

    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          const double chipWidth = 48;
          const double spacing = 12;
          final totalWidth =
              allLetters.length * chipWidth + (allLetters.length - 1) * spacing;
          final available = math.max(constraints.maxWidth - 32, chipWidth);
          final width = math.min(totalWidth, available);

          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.darkBlue.withValues(alpha: 0.6),
                  AppColors.darkBlue.withValues(alpha: 0.42),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.purple.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purple.withValues(alpha: 0.12),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SizedBox(
                width: width,
                child: Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  alignment: WrapAlignment.center,
                  children: allLetters.asMap().entries.map((entry) {
                    final index = entry.key;
                    final ch = entry.value;
                    final isUsed = context.select<PuzzleProvider, bool>(
                      (p) => p.isLetterChipUsed(index),
                    );
                    return _LetterChip(
                      letter: ch,
                      isUsed: isUsed,
                      index: index,
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        final provider = context.read<PuzzleProvider>();
                        if (provider.wordRoundStatus !=
                            PuzzleRoundStatus.playing) {
                          return;
                        }
                        final slots =
                            provider.currentWordRound?.slots ??
                            const <String?>[];
                        final idx = slots.indexWhere((s) => s == null);
                        if (idx >= 0) {
                          provider.placeLetter(idx, ch, letterChipIndex: index);
                          await Future.delayed(
                            const Duration(milliseconds: 10),
                          );
                          final now = provider.currentWordRound;
                          if (now != null && now.isFilled) {
                            final isCorrect = provider.submitWord();
                            final correctWord = now.elementName;
                            onWordSubmitted(isCorrect, correctWord);
                          }
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActions(
    BuildContext context,
    Function(bool isCorrect, String correctWord) onWordSubmitted,
  ) {
    final isTr = context.read<LocalizationProvider>().isTr;
    final canUseHint = context.select<PuzzleProvider, bool>(
      (p) => p.canRevealHint,
    );
    final hintsLeft = context.select<PuzzleProvider, int>(
      (p) => p.wordHintsLeft,
    );

    final status = context.select<PuzzleProvider, PuzzleRoundStatus>(
      (p) => p.wordRoundStatus,
    );
    final isRoundActive = status == PuzzleRoundStatus.playing;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = math.min(constraints.maxWidth, 360);
        final provider = context.read<PuzzleProvider>();
        return SizedBox(
          width: maxWidth,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.turquoise.withValues(
                          alpha: isRoundActive && canUseHint ? 0.7 : 0.25,
                        ),
                        AppColors.steelBlue.withValues(
                          alpha: isRoundActive && canUseHint ? 0.5 : 0.15,
                        ),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.turquoise.withValues(
                          alpha: isRoundActive && canUseHint ? 0.25 : 0.1,
                        ),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: (isRoundActive && canUseHint)
                          ? () async {
                              HapticFeedback.lightImpact();
                              final revealed = provider.revealHintLetter();
                              if (revealed) {
                                await Future.delayed(
                                  const Duration(milliseconds: 30),
                                );
                                final now = provider.currentWordRound;
                                if (now != null && now.isFilled) {
                                  final ok = provider.submitWord();
                                  final correctWord = now.elementName;
                                  onWordSubmitted(ok, correctWord);
                                }
                              }
                            }
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          isTr
                              ? 'İpucu (${hintsLeft < 0 ? 0 : hintsLeft})'
                              : 'Hint (${hintsLeft < 0 ? 0 : hintsLeft})',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.25),
                        Colors.white.withValues(alpha: 0.12),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: isRoundActive
                          ? () {
                              HapticFeedback.lightImpact();
                              final round = provider.currentWordRound;
                              if (round != null) {
                                for (int i = 0; i < round.slots.length; i++) {
                                  provider.clearSlot(i);
                                }
                              }
                            }
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          isTr ? 'Temizle' : 'Clear',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
