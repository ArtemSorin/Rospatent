import 'package:flutter/material.dart';

class SearchInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onSubmitted;

  const SearchInput({super.key, required this.controller, this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => onSubmitted?.call(),
      decoration: const InputDecoration(
        hintText: "Поиск по тексту",
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}
