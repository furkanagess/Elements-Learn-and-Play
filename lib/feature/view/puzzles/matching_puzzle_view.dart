import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:elements_app/feature/provider/puzzle_provider.dart';
import 'package:elements_app/feature/model/puzzle/puzzle_models.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/ads/rewarded_helper.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/core/services/pattern/pattern_service.dart';
import 'package:elements_app/feature/view/tests/tests_home_view.dart';
import 'package:elements_app/feature/view/trivia/trivia_achievements_view.dart';
import 'package:elements_app/product/widget/common/modern_game_result_dialog.dart';
import 'package:elements_app/product/widget/ads/interstitial_ad_widget.dart';

class MatchingPuzzleView extends StatefulWidget {
  final bool first20Only;

  const MatchingPuzzleView({super.key, this.first20Only = false});

  @override
  State<MatchingPuzzleView> createState() => _MatchingPuzzleViewState();
}

class _MatchingPuzzleViewState extends State<MatchingPuzzleView>
    with TickerProviderStateMixin {
  final PatternService _pattern = PatternService();
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final AnimationController _feedbackController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _feedbackAnimation;

  PuzzleProvider? _providerRef;
  bool _resultShown = false;
  bool _showFeedback = false;
  bool _isCorrect = false;
  String _feedbackTitle = '';
  String _feedbackSubtitle = '';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
    _feedbackAnimation = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(parent: _feedbackController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _slideController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isTr = context.read<LocalizationProvider>().isTr;
      _providerRef = context.read<PuzzleProvider>();
      _providerRef!.addListener(_onProviderChanged);
      if (!_providerRef!.matchingSessionActive &&
          !_providerRef!.matchingSessionCompleted &&
          !_providerRef!.matchingSessionFailed) {
        _providerRef!.startMatchingSession(
          turkish: isTr,
          first20Only: widget.first20Only,
        );
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

  void _onProviderChanged() {
    final provider = _providerRef;
    if (provider == null) return;

    if (!_resultShown &&
        (provider.matchingSessionCompleted || provider.matchingSessionFailed)) {
      _resultShown = true;
      final isTr = context.read<LocalizationProvider>().isTr;
      _showResultDialog(
        isTr: isTr,
        success: provider.matchingSessionCompleted,
        correct: provider.matchingCorrect,
        wrong: provider.matchingWrong,
      );
    }

    final status = provider.matchingRoundStatus;
    if (status == PuzzleRoundStatus.success ||
        status == PuzzleRoundStatus.failure) {
      final round = provider.currentMatchingRound;
      if (round != null && !_showFeedback) {
        _showMatchingFeedback(status == PuzzleRoundStatus.success, round);
      }
    }

    if (_resultShown && provider.matchingSessionActive) {
      _resultShown = false;
    }
  }

  void _showMatchingFeedback(bool isSuccess, MatchingRound round) {
    if (_showFeedback) return;
    final isTr = context.read<LocalizationProvider>().isTr;
    setState(() {
      _showFeedback = true;
      _isCorrect = isSuccess;
      _feedbackTitle = isSuccess
          ? (isTr ? 'Harika!' : 'Great Job!')
          : (isTr ? 'Yanlış!' : 'Wrong!');
      _feedbackSubtitle = isSuccess
          ? (isTr ? 'Tüm eşleşmeler doğru.' : 'All matches correct.')
          : (isTr
                ? 'Doğru eşleşmeler: ' +
                      round.correctPairs.entries
                          .map((e) => '${e.key} - ${e.value}')
                          .join(', ')
                : 'Correct matches: ' +
                      round.correctPairs.entries
                          .map((e) => '${e.key} - ${e.value}')
                          .join(', '));
    });

    _feedbackController.forward().then((_) async {
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      await _feedbackController.reverse();
      if (!mounted) return;
      setState(() {
        _showFeedback = false;
      });
      await context.read<PuzzleProvider>().loadNextMatchingRound();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _pattern.getPatternPainter(
                  type: PatternType.atomic,
                  color: Colors.white,
                  opacity: 0.02,
                ),
              ),
            ),
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.16,
                      child: _MatchingHeader(
                        onClose: () => _handleExit(context),
                      ),
                    ),
                    Expanded(
                      child: _MatchingContent(
                        onPairSelected: (left, right) {
                          context.read<PuzzleProvider>().setMatching(
                            left,
                            right,
                          );
                        },
                        showFeedback: _showFeedback,
                        isCorrect: _isCorrect,
                        feedbackTitle: _feedbackTitle,
                        feedbackSubtitle: _feedbackSubtitle,
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

  Future<void> _handleExit(BuildContext context) async {
    final provider = context.read<PuzzleProvider>();
    final isTr = context.read<LocalizationProvider>().isTr;
    if (provider.matchingSessionActive) {
      final shouldExit =
          await showDialog<bool>(
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
                    ? 'Çıkarsanız mevcut tur kaybolacak. Emin misiniz?'
                    : 'If you exit now, your progress will be lost. Are you sure?',
                style: TextStyle(color: AppColors.white.withValues(alpha: 0.8)),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    isTr ? 'İptal' : 'Cancel',
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
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
          ) ??
          false;
      if (!shouldExit) return;
    }

    provider.resetMatchingSessionFlags();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => TestsHomeView()),
      (route) => false,
    );
  }

  Future<void> _maybeShowAchievementsCongrats(
    PuzzleProvider provider,
    PuzzleType type,
  ) async {
    final newlyEarned = provider.consumeLastEarnedBadges();
    if (newlyEarned.isEmpty) return;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _PuzzleAchievementCongratsDialog(
        badges: newlyEarned,
        type: type,
        onHome: () {
          provider.resetMatchingSessionFlags();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => TestsHomeView()),
            (route) => false,
          );
        },
      ),
    );
  }

  Future<void> _showResultDialog({
    required bool isTr,
    required bool success,
    required int correct,
    required int wrong,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ModernGameResultDialog(
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
          if (rewardEarned && mounted) {
            _providerRef?.continueMatchingAfterReward();
            setState(() {
              _showFeedback = false;
            });
            _resultShown = false;
          } else if (mounted) {
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
          await _maybeShowAchievementsCongrats(
            _providerRef!,
            PuzzleType.matching,
          );
          // Show ad after dialog is closed
          await Future.delayed(const Duration(milliseconds: 500));
          await InterstitialAdManager.instance.showAdOnAction(context);
          _providerRef?.resetMatchingSessionFlags();
          _providerRef?.startMatchingSession(
            turkish: isTr,
            first20Only: widget.first20Only,
          );
          setState(() {
            _showFeedback = false;
          });
          _resultShown = false;
        },
        onHome: () async {
          Navigator.of(context).pop();
          await _maybeShowAchievementsCongrats(
            _providerRef!,
            PuzzleType.matching,
          );
          // Show ad after dialog is closed
          await Future.delayed(const Duration(milliseconds: 500));
          await InterstitialAdManager.instance.showAdOnAction(context);
          _providerRef?.resetMatchingSessionFlags();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => TestsHomeView()),
            (route) => false,
          );
        },
        playAgainText: isTr ? 'Tekrar Oyna' : 'Play Again',
        homeText: isTr ? 'Ana Sayfa' : 'Home',
        successIcon: Icons.emoji_events_rounded,
        failureIcon: Icons.refresh_rounded,
      ),
    );
  }
}

