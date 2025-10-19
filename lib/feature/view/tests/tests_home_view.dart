import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/core/services/pattern/pattern_service.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/product/constants/assets_constants.dart';
import 'package:elements_app/feature/view/quiz/modern_quiz_home.dart';
import 'package:elements_app/feature/view/puzzles/puzzles_home_view.dart';
import 'package:elements_app/feature/view/puzzles/trivia_center_view.dart';
import 'package:elements_app/feature/view/home/home_view.dart';
import 'package:elements_app/product/widget/ads/banner_ads_widget.dart';
import 'package:elements_app/feature/provider/quiz_provider.dart';
import 'package:elements_app/product/widget/button/back_button.dart';

class TestsHomeView extends StatefulWidget {
  const TestsHomeView({super.key});

  @override
  State<TestsHomeView> createState() => _TestsHomeViewState();
}

class _TestsHomeViewState extends State<TestsHomeView>
    with TickerProviderStateMixin {
  final PatternService _pattern = PatternService();
  int? _pressedIndex;

  @override
  Widget build(BuildContext context) {
    final isTr = context.watch<LocalizationProvider>().isTr;
    return AppScaffold(
      child: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeView()),
            (route) => false,
          );
          return false;
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.darkBlue,
            leading: const ModernBackButton(),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.games,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    isTr ? 'Oyunlar' : 'Games',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            elevation: 0,
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _pattern.getPatternPainter(
                    type: PatternType.atomic,
                    color: Colors.white,
                    opacity: 0.03,
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Consumer<QuizProvider>(
                        builder: (context, quizProvider, _) {
                          return _buildModernElementSelector(
                            context,
                            isFirst20: quizProvider.useFirst20Elements,
                            onToggle: (value) =>
                                quizProvider.setUseFirst20Elements(value),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      const BannerAdsWidget(showLoadingIndicator: true),
                      const SizedBox(height: 16),
                      _buildCard(
                        context,
                        title: isTr ? 'Quizler' : 'Quizzes',
                        subtitle: isTr ? 'Bilgi Testleri' : 'Knowledge Quizzes',
                        iconSvg: AssetConstants.instance.svgGameThree,
                        color: AppColors.pink,
                        shadow: AppColors.shPink,
                        index: 0,
                        icon: Icons.quiz,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ModernQuizHome(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCard(
                        context,
                        title: isTr ? 'Bulmacalar' : 'Puzzles',
                        subtitle: isTr
                            ? 'Kelime, eşleştirme ve daha fazlası'
                            : 'Word, matching and more',
                        iconSvg: AssetConstants.instance.svgGameThree,
                        color: AppColors.steelBlue,
                        shadow: AppColors.shSteelBlue,
                        index: 1,
                        icon: Icons.extension,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PuzzlesHomeView(
                              first20Only: context
                                  .read<QuizProvider>()
                                  .useFirst20Elements,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCard(
                        context,
                        title: isTr ? 'Element Trivia' : 'Element Trivia',
                        subtitle: isTr
                            ? 'Kategori seç ve trivia çöz'
                            : 'Pick a category and play',
                        iconSvg: AssetConstants.instance.svgGameThree,
                        color: AppColors.turquoise,
                        shadow: AppColors.shTurquoise,
                        index: 2,
                        icon: Icons.psychology,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TriviaCenterView(
                              first20Only: context
                                  .read<QuizProvider>()
                                  .useFirst20Elements,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String iconSvg,
    required Color color,
    required Color shadow,
    required VoidCallback onTap,
    required int index,
    required IconData icon,
  }) {
    final isTr = context.read<LocalizationProvider>().isTr;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressedIndex = index),
      onTapCancel: () => setState(() => _pressedIndex = null),
      onTap: () {
        setState(() => _pressedIndex = null);
        onTap();
      },
      onTapUp: (_) => setState(() => _pressedIndex = null),
      child: AnimatedScale(
        scale: _pressedIndex == index ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15), // Element color background
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withValues(alpha: 0.4), // Element color border
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3), // Element color shadow
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
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.6), // Card color
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: color.withValues(alpha: 0.8),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: shadow.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _chip(isTr ? 'Popüler' : 'Popular', Colors.white),
                        const SizedBox(width: 8),
                        _chip(isTr ? 'Zorlayıcı' : 'Challenging', Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  isTr ? 'Başla' : 'Start',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildModernElementSelector(
    BuildContext context, {
    required bool isFirst20,
    required Function(bool) onToggle,
  }) {
    final isTr = context.read<LocalizationProvider>().isTr;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1), // Opacity white background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2), // Opacity white border
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isFirst20 ? AppColors.glowGreen : AppColors.steelBlue)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        (isFirst20 ? AppColors.glowGreen : AppColors.steelBlue)
                            .withValues(alpha: 0.4),
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    isFirst20 ? Icons.science : Icons.all_inclusive,
                    key: ValueKey(isFirst20),
                    color: isFirst20
                        ? AppColors.glowGreen
                        : AppColors.steelBlue,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTr ? 'Element Seçimi' : 'Element Selection',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      child: Text(
                        isFirst20
                            ? (isTr
                                  ? 'İlk 20 element ile başla'
                                  : 'Start with first 20 elements')
                            : (isTr
                                  ? 'Tüm 118 elementi keşfet'
                                  : 'Explore all 118 elements'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 50,

            child: Row(
              children: [
                Expanded(
                  child: _buildSelectorOption(
                    context,
                    title: isTr ? 'İlk 20' : 'First 20',
                    subtitle: isTr ? 'Kolay' : 'Easy',
                    isSelected: isFirst20,
                    color: AppColors.glowGreen,
                    onTap: () => onToggle(true),
                  ),
                ),
                Expanded(
                  child: _buildSelectorOption(
                    context,
                    title: isTr ? 'Tümü' : 'All',
                    subtitle: isTr ? 'Zorlu' : 'Challenging',
                    isSelected: !isFirst20,
                    color: AppColors.steelBlue,
                    onTap: () => onToggle(false),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.8),
                    color.withValues(alpha: 0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.15),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                child: Text(title),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.9)
                      : Colors.white.withValues(alpha: 0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                child: Text(subtitle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
