// lib/models/user_info.dart
// 👤 사용자 정보 모델
// - users 테이블과 1:1 매핑
// - UserInfo.id는 Gift.partnerId와 매칭되는 값이어야 함

class UserInfo {
  final String name; // (*고유 ID) 사용자(상대)의 표시 이름

  UserInfo({required this.name});

  /// DB Row(Map)을 UserInfo 객체로 변환
  factory UserInfo.fromMap(Map<String, dynamic> map) {
    return UserInfo(
      name: map['name'] as String,
    );
  }

  /// UserInfo 객체를 DB에 넣을 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}
