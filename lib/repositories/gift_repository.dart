// file: repositories/gift_repository.dart
import '../models/gift.dart';
import '../models/user_info.dart';
import '../database/database_helper.dart';

/// 🎯 GiftRepository: 실제 SQLite DB와 통신
class GiftRepository {
  final dbHelper = DatabaseHelper.instance;

  GiftRepository();

  /// 🔹 모든 UserInfo 가져오기
  Future<Map<String, UserInfo>> fetchUsers() async {
    // DB 쿼리
    final db = await dbHelper.database;
    final result = await db.query('UserInfo');

    // Map<id, UserInfo> 형태로 변환
    return {for (var map in result) map['name'] as String: UserInfo.fromMap(map)};
  }

  /// 🔹 모든 Gift 가져오기
  Future<List<Gift>> fetchGifts() async {
    return await dbHelper.getAllGifts();
  }

  /// 🔹 Gift 추가
  Future<void> addGift(Gift gift) async {
    await dbHelper.insertGift(gift);
  }

  /// 🔹 Gift 수정
  Future<void> updateGift(Gift gift) async {
    await dbHelper.updateGift(gift);
  }

  /// 🔹 Gift 삭제
  Future<void> deleteGift(String id) async {
    await dbHelper.deleteGift(id);
  }



  // -------------------------------------------------------------------
  // 🔹 [FRIENDS_SCREEN] 유저별 주고받은 금액 합계 계산
  // -------------------------------------------------------------------
  /// ✅ 모든 유저의 총 준 금액(totalGiven) / 받은 금액(totalReceived)을 계산
  ///
  /// Gift.giftType 기준:
  /// - 0: 준 금액
  /// - 1: 받은 금액
  ///
  /// 결과 예시:
  /// [
  ///   {"name": "홍길동", "totalGiven": 150000, "totalReceived": 70000},
  ///   {"name": "이순신", "totalGiven": 50000, "totalReceived": 120000},
  /// ]
  Future<List<Map<String, dynamic>>> fetchUserSummary() async {
    final db = await dbHelper.database;

    final result = await db.rawQuery('''
      SELECT 
        partnerName AS name,
        SUM(CASE WHEN giftType = 0 THEN CAST(amount AS INTEGER) ELSE 0 END) AS totalGiven,
        SUM(CASE WHEN giftType = 1 THEN CAST(amount AS INTEGER) ELSE 0 END) AS totalReceived
      FROM Gift
      GROUP BY partnerName
      ORDER BY partnerName ASC
    ''');

    print("- fetchUserSummary : $result");

    return result;
  }

  /// ✅ 특정 이름(keyword)으로 검색
  ///
  /// keyword가 "길동"이면 이름에 "길동"이 포함된 유저만 반환
  Future<List<Map<String, dynamic>>> searchUserSummary(String keyword) async {
    final db = await dbHelper.database;

    final result = await db.rawQuery('''
      SELECT 
        partnerName AS name,
        SUM(CASE WHEN giftType = 0 THEN CAST(amount AS INTEGER) ELSE 0 END) AS totalGiven,
        SUM(CASE WHEN giftType = 1 THEN CAST(amount AS INTEGER) ELSE 0 END) AS totalReceived
      FROM Gift
      WHERE partnerName LIKE ?
      GROUP BY partnerName
      ORDER BY partnerName ASC
    ''', ['%$keyword%']);

    print("- searchUserSummary : $result");

    return result;
  }
}
