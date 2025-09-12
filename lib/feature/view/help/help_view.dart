import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/product/widget/button/back_button.dart';
import 'package:elements_app/core/services/pattern/pattern_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class HelpView extends StatefulWidget {
  const HelpView({super.key});

  @override
  State<HelpView> createState() => _HelpViewState();
}

class _HelpViewState extends State<HelpView> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final PatternService _patternService = PatternService();
  int? _pressedCardIndex;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTr = context.watch<LocalizationProvider>().isTr;

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
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  children: [
                    _buildHelpSection(
                      context,
                      index: 0,
                      title: isTr ? 'Elementleri Keşfedin' : 'Explore Elements',
                      icon: Icons.science,
                      color: AppColors.purple,
                      items: [
                        isTr
                            ? '• Tüm elementleri listeleyin ve detaylı bilgilere ulaşın'
                            : '• List all elements and access detailed information',
                        isTr
                            ? '• Grid veya liste görünümü arasında geçiş yapın'
                            : '• Switch between grid and list views',
                        isTr
                            ? '• Element detaylarında interaktif özellikler keşfedin'
                            : '• Discover interactive features in element details',
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildHelpSection(
                      context,
                      index: 1,
                      title: isTr ? 'Grupları İnceleyin' : 'Explore Groups',
                      icon: Icons.category,
                      color: AppColors.yellow,
                      items: [
                        isTr
                            ? '• Metal, ametal ve yarı metal gruplarını keşfedin'
                            : '• Explore metal, nonmetal and metalloid groups',
                        isTr
                            ? '• Her grubun özelliklerini öğrenin'
                            : '• Learn properties of each group',
                        isTr
                            ? '• Gruplar arası karşılaştırmalar yapın'
                            : '• Make comparisons between groups',
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildHelpSection(
                      context,
                      index: 2,
                      title: isTr
                          ? 'Bilginizi Test Edin'
                          : 'Test Your Knowledge',
                      icon: Icons.quiz,
                      color: AppColors.powderRed,
                      items: [
                        isTr
                            ? '• Farklı zorluk seviyelerinde quizler çözün'
                            : '• Solve quizzes at different difficulty levels',
                        isTr
                            ? '• Element sembolleri ve özellikleri hakkında pratik yapın'
                            : '• Practice element symbols and properties',
                        isTr
                            ? '• Skorunuzu takip edin ve kendinizi geliştirin'
                            : '• Track your score and improve yourself',
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildHelpSection(
                      context,
                      index: 3,
                      title: isTr ? 'Özelleştirin' : 'Customize',
                      icon: Icons.settings,
                      color: AppColors.turquoise,
                      items: [
                        isTr
                            ? '• Dil seçeneğini değiştirin'
                            : '• Change language preference',
                        isTr
                            ? '• Görünüm tercihlerinizi ayarlayın'
                            : '• Adjust your view preferences',
                        isTr ? '• Geri bildirim gönderin' : '• Send feedback',
                      ],
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

  AppBar _buildModernAppBar() {
    final isTr = context.watch<LocalizationProvider>().isTr;

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
              Icons.lightbulb_outline,
              color: AppColors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isTr ? 'İpuçları ve Yardım' : 'Tips & Help',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      elevation: 0,
    );
  }

  Widget _buildHelpSection(
    BuildContext context, {
    required int index,
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    final isPressed = _pressedCardIndex == index;

    return AnimatedScale(
      scale: isPressed ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.9),
              color.withValues(alpha: 0.7),
              color.withValues(alpha: 0.5),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background pattern
              Positioned.fill(
                child: CustomPaint(
                  painter: _patternService.getPatternPainter(
                    type: PatternType.molecular,
                    color: Colors.white,
                    opacity: 0.05,
                  ),
                ),
              ),
              // Decorative elements
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Content
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTapDown: (_) {
                    setState(() {
                      _pressedCardIndex = index;
                    });
                  },
                  onTapUp: (_) {
                    setState(() {
                      _pressedCardIndex = null;
                    });
                    HapticFeedback.lightImpact();
                  },
                  onTapCancel: () {
                    setState(() {
                      _pressedCardIndex = null;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
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
                              child: Icon(icon, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
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
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ...items
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