class _MatchingHeader extends StatelessWidget {
  final VoidCallback? onClose;
  const _MatchingHeader({this.onClose});

  @override
  Widget build(BuildContext context) {
    final isTr = context.watch<LocalizationProvider>().isTr;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBlue.withValues(alpha: 0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                    isTr ? 'Eşleştirme Oyunu' : 'Matching Puzzle',
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
                    children: const [
                      Icon(Icons.link, color: AppColors.turquoise, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Match',
                        style: TextStyle(
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
            Row(
              children: [
                SizedBox(
                  width: 220,
                  child: Consumer<PuzzleProvider>(
                    builder: (context, p, _) {
                      final progress =
                          p.matchingRoundIndex / p.matchingTotalRoundsCount;
                      final roundLabel =
                          '${p.matchingRoundIndex + 1}/${p.matchingTotalRoundsCount}';
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                roundLabel,
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
                Consumer<PuzzleProvider>(
                  builder: (context, p, _) => Row(
                    children: [
                      _compactStat(
                        Icons.check_circle,
                        p.matchingCorrect.toString(),
                        AppColors.glowGreen,
                      ),
                      const SizedBox(width: 6),
                      _compactStat(
                        Icons.cancel,
                        p.matchingWrong.toString(),
                        AppColors.powderRed,
                      ),
                      const SizedBox(width: 6),
                      _compactStat(
                        Icons.favorite,
                        p.getMatchingAttemptsLeft(context).toString(),
                        AppColors.pink,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _compactStat(IconData icon, String value, Color color) {
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

class _MatchingContent extends StatelessWidget {
  final void Function(String left, String right) onPairSelected;
  final bool showFeedback;
  final bool isCorrect;
  final String feedbackTitle;
  final String feedbackSubtitle;
  final Animation<double> feedbackAnimation;

  const _MatchingContent({
    required this.onPairSelected,
    required this.showFeedback,
    required this.isCorrect,
    required this.feedbackTitle,
    required this.feedbackSubtitle,
    required this.feedbackAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final round = context.select<PuzzleProvider, MatchingRound?>(
      (p) => p.currentMatchingRound,
    );
    final status = context.select<PuzzleProvider, PuzzleRoundStatus>(
      (p) => p.matchingRoundStatus,
    );
    final isRoundActive = status == PuzzleRoundStatus.playing;

    if (round == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.white),
      );
    }

    final userMatches = round.userMatches;
    // Provider now determines pair count per level; show all pairs in round
    final List<String> visibleLeft = round.leftItems;
    final List<String> visibleRight = round.rightItems;
    final leftSymbols = context.select<PuzzleProvider, Map<String, String>>(
      (p) => p.matchingLeftSymbols,
    );

    // Distinct color per correct pair, consistent across left and right
    final List<Color> _pairPalette = [
      AppColors.yellow,
      AppColors.pink,
      AppColors.purple,
      AppColors.turquoise,
      AppColors.lightGreen,
      AppColors.darkTurquoise,
      AppColors.darkWhite,
      AppColors.skinColor,
      AppColors.glowGreen,
      AppColors.powderRed,
      AppColors.steelBlue,
    ];
    final Map<String, Color> _numberToColor = {
      for (int i = 0; i < visibleLeft.length; i++)
        visibleLeft[i]: _pairPalette[i % _pairPalette.length],
    };
    final Map<String, Color> _nameToColor = {
      for (final entry in round.correctPairs.entries)
        entry.value: _numberToColor[entry.key] ?? AppColors.purple,
    };

    return Column(
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _MatchingInfoCard(),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = math.min(constraints.maxWidth, 520.0);
                return Column(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: maxWidth,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: visibleLeft.map((number) {
                                  final matched = userMatches[number];
                                  final symbol = leftSymbols[number] ?? '';
                                  return _MatchingLeftCard(
                                    number: number,
                                    elementSymbol: symbol,
                                    matchedValue: matched,
                                    isRoundActive: isRoundActive,
                                    pairColor:
                                        _numberToColor[number] ??
                                        AppColors.purple,
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const VerticalDivider(
                              color: Colors.transparent,
                              width: 16,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: visibleRight.map((name) {
                                  final matchedEntry = userMatches.entries
                                      .firstWhere(
                                        (entry) => entry.value == name,
                                        orElse: () => const MapEntry('', null),
                                      );
                                  final matchedNumber =
                                      matchedEntry.value == null
                                      ? null
                                      : matchedEntry.key;
                                  return _MatchingRightCard(
                                    name: name,
                                    matchedNumber: matchedNumber,
                                    isRoundActive: isRoundActive,
                                    onAccept: (leftNumber) =>
                                        onPairSelected(leftNumber, name),
                                    pairColor:
                                        _nameToColor[name] ?? AppColors.purple,
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.08),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: showFeedback
                          ? _MatchingFeedbackCard(
                              isCorrect: isCorrect,
                              title: feedbackTitle,
                              subtitle: feedbackSubtitle,
                              animation: feedbackAnimation,
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _MatchingInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isTr = context.read<LocalizationProvider>().isTr;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
            color: AppColors.turquoise.withValues(alpha: 0.12),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.turquoise.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.turquoise.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.touch_app,
              color: AppColors.turquoise,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isTr
                  ? 'Soldaki atom numaralarını sağdaki doğru element isimleriyle eşleştir.'
                  : 'Match the atomic numbers on the left with the correct element names on the right.',
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchingLeftCard extends StatelessWidget {
  final String number;
  final String elementSymbol;
  final String? matchedValue;
  final bool isRoundActive;
  final Color pairColor;

  const _MatchingLeftCard({
    required this.number,
    required this.elementSymbol,
    required this.matchedValue,
    required this.isRoundActive,
    required this.pairColor,
  });

  @override
  Widget build(BuildContext context) {
    final matched = matchedValue != null;
    final gradient = matched
        ? [pairColor.withValues(alpha: 0.75), pairColor.withValues(alpha: 0.55)]
        : [
            AppColors.darkBlue.withValues(alpha: 0.6),
            AppColors.darkBlue.withValues(alpha: 0.43),
          ];

    Widget card({bool highlight = false}) => AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 6),
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: highlight
              ? [
                  AppColors.turquoise.withValues(alpha: 0.35),
                  AppColors.turquoise.withValues(alpha: 0.25),
                ]
              : gradient,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight
              ? AppColors.turquoise
              : matched
              ? pairColor
              : Colors.white.withValues(alpha: 0.25),
          width: highlight ? 2.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                number,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Text(
                elementSymbol,
                style: TextStyle(
                  color: AppColors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (matchedValue != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                matchedValue!,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            Icon(
              Icons.outbond_rounded,
              size: 18,
              color: Colors.white.withValues(alpha: 0.6),
            ),
        ],
      ),
    );

    if (!isRoundActive) return card();

    return Draggable<String>(
      data: 'num:$number',
      feedback: Material(
        color: Colors.transparent,
        child: card(highlight: true),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: card()),
      child: DragTarget<String>(
        onWillAccept: (data) => (data ?? '').startsWith('name:'),
        onAccept: (data) {
          final name = data.replaceFirst('name:', '');
          HapticFeedback.mediumImpact();
          context.read<PuzzleProvider>().setMatching(number, name);
        },
        builder: (context, candidate, rejected) =>
            card(highlight: candidate.isNotEmpty),
      ),
    );
  }
}

class _MatchingRightCard extends StatelessWidget {
  final String name;
  final String? matchedNumber;
  final bool isRoundActive;
  final void Function(String leftNumber) onAccept;
  final Color pairColor;

  const _MatchingRightCard({
    required this.name,
    required this.matchedNumber,
    required this.isRoundActive,
    required this.onAccept,
    required this.pairColor,
  });

  @override
  Widget build(BuildContext context) {
    final matched = matchedNumber != null;
    final gradient = matched
        ? [pairColor.withValues(alpha: 0.7), pairColor.withValues(alpha: 0.5)]
        : [
            AppColors.darkBlue.withValues(alpha: 0.5),
            AppColors.darkBlue.withValues(alpha: 0.35),
          ];

    Widget card({bool highlight = false}) => AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 6),
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: highlight
              ? [
                  AppColors.turquoise.withValues(alpha: 0.35),
                  AppColors.turquoise.withValues(alpha: 0.25),
                ]
              : gradient,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight
              ? AppColors.turquoise
              : matched
              ? pairColor
              : Colors.white.withValues(alpha: 0.25),
          width: highlight ? 2.0 : 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            matchedNumber != null
                ? (context.read<LocalizationProvider>().isTr
                      ? 'Numara: $matchedNumber'
                      : 'Number: $matchedNumber')
                : (context.read<LocalizationProvider>().isTr
                      ? 'Sürükle veya bırak'
                      : 'Drag or drop'),
            style: TextStyle(
              color: AppColors.white.withValues(
                alpha: matchedNumber != null ? 0.85 : 0.6,
              ),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );

    if (!isRoundActive) return card();

    return Draggable<String>(
      data: 'name:$name',
      feedback: Material(
        color: Colors.transparent,
        child: card(highlight: true),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: card()),
      child: DragTarget<String>(
        onWillAccept: (data) => (data ?? '').startsWith('num:'),
        onAccept: (data) {
          final leftNumber = data.replaceFirst('num:', '');
          HapticFeedback.mediumImpact();
          onAccept(leftNumber);
        },
        builder: (context, candidate, rejected) =>
            card(highlight: candidate.isNotEmpty),
      ),
    );
  }
}

class _MatchingFeedbackCard extends StatelessWidget {
  final bool isCorrect;
  final String title;
  final String subtitle;
  final Animation<double> animation;

  const _MatchingFeedbackCard({
    required this.isCorrect,
    required this.title,
    required this.subtitle,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final primary = isCorrect ? AppColors.glowGreen : AppColors.powderRed;
    final secondary = isCorrect ? AppColors.turquoise : AppColors.pink;
    final icon = isCorrect ? Icons.check_circle : Icons.cancel;

    return ScaleTransition(
      scale: animation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primary.withValues(alpha: 0.9),
              secondary.withValues(alpha: 0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primary.withValues(alpha: 0.6), width: 2),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.3),
              offset: const Offset(0, 8),
              blurRadius: 20,
            ),
          ],
        ),
        child: Row(
          children: [
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
          ],
        ),
      ),
    );
  }
}

class _PuzzleAchievementCongratsDialog extends StatelessWidget {
  final List<PuzzleBadge> badges;
  final PuzzleType type;
  final VoidCallback? onHome;

  const _PuzzleAchievementCongratsDialog({
    required this.badges,
    required this.type,
    this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final isTr = context.watch<LocalizationProvider>().isTr;
    final colors = _getTypeColors(type);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors.primary.withValues(alpha: 0.95),
              Colors.white.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: AppColors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isTr
                        ? 'Tebrikler! Yeni başarımlar kazandın'
                        : 'Congrats! You earned new achievements',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...badges.take(3).map((b) => _buildBadgeRow(b, isTr)).toList(),
            if (badges.length > 3) ...[
              const SizedBox(height: 8),
              Text(
                isTr
                    ? '+${badges.length - 3} diğer başarı'
                    : '+${badges.length - 3} more',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
              ),
            ],
            const SizedBox(height: 20),
            // First row: Awesome and View Achievements
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isTr ? 'Harika!' : 'Awesome!',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TriviaAchievementsView(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isTr ? 'Başarıları Gör' : 'View Achievements',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Second row: Home button (if onHome callback is provided)
            if (onHome != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onHome!();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isTr ? 'Ana Sayfa' : 'Home',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeRow(PuzzleBadge badge, bool isTr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star, color: AppColors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTr ? badge.titleTr : badge.titleEn,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  isTr ? badge.descriptionTr : badge.descriptionEn,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ({Color primary, Color secondary}) _getTypeColors(PuzzleType type) {
    switch (type) {
      case PuzzleType.word:
        return (primary: AppColors.glowGreen, secondary: AppColors.steelBlue);
      case PuzzleType.matching:
        return (primary: AppColors.steelBlue, secondary: AppColors.glowGreen);
      case PuzzleType.crossword:
      case PuzzleType.placement:
        return (primary: AppColors.glowGreen, secondary: AppColors.steelBlue);
    }
  }
}

// Clear button removed per UX update
