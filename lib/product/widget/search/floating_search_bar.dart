import 'package:flutter/material.dart';
import 'package:elements_app/product/constants/app_colors.dart';

class FloatingSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onSearchChanged;
  final VoidCallback? onClear;
  final String hintText;
  final bool isExpanded;
  final VoidCallback? onTap;

  const FloatingSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSearchChanged,
    this.onClear,
    this.hintText = 'Element ara...',
    this.isExpanded = false,
    this.onTap,
  });

  @override
  State<FloatingSearchBar> createState() => _FloatingSearchBarState();
}

class _FloatingSearchBarState extends State<FloatingSearchBar>
    with TickerProviderStateMixin {
  bool _isFocused = false;
  bool _hasText = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _widthAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _widthAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    widget.focusNode.addListener(_onFocusChanged);
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.focusNode.removeListener(_onFocusChanged);
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
    });

    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _onTextChanged() {
    setState(() {
      _hasText = widget.controller.text.isNotEmpty;
    });
    widget.onSearchChanged(widget.controller.text);
  }

  void _clearSearch() {
    widget.controller.clear();
    widget.focusNode.unfocus();
    if (widget.onClear != null) {
      widget.onClear!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width:
                MediaQuery.of(context).size.width *
                0.85 *
                _widthAnimation.value,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: _isFocused
                    ? AppColors.turquoise
                    : AppColors.darkBlue.withValues(alpha: 0.1),
                width: _isFocused ? 2.5 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isFocused
                      ? AppColors.turquoise.withValues(alpha: 0.3)
                      : AppColors.darkBlue.withValues(alpha: 0.2),
                  offset: const Offset(0, 8),
                  blurRadius: _isFocused ? 25 : 20,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: AppColors.white.withValues(alpha: 0.9),
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                // Search Icon Container
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _isFocused
                        ? AppColors.turquoise.withValues(alpha: 0.15)
                        : AppColors.darkBlue.withValues(alpha: 0.05),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      bottomLeft: Radius.circular(28),
                    ),
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    color: _isFocused
                        ? AppColors.turquoise
                        : AppColors.darkBlue.withValues(alpha: 0.7),
                    size: 26,
                  ),
                ),

                // Text Field
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: widget.controller,
                      focusNode: widget.focusNode,
                      style: TextStyle(
                        color: AppColors.darkBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: 0.3,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: TextStyle(
                          color: AppColors.darkBlue.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          letterSpacing: 0.2,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 18,
                        ),
                      ),
                    ),
                  ),
                ),

                // Clear Button
                if (_hasText)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.powderRed.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(28),
                          bottomRight: Radius.circular(28),
                        ),
                        onTap: _clearSearch,
                        child: Icon(
                          Icons.close_rounded,
                          color: AppColors.powderRed,
                          size: 22,
                        ),
                      ),
                    ),
                  ),

                // Filter Button (when not searching)
                if (!_hasText)
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.glowGreen.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(28),
                          bottomRight: Radius.circular(28),
                        ),
                        onTap: () {
                          // Filter functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Filtreleme özelliği yakında!',
                              ),
                              backgroundColor: AppColors.glowGreen,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.tune_rounded,
                          color: AppColors.glowGreen,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
