import 'package:flutter/material.dart';
import 'app_colors.dart'; // 색상은 나중에 AppColors로 관리

/// 앱 전체에서 공통으로 사용하는 텍스트 스타일 모음
class AppTextStyles {
  // MoneygraphyRounded 폰트 (특별한 제목용)
  static const String moneygraphy = 'MoneygraphyRounded';
  // Pretendard 폰트 (기본 본문용)
  static const String pretendard = 'Pretendard';

  static const TextStyle mg24Black = TextStyle(
    fontFamily: moneygraphy,
    fontSize: 24,
    color: Colors.black
  );

  static const TextStyle mg24White = TextStyle(
      fontFamily: moneygraphy,
      fontSize: 36,
      color: Colors.white,
      height: 1.0, // 행간을 글자 크기 기준 1배로 줄임
  );

  static const TextStyle body18mBlack = TextStyle(
      fontFamily: pretendard,
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Colors.black
  );

  static const TextStyle body17bBlack = TextStyle(
      fontFamily: pretendard,
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: Colors.black
  );

  static const TextStyle body17mBlack = TextStyle(
      fontFamily: pretendard,
      fontSize: 17,
      fontWeight: FontWeight.w500,
      color: Colors.black
  );

  static const TextStyle body16bBlack = TextStyle(
    fontFamily: pretendard,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black
  );

  static const TextStyle body16mBlack = TextStyle(
      fontFamily: pretendard,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.black
  );

  static const TextStyle body14mBlack = TextStyle(
    fontFamily: pretendard,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black
  );

  static const TextStyle body14b = TextStyle(
      fontFamily: pretendard,
      fontSize: 14,
      fontWeight: FontWeight.bold
  );

  static const TextStyle body16m = TextStyle(
      fontFamily: pretendard,
      fontSize: 16,
      fontWeight: FontWeight.w500
  );

  static const TextStyle body14m = TextStyle(
      fontFamily: pretendard,
      fontSize: 14,
      fontWeight: FontWeight.w500
  );

  static const TextStyle title20b = TextStyle(
    fontFamily: pretendard,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  // -------------------
  // 제목용 큰 글씨
  // -------------------
  static const TextStyle title = TextStyle(
    fontFamily: moneygraphy, // MoneygraphyRounded 사용
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.grey08,
  );

  // -------------------
  // 본문 기본 글씨
  // -------------------
  static const TextStyle bodyRegular = TextStyle(
    fontFamily: pretendard, // Pretendard 사용
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.grey07,
  );

  static const TextStyle bodyBold = TextStyle(
    fontFamily: pretendard,
    fontSize: 16,
    fontWeight: FontWeight.w700, // Bold
    color: AppColors.grey08,
  );

  static const TextStyle bodyThin = TextStyle(
    fontFamily: pretendard,
    fontSize: 16,
    fontWeight: FontWeight.w100, // Thin
    color: AppColors.grey06,
  );

  // -------------------
  // 작은 글씨 / 서브 텍스트
  // -------------------
  static const TextStyle small = TextStyle(
    fontFamily: pretendard,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.grey05,
  );
}

