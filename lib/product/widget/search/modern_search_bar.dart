import 'package:flutter/material.dart';
import 'package:elements_app/product/constants/app_colors.dart';

class ModernSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onSearchChanged;
  final VoidCallback? onClear;
  final String hintText;
  final bool showSuggestions;
  final List<String>? suggestions;
  final Function(String)? onSuggestionSelected;

  const ModernSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSearchChanged,
    this.onClear,
    this.hintText = 'Element ara...',
    this.showSuggestions = false,
    this.suggestions,
    this.onSuggestionSelected,
  });

  @override
  State<ModernSearchBar> createState() => _ModernSearchBarState();
}

class _ModernSearchBarState extends State<ModernSearchBar>
    with TickerProviderStateMixin {
  bool _isFocused = false;
  bool _hasText = false;
  late AnimationController _animationController;
  late AnimationController _suggestionController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _suggestionController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _suggestionController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _suggestionController,
            curve: Curves.easeOutCubic,
          ),
        );

    widget.focusNode.addListener(_onFocusChanged);
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _suggestionController.dispose();
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
      if (widget.showSuggestions && widget.suggestions != null) {
        _suggestionController.forward();
      }
    } else {
      _animationController.reverse();
      _suggestionController.reverse();
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
    return Column(
      children: [
        // Main Search Bar
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(30),
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
                          : AppColors.darkBlue.withValues(alpha: 0.15),
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
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _isFocused
                            ? AppColors.turquoise.withValues(alpha: 0.15)
                            : AppColors.darkBlue.withValues(alpha: 0.05),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          bottomLeft: Radius.circular(30),
                        ),
                      ),
                      child: Icon(
                        Icons.search_rounded,
                        color: _isFocused
                            ? AppColors.turquoise
                            : AppColors.darkBlue.withValues(alpha: 0.7),
                        size: 28,
                      ),
                    ),

                    // Text Field
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
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
                              vertical: 20,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Clear Button
                    if (_hasText)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.powderRed.withValues(alpha: 0.1),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                            onTap: _clearSearch,
                            child: Icon(
                              Icons.close_rounded,
                              color: AppColors.powderRed,
                              size: 24,
                            ),
                          ),
                        ),
                      ),

                    // Voice Search Button (Optional)
                    if (!_hasText)
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.glowGreen.withValues(alpha: 0.1),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                            onTap: () {
                              // Voice search functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Sesli arama yakında!'),
                                  backgroundColor: AppColors.turquoise,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                            child: Icon(
                              Icons.mic_rounded,
                              color: AppColors.glowGreen,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),

        // Search Suggestions
        if (widget.showSuggestions && widget.suggestions != null && _isFocused)
          AnimatedBuilder(
            animation: _suggestionController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value.dy * 50),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.turquoise.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkBlue.withValues(alpha: 0.1),
                          offset: const Offset(0, 8),
                          blurRadius: 20,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Suggestions Header
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.turquoise.withValues(alpha: 0.05),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline_rounded,
                                color: AppColors.turquoise,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Öneriler',
                                style: TextStyle(
                                  color: AppColors.turquoise,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Suggestions List
                        ...widget.suggestions!.take(5).map((suggestion) {
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                widget.controller.text = suggestion;
                                if (widget.onSuggestionSelected != null) {
                                  widget.onSuggestionSelected!(suggestion);
                                }
                                widget.focusNode.unfocus();
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.search_rounded,
                                      color: AppColors.darkBlue.withValues(
                                        alpha: 0.5,
                                      ),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        suggestion,
                                        style: TextStyle(
                                          color: AppColors.darkBlue,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
