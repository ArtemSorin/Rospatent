import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Типографическая шкала приложения.
class AppText {
  AppText._();

  static const h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.4,
    color: AppColors.ink,
  );

  static const h2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.3,
    color: AppColors.ink,
  );

  static const h3 = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: AppColors.ink,
  );

  static const title = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.ink,
  );

  static const body = TextStyle(
    fontSize: 15,
    height: 1.4,
    color: AppColors.ink,
  );

  static const bodySecondary = TextStyle(
    fontSize: 14,
    height: 1.4,
    color: AppColors.inkSecondary,
  );

  static const caption = TextStyle(
    fontSize: 12.5,
    height: 1.3,
    color: AppColors.inkSecondary,
  );

  static const onDarkTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.4,
    color: Colors.white,
  );

  static const onDarkBody = TextStyle(
    fontSize: 15,
    height: 1.35,
    color: Color(0xCCFFFFFF),
  );
}
