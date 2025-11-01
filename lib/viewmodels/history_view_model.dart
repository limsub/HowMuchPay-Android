// file: viewmodels/history_view_model.dart
import 'package:flutter/material.dart';
import '../models/gift.dart';
import '../models/user_info.dart';
import '../repositories/gift_repository.dart';

/// 🎯 HistoryViewModel: 화면에서 보여줄 데이터와 상태 관리
class HistoryViewModel extends ChangeNotifier {
  final GiftRepository repository;

  HistoryViewModel({required this.repository});

  Map<String, UserInfo> users = {};    // 파트너 정보
  List<Gift> gifts = [];               // 전체 Gift 리스트
  int totalGiven = 0;                  // 총 전한 마음 금액
  int totalReceived = 0;               // 총 받은 마음 금액
  bool isLoading = false;              // 로딩 상태

  /// 🔹 DB에서 데이터 가져오기
  Future<void> loadData() async {
    print('ViewModel hashCode: ${this.hashCode}');


    isLoading = true;
    notifyListeners();                  // UI 갱신

    users = await repository.fetchUsers();
    gifts = await repository.fetchGifts();

    totalGiven = gifts
        .where((g) => g.giftTypeEnum == GiftType.given)
        .fold(0, (prev, g) => prev + g.amount);

    totalReceived = gifts
        .where((g) => g.giftTypeEnum == GiftType.received)
        .fold(0, (prev, g) => prev + g.amount);

    isLoading = false;
    print('totalGiven : ${totalGiven} totalReceived : ${totalReceived}');
    notifyListeners();
  }

  /// 🔹 Gift를 월별로 그룹핑 (최신 데이터가 위)
  Map<String, List<Gift>> groupByMonth() {
    // 1️⃣ 날짜 기준 내림차순 정렬
    gifts.sort((a, b) => b.date.compareTo(a.date));

    // 2️⃣ 월별로 그룹핑
    Map<String, List<Gift>> map = {};
    for (var gift in gifts) {
      String month = gift.date.substring(0, 6); // yyyyMM
      if (!map.containsKey(month)) map[month] = [];
      map[month]!.add(gift);
    }

    // 3️⃣ 월 키도 내림차순 정렬
    final sortedMap = Map<String, List<Gift>>.fromEntries(
      map.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
    );

    return sortedMap;
  }


  /// 🔹 Gift 추가 후 UI 갱신
  Future<void> addGift(Gift gift) async {
    await repository.addGift(gift);
    await loadData();
  }

  /// 🔹 Gift 수정 후 UI 갱신
  Future<void> updateGift(Gift gift) async {
    await repository.updateGift(gift);
    await loadData();
  }

  /// 🔹 Gift 삭제 후 UI 갱신
  Future<void> deleteGift(String id) async {
    await repository.deleteGift(id);
    await loadData();
  }
}
