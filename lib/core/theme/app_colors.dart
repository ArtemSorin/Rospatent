import 'package:flutter/material.dart';

/// Палитра в духе государственных мобильных приложений:
/// насыщенный «госсиний», холодный серо-голубой фон и тёмно-синий текст вместо чёрного.
class AppColors {
  AppColors._();

  // Фирменный синий
  static const brand = Color(0xFF0D4CD3);
  static const brandBright = Color(0xFF1B63F0);
  static const brandDark = Color(0xFF0A36A0);
  static const brandMid = Color(0xFF6B9BFF);
  static const brandSoft = Color(0xFFE8EEFC);
  static const brandSofter = Color(0xFFDCE7FF);

  // Текст
  static const ink = Color(0xFF0B1F35);
  static const inkSecondary = Color(0xFF5B6B80);
  static const inkTertiary = Color(0xFF8A97AB);

  // Поверхности
  static const bg = Color(0xFFF2F5FA);
  static const surface = Colors.white;
  static const line = Color(0xFFE3E8F0);

  // Декор на синем фоне (круги и скруглённые квадраты в шапках)
  static const heroShapeDark = Color(0x40061A45);
  static const heroShapeLight = Color(0x2EFFFFFF);
  static const onHeroGlass = Color(0x26FFFFFF);

  // Статусы
  static const danger = Color(0xFFE5484D);
  static const dangerSoft = Color(0xFFFDECEC);
  static const amber = Color(0xFFF5A623);
  static const amberSoft = Color(0xFFFFF3DC);
}
