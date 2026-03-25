import 'package:flutter/material.dart';

import 'patent_card.dart';

import '../../data/patent_api.dart';

class PatentsList extends StatelessWidget {
  final List<Patent> patents;
  final void Function(Patent) onPatentTap;

  const PatentsList({
    super.key,
    required this.patents,
    required this.onPatentTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: patents.length,
      itemBuilder: (context, index) {
        final patent = patents[index];
        return PatentCard(patent: patent, onTap: () => onPatentTap(patent));
      },
    );
  }
}
