import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HelpView extends StatelessWidget {
  const HelpView({super.key});

  @override
  Widget build(BuildContext context) {
    final isTr = context.watch<LocalizationProvider>().isTr;

    return AppScaffold(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverAppBar(
                backgroundColor: AppColors.background,
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.glowGreen,
                          AppColors.glowGreen.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.lightbulb_outline,
                            color: AppColors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isTr ? 'İpuçları ve Yardım' : 'Tips & Help',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isTr
                              ? 'Uygulamayı en iyi şekilde kullanın'
                              : 'Get the most out of the app',
                          style: TextStyle(
                            color: AppColors.white.withValues(alpha: 0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHelpSection(
                      context,
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
                    const SizedBox(height: 24),
                    _buildHelpSection(
                      context,
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
                    const SizedBox(height: 24),
                    _buildHelpSection(
                      context,
                      title:
                          isTr ? 'Bilginizi Test Edin' : 'Test Your Knowledge',
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
                    const SizedBox(height: 24),
                    _buildHelpSection(
                      context,
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
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...items
              .map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      item,
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }
}
