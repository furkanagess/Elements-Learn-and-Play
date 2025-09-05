import 'package:elements_app/feature/provider/favorite_elements_provider.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/feature/view/elementDetail/element_detail_view.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/constants/stringConstants/en_app_strings.dart';
import 'package:elements_app/product/constants/stringConstants/tr_app_strings.dart';
import 'package:elements_app/product/extensions/color_extension.dart';
import 'package:elements_app/product/extensions/context_extensions.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:elements_app/product/constants/assets_constants.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Modern App Bar
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppColors.darkBlue,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.darkBlue,
                          AppColors.darkBlue.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                    child: _buildHeader(context),
                  ),
                ),
                leading: BackButton(),
              ),

              // Content
              Consumer<FavoriteElementsProvider>(
                builder: (context, provider, child) {
                  if (provider.favoriteElements.isEmpty) {
                    return SliverFillRemaining(
                      child: _buildEmptyState(context),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final element = provider.favoriteElements[index];
                          return _buildFavoriteCard(context, element);
                        },
                        childCount: provider.favoriteElements.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        // Background pattern
        Positioned.fill(
          child: CustomPaint(
            painter: FavoritesPatternPainter(),
          ),
        ),
        // Content
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.favorite,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.read<LocalizationProvider>().isTr
                          ? 'Favori Elementler'
                          : 'Favorite Elements',
                      style: context.textTheme.headlineMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Consumer<FavoriteElementsProvider>(
                      builder: (context, provider, child) {
                        return Text(
                          context.read<LocalizationProvider>().isTr
                              ? '${provider.favoriteElements.length} element'
                              : '${provider.favoriteElements.length} elements',
                          style: TextStyle(
                            color: AppColors.white.withValues(alpha: 0.9),
                            fontSize: 16,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            AssetConstants.instance.lottieNewHeart,
            height: 200,
            repeat: true,
          ),
          const SizedBox(height: 24),
          Text(
            context.read<LocalizationProvider>().isTr
                ? 'Henüz favori element eklemediniz'
                : 'No favorite elements yet',
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.8),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            context.read<LocalizationProvider>().isTr
                ? 'Element detay sayfasından favorilerinize element ekleyebilirsiniz'
                : 'You can add elements to your favorites from the element detail page',
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.6),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(BuildContext context, element) {
    Color elementColor;
    Color shadowColor;

    try {
      if (element.colors is String) {
        elementColor = (element.colors as String).toColor();
      } else if (element.colors != null) {
        elementColor = element.colors!.toColor();
      } else {
        elementColor = AppColors.darkBlue;
      }

      if (element.shColor is String) {
        shadowColor = (element.shColor as String).toColor();
      } else if (element.shColor != null) {
        shadowColor = element.shColor!.toColor();
      } else {
        shadowColor = AppColors.background;
      }
    } catch (e) {
      elementColor = AppColors.darkBlue;
      shadowColor = AppColors.background;
    }

    final isTr = context.read<LocalizationProvider>().isTr;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            elementColor,
            elementColor.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.3),
            offset: const Offset(0, 8),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ElementDetailView(element: element),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Element number
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      element.number?.toString() ?? '',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // Element info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        element.symbol ?? '',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isTr ? element.trName ?? '' : element.enName ?? '',
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatWeight(element.weight),
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Remove from favorites button
                IconButton(
                  icon: Icon(
                    Icons.favorite,
                    color: AppColors.white.withValues(alpha: 0.9),
                    size: 24,
                  ),
                  onPressed: () {
                    context
                        .read<FavoriteElementsProvider>()
                        .toggleFavorite(element);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Formats the weight string to show 4 decimal places
  String _formatWeight(String? weight) {
    if (weight == null || weight.isEmpty) return '';

    // Try to parse as double and format to 4 decimal places
    final doubleValue = double.tryParse(weight.replaceAll(',', '.'));
    if (doubleValue != null) {
      return doubleValue.toStringAsFixed(4);
    }

    // If parsing fails, return original value
    return weight;
  }
}

class FavoritesPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    // Draw subtle pattern
    for (int i = 0; i < size.width; i += 40) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        paint,
      );
    }
    for (int i = 0; i < size.height; i += 40) {
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(size.width, i.toDouble()),
        paint,
      );
    }

    // Draw some circles for visual interest
    final circlePaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final x = (i * 80) % size.width;
      final y = (i * 60) % size.height;
      canvas.drawCircle(Offset(x, y), 20, circlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
