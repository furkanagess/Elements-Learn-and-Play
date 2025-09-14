import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Filter modal component for sorting elements
class FilterModal extends StatelessWidget {
  final Function(String) onSortSelected;

  const FilterModal({super.key, required this.onSortSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            context.read<LocalizationProvider>().isTr
                ? 'Sıralama Seçenekleri'
                : 'Sort Options',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Filter Options
          _buildFilterOption(
            context,
            icon: Icons.format_list_numbered,
            title: context.read<LocalizationProvider>().isTr
                ? 'Atom Numarasına Göre'
                : 'By Atomic Number',
            onTap: () {
              onSortSelected('number');
              Navigator.pop(context);
            },
          ),
          _buildFilterOption(
            context,
            icon: Icons.sort_by_alpha,
            title: context.read<LocalizationProvider>().isTr
                ? 'İsme Göre'
                : 'By Name',
            onTap: () {
              onSortSelected('name');
              Navigator.pop(context);
            },
          ),
          _buildFilterOption(
            context,
            icon: Icons.scale,
            title: context.read<LocalizationProvider>().isTr
                ? 'Atom Ağırlığına Göre'
                : 'By Atomic Weight',
            onTap: () {
              onSortSelected('weight');
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFilterOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
