import 'package:flutter/foundation.dart';
import '../repositories/gift_repository.dart';

/// 🎯 FriendSummary
/// 한 유저의 요약 정보 (이름, 준 금액, 받은 금액)
class FriendSummary {
  final String name;
  final int totalSent;
  final int totalReceived;

  FriendSummary({
    required this.name,
    required this.totalSent,
    required this.totalReceived,
  });

  factory FriendSummary.fromMap(Map<String, dynamic> map) {
    return FriendSummary(
      name: map['name'] ?? '',
      totalSent: map['totalGiven'] != null
          ? int.tryParse(map['totalGiven'].toString()) ?? 0
          : 0,
      totalReceived: map['totalReceived'] != null
          ? int.tryParse(map['totalReceived'].toString()) ?? 0
          : 0,
    );
  }
}

/// 🎯 FriendsViewModel
/// - 전체 유저별 금액 요약 정보 관리
/// - 검색 기능
class FriendsViewModel extends ChangeNotifier {
  final GiftRepository repository;
  bool isLoading = false;
  List<FriendSummary> allFriends = [];
  List<FriendSummary> filteredFriends = [];

  FriendsViewModel({required this.repository});

  /// ✅ 전체 유저 불러오기
  Future<void> loadFriends() async {
    isLoading = true;
    notifyListeners();

    final data = await repository.fetchUserSummary();
    allFriends = data.map((e) => FriendSummary.fromMap(e)).toList();
    filteredFriends = allFriends;

    for (int i = 0; i < allFriends.length; i++) {
      print("---------------------------------------------------------------------");
      print(allFriends[i].name);
      print(allFriends[i].totalSent);
      print(allFriends[i].totalReceived);
      print("---------------------------------------------------------------------");
    }


    isLoading = false;
    notifyListeners();
  }

  /// ✅ 이름으로 검색
  Future<void> searchFriends(String keyword) async {
    if (keyword.isEmpty) {
      filteredFriends = allFriends;
    } else {
      final data = await repository.searchUserSummary(keyword);
      filteredFriends = data.map((e) => FriendSummary.fromMap(e)).toList();
    }
    notifyListeners();
  }
}
