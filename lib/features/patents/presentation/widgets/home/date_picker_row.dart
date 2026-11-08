import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rospatent/core/theme/app_colors.dart';
import 'package:rospatent/core/theme/app_text.dart';
import 'package:rospatent/core/widgets/app_ui.dart';

class DatePickerRow extends StatelessWidget {
  final DateTime? from;
  final DateTime? to;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;
  final VoidCallback onClearFrom;
  final VoidCallback onClearTo;

  const DatePickerRow({
    super.key,
    required this.from,
    required this.to,
    required this.onPickFrom,
    required this.onPickTo,
    required this.onClearFrom,
    required this.onClearTo,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Дата публикации', style: AppText.h3),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _DateField(
                  label: 'Публикация от',
                  date: from,
                  onTap: onPickFrom,
                  onClear: onClearFrom,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateField(
                  label: 'Публикация до',
                  date: to,
                  onTap: onPickTo,
                  onClear: onClearTo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final selected = date;
    return Material(
      color: AppColors.bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppText.caption, maxLines: 1),
                    const SizedBox(height: 3),
                    Text(
                      selected == null
                          ? 'Не выбрана'
                          : DateFormat('dd.MM.yyyy').format(selected),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: selected == null
                            ? AppColors.inkTertiary
                            : AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected == null)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: AppColors.inkTertiary,
                  ),
                )
              else
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: AppColors.inkSecondary,
                  tooltip: 'Сбросить',
                  onPressed: onClear,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
