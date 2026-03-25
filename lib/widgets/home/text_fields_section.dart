import 'package:flutter/material.dart';

class TextFieldsSection extends StatelessWidget {
  final TextEditingController patenteeController;
  final TextEditingController authorsController;

  const TextFieldsSection({
    super.key,
    required this.patenteeController,
    required this.authorsController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            hintText: "Номер заявки",
            prefixIcon: Icon(Icons.confirmation_number_outlined),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: authorsController,
          decoration: const InputDecoration(
            hintText: "Авторы (ФИО через запятую)",
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: patenteeController,
          decoration: const InputDecoration(
            hintText: "Патентообладатели (ФИО через запятую)",
            prefixIcon: Icon(Icons.business_outlined),
          ),
        ),
      ],
    );
  }
}
