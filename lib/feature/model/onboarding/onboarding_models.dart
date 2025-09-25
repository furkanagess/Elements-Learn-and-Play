import 'package:flutter/material.dart';
import 'package:elements_app/product/constants/app_colors.dart';

class OnboardingPage {
  final String title;
  final String titleTr;
  final String description;
  final String descriptionTr;
  final String imagePath;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData icon;

  const OnboardingPage({
    required this.title,
    required this.titleTr,
    required this.description,
    required this.descriptionTr,
    required this.imagePath,
    required this.primaryColor,
    required this.secondaryColor,
    required this.icon,
  });
}

class OnboardingData {
  static const List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'Welcome to Elements',
      titleTr: 'Elements\'e Hoş Geldin',
      description:
          'Discover the fascinating world of chemistry through interactive games and puzzles',
      descriptionTr:
          'Etkileşimli oyunlar ve bulmacalar aracılığıyla kimyanın büyüleyici dünyasını keşfet',
      imagePath: 'assets/img/onboarding_1.png',
      primaryColor: AppColors.turquoise,
      secondaryColor: AppColors.shTurquoise,
      icon: Icons.science,
    ),
    OnboardingPage(
      title: 'Learn Through Games',
      titleTr: 'Oyunlarla Öğren',
      description:
          'Master the periodic table with fun quizzes, puzzles, and trivia challenges',
      descriptionTr:
          'Eğlenceli quizler, bulmacalar ve trivia yarışmaları ile periyodik tabloyu öğren',
      imagePath: 'assets/img/onboarding_2.png',
      primaryColor: AppColors.glowGreen,
      secondaryColor: AppColors.shGlowGreen,
      icon: Icons.videogame_asset,
    ),
    OnboardingPage(
      title: 'Track Your Progress',
      titleTr: 'İlerlemeni Takip Et',
      description:
          'Monitor your learning journey with detailed statistics and achievements',
      descriptionTr:
          'Detaylı istatistikler ve başarımlarla öğrenme yolculuğunu takip et',
      imagePath: 'assets/img/onboarding_3.png',
      primaryColor: AppColors.yellow,
      secondaryColor: AppColors.shYellow,
      icon: Icons.analytics,
    ),
    OnboardingPage(
      title: 'Go Premium',
      titleTr: 'Premium\'a Geç',
      description:
          'Unlock all features, remove ads, and get unlimited access to everything',
      descriptionTr:
          'Tüm özelliklerin kilidini aç, reklamları kaldır ve her şeye sınırsız erişim sağla',
      imagePath: 'assets/img/onboarding_4.png',
      primaryColor: AppColors.purple,
      secondaryColor: AppColors.shPurple,
      icon: Icons.star,
    ),
  ];
}
