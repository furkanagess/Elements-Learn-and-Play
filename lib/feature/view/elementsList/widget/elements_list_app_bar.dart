import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/widget/button/back_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// AppBar component for ElementsListView with search functionality
class ElementsListAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final VoidCallback onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onFilterPressed;

  const ElementsListAppBar({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.darkBlue,
              AppColors.steelBlue.withValues(alpha: 0.95),
              AppColors.purple.withValues(alpha: 0.9),
            ],
          ),
        ),
      ),
      leading: const ModernBackButton(),
      title: _buildSearchField(context),
      actions: _buildActionButtons(),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBlue.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: TextField(
          controller: searchController,
          textAlignVertical: TextAlignVertical.center,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 14,
            height: 1,
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: context.read<LocalizationProvider>().isTr
                ? 'Element adı, sembol veya numara ara...'
                : 'Search by element name, symbol or number...',
            hintStyle: TextStyle(
              color: AppColors.white.withValues(alpha: 0.5),
              fontSize: 12,
              height: 1,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                Icons.search,
                color: AppColors.white.withValues(alpha: 0.7),
                size: 20,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: AppColors.white.withValues(alpha: 0.7),
                      size: 18,
                    ),
                    onPressed: onClearSearch,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          onChanged: (_) => onSearchChanged(),
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons() {
    return [
      Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.filter_list, color: AppColors.white),
          onPressed: onFilterPressed,
        ),
      ),
    ];
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
