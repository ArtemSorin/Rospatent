import 'package:flutter/material.dart';
import 'package:rospatent/core/theme/app_text.dart';
import 'package:rospatent/core/widgets/app_ui.dart';

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
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Уточнить поиск', style: AppText.h3),
          const SizedBox(height: 14),
          const TextField(
            decoration: InputDecoration(
              hintText: 'Номер заявки',
              prefixIcon: Icon(Icons.confirmation_number_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: authorsController,
            decoration: const InputDecoration(
              hintText: 'Авторы (ФИО через запятую)',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: patenteeController,
            decoration: const InputDecoration(
              hintText: 'Патентообладатели (ФИО через запятую)',
              prefixIcon: Icon(Icons.business_outlined),
            ),
          ),
        ],
      ),
    );
  }
}
