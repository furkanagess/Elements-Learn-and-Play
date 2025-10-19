import 'package:elements_app/core/mixin/animation_mixin.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/feature/provider/periodicTable/periodic_table_provider.dart';
import 'package:elements_app/feature/service/element_of_day_service.dart';
import 'package:elements_app/feature/view/elementDetail/element_detail_view.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/constants/stringConstants/en_app_strings.dart';
import 'package:elements_app/product/constants/stringConstants/tr_app_strings.dart';
import 'package:elements_app/core/services/pattern/pattern_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elements_app/core/services/widget/element_home_widget_service.dart';

class ElementOfDayWidget extends StatefulWidget {
  const ElementOfDayWidget({super.key});

  @override
  State<ElementOfDayWidget> createState() => _ElementOfDayWidgetState();
}

class _ElementOfDayWidgetState extends State<ElementOfDayWidget>
    with TickerProviderStateMixin, AnimationMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  // Pattern service for background patterns
  final PatternService _patternService = PatternService();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _pulseController.repeat(reverse: true);
    _slideController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date, bool isTr) {
    if (isTr) {
      const months = [
        'Ocak',
        'Şubat',
        'Mart',
        'Nisan',
        'Mayıs',
        'Haziran',
        'Temmuz',
        'Ağustos',
        'Eylül',
        'Ekim',
        'Kasım',
        'Aralık',
      ];
      const days = [
        'Pazartesi',
        'Salı',
        'Çarşamba',
        'Perşembe',
        'Cuma',
        'Cumartesi',
        'Pazar',
      ];
      return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
    } else {
      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      const days = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
    }
  }

  Color _getElementColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'alkali metal':
        return AppColors.turquoise;
      case 'alkaline earth metal':
        return AppColors.yellow;
      case 'transition metal':
        return AppColors.purple;
      case 'post-transition metal':
        return AppColors.steelBlue;
      case 'metalloid':
        return AppColors.skinColor;
      case 'reactive nonmetal':
        return AppColors.powderRed;
      case 'noble gas':
        return AppColors.glowGreen;
      case 'halogen':
        return AppColors.lightGreen;
      case 'lanthanide':
        return AppColors.darkTurquoise;
      case 'actinide':
        return AppColors.pink;
      default:
        return AppColors.purple;
    }
  }

  String _getLocalizedCategory(String? category, bool isTr) {
    if (category == null) {
      return isTr ? 'Bilinmeyen Kategori' : 'Unknown Category';
    }

    switch (category.toLowerCase()) {
      case 'alkali metal':
        return isTr ? TrAppStrings.alkaline : EnAppStrings.alkaline;
      case 'alkaline earth metal':
        return isTr ? TrAppStrings.earthAlkaline : EnAppStrings.earthAlkaline;
      case 'transition metal':
        return isTr
            ? TrAppStrings.transitionMetal
            : EnAppStrings.transitionMetal;
      case 'post-transition metal':
        return isTr ? TrAppStrings.postTransition : EnAppStrings.postTransition;
      case 'metalloid':
        return isTr ? TrAppStrings.metalloids : EnAppStrings.metalloids;
      case 'reactive nonmetal':
        return isTr
            ? TrAppStrings.reactiveNonmetal
            : EnAppStrings.reactiveNonmetal;
      case 'noble gas':
        return isTr ? TrAppStrings.nobleGases : EnAppStrings.nobleGases;
      case 'halogen':
        return isTr ? TrAppStrings.halogens : EnAppStrings.halogens;
      case 'lanthanide':
        return isTr ? TrAppStrings.lanthanides : EnAppStrings.lanthanides;
      case 'actinide':
        return isTr ? TrAppStrings.actinides : EnAppStrings.actinides;
      default:
        return isTr ? TrAppStrings.unknown : EnAppStrings.unknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PeriodicTableProvider, LocalizationProvider>(
      builder: (context, periodicProvider, localizationProvider, child) {
        final element = ElementOfDayService.getElementOfDay(
          periodicProvider.state.elements,
        );
        final isTr = localizationProvider.isTr;
        final today = _formatDate(DateTime.now(), isTr);

        if (element == null) {
          return const SizedBox.shrink();
        }

        // Update iOS widget with current element
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ElementHomeWidgetService.updateWidgetDirectly(element);
        });

        final elementColor = _getElementColor(element.enCategory);

        // Get localized strings
        final elementOfDayText = isTr
            ? TrAppStrings.elementOfDay
            : EnAppStrings.elementOfDay;
        final atomicWeightText = isTr
            ? TrAppStrings.atomicWeight
            : EnAppStrings.atomicWeight;

        return SlideTransition(
          position: _slideAnimation,
          child: InkWell(
            onTap: () {
              // Update widget when element is tapped
              ElementHomeWidgetService.updateWidgetDirectly(element);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ElementDetailView(element: element),
                ),
              );
            },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    elementColor.withValues(alpha: 0.2),
                    elementColor.withValues(alpha: 0.1),
                    AppColors.darkBlue.withValues(alpha: 0.8),
                  ],
                ),
                border: Border.all(
                  color: elementColor.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: elementColor.withValues(alpha: 0.3),
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // Background Pattern
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _patternService.getPatternPainter(
                          type: PatternType.atomic,
                          color: Colors.white,
                          opacity: 0.05,
                        ),
                      ),
                    ),

                    // Decorative Elements
                    Positioned(
                      right: -30,
                      top: -30,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: elementColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    Positioned(
                      left: -20,
                      bottom: -20,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: elementColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    // Main Content
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: elementColor.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: elementColor.withValues(alpha: 0.6),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: elementColor.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.auto_awesome,
                                      color: elementColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      elementOfDayText,
                                      style: TextStyle(
                                        color: elementColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Text(
                                today,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Element Info
                          Expanded(
                            child: Row(
                              children: [
                                // Element Card
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: elementColor.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: elementColor.withValues(
                                        alpha: 0.6,
                                      ),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: elementColor.withValues(
                                          alpha: 0.4,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${element.number}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        element.symbol ?? '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // Element Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        isTr
                                            ? (element.trName ??
                                                  element.enName ??
                                                  'Bilinmeyen Element')
                                            : (element.enName ??
                                                  'Unknown Element'),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _getLocalizedCategory(
                                          element.enCategory,
                                          isTr,
                                        ),
                                        style: TextStyle(
                                          color: elementColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$atomicWeightText: ${element.weight ?? (isTr ? 'Bilinmeyen' : 'Unknown')}',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.7,
                                          ),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Arrow Icon
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: elementColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    color: elementColor,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
