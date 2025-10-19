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
          color: AppColors.darkBlue, // darkBlue background
          border: Border(
            bottom: BorderSide(
              color: AppColors.darkBlue, // Opacity white border
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
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
        color: Colors.white.withValues(
          alpha: 0.15,
        ), // Opacity white background for search field
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3), // Opacity white border
          width: 1,
        ),
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
            hintStyle: const TextStyle(
              color: Color(0xFFB0B0B0), // Light gray hint text
              fontSize: 12,
              height: 1,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                Icons.search,
                color: const Color(0xFFB0B0B0), // Light gray icon
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
                      color: const Color(0xFFB0B0B0), // Light gray icon
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
          color: Colors.white.withValues(
            alpha: 0.15,
          ), // Opacity white background like search field
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3), // Opacity white border
            width: 1,
          ),
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
