import 'package:flutter/material.dart';
import 'package:rospatent/core/theme/app_colors.dart';

/// Поле поиска для синей шапки: белое, крупное, с кнопкой «найти» внутри.
class SearchInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onSubmitted;

  const SearchInput({super.key, required this.controller, this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => onSubmitted?.call(),
      style: const TextStyle(fontSize: 16, color: AppColors.ink),
      decoration: InputDecoration(
        hintText: 'Поиск по тексту патентов',
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.search_rounded, size: 24),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        suffixIconConstraints: const BoxConstraints(minWidth: 52, minHeight: 48),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Material(
            color: AppColors.brand,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onSubmitted,
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 22,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: Color(0xFF9DBBFF), width: 2),
        ),
      ),
    );
  }
}
