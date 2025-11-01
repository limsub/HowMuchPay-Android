import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/user_info.dart';
import '../models/gift.dart';

/// 🎯 MakeGift 화면의 상태를 관리하는 ViewModel
/// - 새 Gift 추가 / 기존 Gift 수정 둘 다 지원
/// - 입력 필드 제어
/// - 날짜 및 이벤트 타입 관리
/// - 검증 및 DB 저장 처리
class MakeGiftViewModel extends ChangeNotifier {
  // -----------------------------
  // 🔹 Controllers
  // -----------------------------
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController memoController = TextEditingController();

  // -----------------------------
  // 🔹 Computed (UI Binding)
  // -----------------------------
  bool get nameHasText => nameController.text.isNotEmpty;
  bool get amountHasText => amountController.text.isNotEmpty;
  bool get memoHasText => memoController.text.isNotEmpty;

  // -----------------------------
  // 🔹 State
  // -----------------------------
  bool isSent = true; // 선택된 유형
  int eventType = 0;  // 경조사 종류 (0: 결혼식, 1: 돌잔치, 2: 장례식, 3: 기타)
  DateTime selectedDate = DateTime.now(); // 날짜
  Gift? existingGift; // ✅ 수정 모드 시 기존 Gift 저장

  // -----------------------------
  // 🔹 Constructor
  // -----------------------------
  MakeGiftViewModel({this.existingGift}) {
    // ✅ 기존 gift가 있다면 초기값 설정
    if (existingGift != null) {
      _loadExistingGift(existingGift!);
    }

    // 입력 변경 시 UI 자동 갱신
    nameController.addListener(_onTextChanged);
    amountController.addListener(_onTextChanged);
    memoController.addListener(_onTextChanged);
  }

  void _loadExistingGift(Gift gift) {
    nameController.text = gift.partnerName;
    amountController.text = NumberFormat('#,###').format(gift.amount);
    memoController.text = gift.memo;
    isSent = gift.giftType == 0; // 0: 전한, 1: 받은
    eventType = gift.eventType;
    print("---------${gift.date}");
    // selectedDate = DateFormat('yyyyMMdd').parse(gift.date);
    // gift.date = "20250412"
    selectedDate = DateTime(
      int.parse(gift.date.substring(0, 4)), // 연도
      int.parse(gift.date.substring(4, 6)), // 월
      int.parse(gift.date.substring(6, 8)), // 일
    );

  }


  void _onTextChanged() => notifyListeners();

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    memoController.dispose();
    super.dispose();
  }

  // -----------------------------
  // 🔹 금액 입력 포맷팅
  // -----------------------------
  void onAmountChanged(String v) {
    final onlyDigits = v.replaceAll(RegExp(r'[^0-9]'), '');
    if (onlyDigits.isEmpty) {
      amountController.value = TextEditingValue(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
      return;
    }
    final formatted = NumberFormat('#,###').format(int.parse(onlyDigits));
    amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  // -----------------------------
  // 🔹 선택 상태 변경
  // -----------------------------
  // - 유형 변경
  void toggleIsSent(bool value) {
    isSent = value;
    notifyListeners();
  }

  // - 경조사 종류 선택
  void setEventType(int index) {
    eventType = index;
    notifyListeners();
  }

  // - 날짜 선택
  void setDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  // -----------------------------
  // 🔹 유효성 검증
  // -----------------------------
  String? validate() {
    // 이름 입력 확인
    if (nameController.text.trim().isEmpty) {
      return '이름을 입력해주세요.';
    }

    // 금액 입력 확인 (숫자 0 이상)
    final amountText = amountController.text.replaceAll(',', '');
    final amount = int.tryParse(amountText) ?? -1;
    if (amount <= 0) {
      return '금액을 0원 이상 입력해주세요.';
    }

    // 경조사 종류 선택 확인 (0~3)
    if (eventType < 0 || eventType > 3) {
      return '경조사 종류를 선택해주세요.';
    }

    // 유형 선택은 항상 값이 있으므로 체크하지 않음
    return null; // 모든 조건 통과
  }

  // ✅ 모든 필드가 유효할 때 저장 버튼 활성화
  bool get canSave => validate() == null;

  // -----------------------------
  // 🔹 저장 처리
  // -----------------------------
  Future<void> save() async {
    debugPrint('저장: name=${nameController.text}, '
        'type=${isSent ? "전한" : "받은"}, '
        'event=$eventType, '
        'amount=${amountController.text}, '
        'date=${DateFormat('yyyyMMdd').format(selectedDate)}, '
        'memo=${memoController.text}');

    final gift = Gift(
      id: existingGift?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      partnerName: nameController.text.trim(),
      giftType: isSent ? 0 : 1,
      amount: int.parse(amountController.text.replaceAll(',', '')),
      eventType: eventType,
      date: DateFormat('yyyyMMdd').format(selectedDate),
      memo: memoController.text.trim(),
    );

    if (existingGift == null) {
      // 신규 추가
      await DatabaseHelper.instance.insertGiftWithUserCheck(gift);
      debugPrint('✅ Gift 저장 완료: ${gift.partnerName} / ${gift.amount}');
    } else {
      // 기존 데이터 수정
      await DatabaseHelper.instance.updateGift(gift);
      debugPrint('✅ Gift 수정 완료: ${gift.partnerName} / ${gift.amount}');
    }
  }

}
