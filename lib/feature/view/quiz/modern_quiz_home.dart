import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elements_app/feature/provider/quiz_provider.dart';
import 'package:elements_app/feature/provider/admob_provider.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/feature/model/quiz/quiz_models.dart';
import 'package:elements_app/feature/view/quiz/unified_quiz_view.dart';
import 'package:elements_app/feature/view/quiz/quiz_statistics_view.dart';
import 'package:elements_app/feature/view/home/home_view.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/core/services/pattern/pattern_service.dart';
import 'package:flutter/services.dart';

/// Modern quiz home view with statistics and quiz selection
class ModernQuizHome extends StatefulWidget {
  const ModernQuizHome({super.key});

  @override
  State<ModernQuizHome> createState() => _ModernQuizHomeState();
}

class _ModernQuizHomeState extends State<ModernQuizHome>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Animation controllers for 3D button effects
  late AnimationController _statisticsScaleController;
  late Animation<double> _statisticsScaleAnimation;

  // Map to store scale controllers for each quiz card
  final Map<QuizType, AnimationController> _quizScaleControllers = {};
  final Map<QuizType, Animation<double>> _quizScaleAnimations = {};

  final PatternService _patternService = PatternService();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Initialize statistics scale animation
    _statisticsScaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _statisticsScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _statisticsScaleController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  String _localizedDifficulty(String difficulty) {
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
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _statisticsScaleController.dispose();

    // Dispose all quiz scale controllers
    for (var controller in _quizScaleControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  // Animation methods for statistics card
  void _onStatisticsTapDown(TapDownDetails details) {
    _statisticsScaleController.forward();
  }

  void _onStatisticsTapUp(TapUpDetails details) {
    _statisticsScaleController.reverse();
    HapticFeedback.lightImpact();
    _navigateToStatistics();
  }

  void _onStatisticsTapCancel() {
    _statisticsScaleController.reverse();
  }

  void _navigateToStatistics() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QuizStatisticsView()),
    );
  }

  // Animation methods for quiz cards
  void _onQuizCardTapDown(TapDownDetails details, QuizType type) {
    _getOrCreateQuizScaleController(type).forward();
  }

  void _onQuizCardTapUp(TapUpDetails details, QuizType type) {
    _getOrCreateQuizScaleController(type).reverse();
    HapticFeedback.lightImpact();
    _startQuiz(type);
  }

  void _onQuizCardTapCancel(QuizType type) {
    _getOrCreateQuizScaleController(type).reverse();
  }

  // Helper method to get or create scale controller for each quiz card
  AnimationController _getOrCreateQuizScaleController(QuizType type) {
    if (!_quizScaleControllers.containsKey(type)) {
      _quizScaleControllers[type] = AnimationController(
        duration: const Duration(milliseconds: 150),
        vsync: this,
      );
      _quizScaleAnimations[type] = Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(
          parent: _quizScaleControllers[type]!,
          curve: Curves.easeInOut,
        ),
      );
    }
    return _quizScaleControllers[type]!;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildModernAppBar(),
        body: Stack(
          children: [
            // Background Pattern
            Positioned.fill(
              child: CustomPaint(
                painter: _patternService.getPatternPainter(
                  type: PatternType.atomic,
                  color: Colors.white,
                  opacity: 0.03,
                ),
              ),
            ),

            // Content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildStatisticsCard(),
                      const SizedBox(height: 16),
                      _buildQuizTypesSection(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildModernAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.glowGreen,
              AppColors.yellow.withValues(alpha: 0.95),
              AppColors.darkBlue.withValues(alpha: 0.9),
            ],
          ),
        ),
      ),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.white,
          size: 20,
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeView()),
            (route) => false,
          );
        },
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.quiz, color: AppColors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            context.watch<LocalizationProvider>().isTr
                ? 'Quiz Merkezi'
                : 'Quiz Center',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    final isTr = context.watch<LocalizationProvider>().isTr;
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTapDown: _onStatisticsTapDown,
        onTapUp: _onStatisticsTapUp,
        onTapCancel: _onStatisticsTapCancel,
        child: AnimatedBuilder(
          animation: _statisticsScaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _statisticsScaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.purple.withValues(alpha: 0.9),
                      AppColors.pink.withValues(alpha: 0.7),
                      AppColors.turquoise.withValues(alpha: 0.5),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.purple.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: AppColors.pink.withValues(alpha: 0.2),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.analytics_rounded,
                        color: AppColors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isTr ? 'İstatistikler' : 'Statistics',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isTr
                                ? 'Performansını görüntüle, en iyi skorlarını incele'
                                : 'View your performance and best scores',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.white.withValues(alpha: 0.9),
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuizTypesSection() {
    final isTr = context.watch<LocalizationProvider>().isTr;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isTr ? 'Quiz Türleri' : 'Quiz Types',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...QuizType.values.map((type) => _buildQuizTypeCard(type)).toList(),
      ],
    );
  }

  Widget _buildQuizTypeCard(QuizType type) {
    final colors = _getQuizTypeColors(type);
    final isTr = context.watch<LocalizationProvider>().isTr;

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTapDown: (details) => _onQuizCardTapDown(details, type),
        onTapUp: (details) => _onQuizCardTapUp(details, type),
        onTapCancel: () => _onQuizCardTapCancel(type),
        child: AnimatedBuilder(
          animation: _getOrCreateQuizScaleController(type),
          builder: (context, child) {
            return Transform.scale(
              scale: _quizScaleAnimations[type]?.value ?? 1.0,
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.primary,
                      colors.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow.withValues(alpha: 0.3),
                      offset: const Offset(0, 8),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Background Pattern
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _patternService.getRandomPatternPainter(
                            seed: type.hashCode,
                            color: Colors.white,
                            opacity: 0.08,
                          ),
                        ),
                      ),

                      // Decorative Elements
                      Positioned(
                        top: -15,
                        right: -15,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -10,
                        left: -10,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),

                      // Main Content
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            // Icon
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                type.icon,
                                color: AppColors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 20),

                            // Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    isTr
                                        ? type.turkishTitle
                                        : type.englishTitle,
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black26,
                                          offset: Offset(1, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getQuizDescriptionLocalized(type, isTr),
                                    style: TextStyle(
                                      color: AppColors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.white.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withValues(
                                              alpha: 0.25,
                                            ),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          _localizedDifficulty(type.difficulty),
                                          style: const TextStyle(
                                            color: AppColors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Consumer<QuizProvider>(
                                        builder: (context, provider, child) {
                                          final stats = provider
                                              .getStatisticsForType(type);
                                          return Text(
                                            isTr
                                                ? 'En İyi: %${stats.bestScore.toInt()}'
                                                : 'Best: %${stats.bestScore.toInt()}',
                                            style: TextStyle(
                                              color: AppColors.white.withValues(
                                                alpha: 0.7,
                                              ),
                                              fontSize: 12,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Arrow
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: AppColors.white.withValues(alpha: 0.9),
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _startQuiz(QuizType type) {
    context.read<AdmobProvider>().onRouteChanged();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UnifiedQuizView(quizType: type)),
    );
  }

  ({Color primary, Color shadow}) _getQuizTypeColors(QuizType type) {
    switch (type) {
      case QuizType.symbol:
        return (primary: AppColors.glowGreen, shadow: AppColors.shGlowGreen);
      case QuizType.group:
        return (primary: AppColors.yellow, shadow: AppColors.shYellow);
      case QuizType.number:
        return (primary: AppColors.powderRed, shadow: AppColors.shPowderRed);
    }
  }

  String _getQuizDescriptionLocalized(QuizType type, bool isTr) {
    switch (type) {
      case QuizType.symbol:
        return isTr
            ? 'Sembol verildiğinde element adını bulun'
            : 'Find the element name given its symbol';
      case QuizType.group:
        return isTr
            ? 'Element adı verildiğinde grubunu bulun'
            : 'Find the group given the element name';
      case QuizType.number:
        return isTr
            ? 'Atom numarası verildiğinde element adını bulun'
            : 'Find the element name given the atomic number';
    }
  }
}
