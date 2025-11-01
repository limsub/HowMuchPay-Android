// lib/utils/date_utils.dart

/// 🔹 날짜를 영어 서수형으로 변환
String formatDayToEnglish(String date) {
  int day = int.parse(date.substring(6, 8));

  if (day >= 11 && day <= 13) {
    return '${day}th';
  }

  switch (day % 10) {
    case 1:
      return '${day}st';
    case 2:
      return '${day}nd';
    case 3:
      return '${day}rd';
    default:
      return '${day}th';
  }
}
