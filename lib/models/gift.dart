// lib/models/gift.dart
// 🎯 Gift(선물/축의금/조의금) 모델 정의
// - DB(예: SQLite)의 gifts 테이블과 1:1 매핑되도록 설계
// - id는 외부에서 생성(예: yyyyMMddHHmmss 형식)하도록 가정

/// 선물(축의금/조의금) 타입을 나타내는 enum
/// DB에는 정수로 저장됨 (giftType.rawValue)
enum GiftType {
  given,    // 0: 전한 마음 (내가 준 경우)
  received, // 1: 받은 마음 (내가 받은 경우)
}

/// 이벤트 타입(결혼식, 돌잔치 등)을 나타내는 enum
/// DB에는 정수로 저장됨 (eventType.rawValue)
enum EventType {
  wedding,     // 0: 결혼식
  firstBirth,  // 1: 돌잔치
  funeral,     // 2: 장례식
  other,       // 3: 기타
}

extension EventTypeExtension on EventType {
  String get koreanName {
    switch (this) {
      case EventType.wedding: return '결혼식';
      case EventType.firstBirth: return '돌잔치';
      case EventType.funeral: return '장례식';
      case EventType.other: return '기타';
    }
  }
}



/// 🎁 선물(축의금/조의금) 데이터 모델
/// - 이 클래스는 DB 레코드(행) 하나와 대응됩니다.
/// - toMap(), fromMap()은 sqflite (Map<String,dynamic>)와의 변환에 사용됩니다.
class Gift {
  final String id;        // PK 역할: 보통 'yyyyMMddHHmmss' 같은 고유 문자열 (외부에서 생성)
  final String partnerName; // 상대 유저의 id (UserInfo.id). DB에서는 외래키(fk) 역할
  final int giftType;     // GiftType의 정수값 (0: given, 1: received)
  final int amount;       // 금액 (원 단위, 정수)
  final int eventType;    // EventType의 정수값 (0..3)
  final String date;      // 거래 날짜. 'yyyyMMdd' 형식(검색 및 정렬 시 사용)
  final String memo;      // 추가 메모(옵션)

  Gift({
    required this.id,
    required this.partnerName,
    required this.giftType,
    required this.amount,
    required this.eventType,
    required this.date,
    required this.memo,
  });

  /// ✅ DB에서 읽은 Map<String, dynamic>을 Gift 객체로 변환
  /// - sqflite은 레코드를 Map으로 반환하므로 이 변환이 필요
  /// - 타입이 일치하지 않으면 예외가 발생할 수 있으니, DB 스키마와 항상 동기화할 것
  factory Gift.fromMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'] as String,
      partnerName: map['partnerName'] as String,
      giftType: map['giftType'] as int,
      amount: map['amount'] as int,
      eventType: map['eventType'] as int,
      date: map['date'] as String,
      memo: map['memo'] as String,
    );
  }

  /// ✅ Gift 객체를 DB에 넣을 Map 형태로 변환
  /// - insert/update 시에 이 Map을 그대로 사용
  /// - 컬럼명은 DB 테이블 생성 시 사용한 이름과 일치해야 함
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'partnerName': partnerName,
      'giftType': giftType,
      'amount': amount,
      'eventType': eventType,
      'date': date,
      'memo': memo,
    };
  }

  /// 편의 함수: enum 타입을 받아서 Gift 생성 시 사용 가능
  /// - 예: Gift.fromDomain(id, userId, GiftType.given, ...)
  static Gift fromDomain({
    required String id,
    required String partnerName,
    required GiftType giftType,
    required int amount,
    required EventType eventType,
    required String date,
    required String memo,
  }) {
    return Gift(
      id: id,
      partnerName: partnerName,
      giftType: giftType.index,   // enum -> int
      amount: amount,
      eventType: eventType.index, // enum -> int
      date: date,
      memo: memo,
    );
  }

  /// 편의 함수: Gift 객체에서 enum 타입 반환
  GiftType get giftTypeEnum => GiftType.values[giftType];
  EventType get eventTypeEnum => EventType.values[eventType];
}