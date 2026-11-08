import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rospatent/core/theme/app_colors.dart';
import 'package:rospatent/core/theme/app_text.dart';
import 'package:rospatent/core/widgets/app_ui.dart';
import 'package:rospatent/core/widgets/hero_header.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            HeroHeader(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: HeroIconButton(
                      icon: Icons.notifications_none_rounded,
                      tooltip: 'Уведомления',
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.document_scanner_outlined,
                      size: 36,
                      color: AppColors.brand,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('Роспатент', style: AppText.onDarkTitle),
                  const SizedBox(height: 6),
                  const Text(
                    'Поиск патентов в базе данных Роспатента',
                    style: AppText.onDarkBody,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppCard(
                    child: Text(
                      'Это приложение помогает вам в поиске патентов в базе данных '
                      'Роспатента, а также сохранять нужные патенты в избранное',
                      style: AppText.body,
                    ),
                  ),
                  const SectionTitle(
                    'Основные возможности',
                    padding: EdgeInsets.fromLTRB(0, 24, 0, 10),
                  ),
                  const AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _FeatureTile(
                          Icons.search_rounded,
                          'Поиск патентов',
                          'Запросы в базу патентов с заданными параметрами',
                        ),
                        Divider(height: 1, indent: 76),
                        _FeatureTile(
                          Icons.star_outline_rounded,
                          'Сохранение в избранное',
                          'Возможность добавлять нужные патенты в раздел избранного',
                        ),
                        Divider(height: 1, indent: 76),
                        _FeatureTile(
                          Icons.description_outlined,
                          'Детальное описание патента',
                          'Полная информация о патенте, включая его статус, правообладателей и т.д.',
                        ),
                        Divider(height: 1, indent: 76),
                        _FeatureTile(
                          Icons.notifications_active_outlined,
                          'Уведомления',
                          'Оповещения об изменениях в избранных патентах',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const AppCard(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: AppColors.brand),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Версия приложения', style: AppText.title),
                              SizedBox(height: 2),
                              Text('1.0.0', style: AppText.caption),
                            ],
                          ),
                        ),
                        Text('© 2025', style: AppText.caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureTile(this.icon, this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.brandSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.brand, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.title),
                const SizedBox(height: 3),
                Text(subtitle, style: AppText.bodySecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
