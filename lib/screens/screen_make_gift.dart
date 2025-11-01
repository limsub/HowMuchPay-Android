// lib/screens/make_gift_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart'; // ✅ 이걸 추가해야 CupertinoDatePicker 사용 가능
import 'package:intl/intl.dart'; // 날짜 포맷용

// 프로젝트 전역 스타일/색상 사용 (없다면 기본값으로 대체)
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../viewmodels/make_gift_view_model.dart';
import '../models/gift.dart'; // ✅ 기존 Gift 데이터를 받아서 수정 모드로 표시하기 위함


class MakeGiftScreen extends StatelessWidget {
  final Gift? existingGift;
  final bool isEditMode;

  const MakeGiftScreen({
    super.key,
    this.existingGift,
    this.isEditMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // ✅ 기존 Gift가 있다면 ViewModel 초기화 시 전달
      create: (_) => MakeGiftViewModel(existingGift: existingGift),
      child: _MakeGiftScreenBody(isEditMode: isEditMode),
    );
  }
}

class _MakeGiftScreenBody extends StatelessWidget {
  final bool isEditMode;
  const _MakeGiftScreenBody({super.key, required this.isEditMode});

  // 날짜 선택 다이얼로그
  Future<void> _pickDate(BuildContext context, MakeGiftViewModel vm) async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Container(
          height: 250,
          color: Colors.white,
          child: Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: vm.selectedDate,
              minimumDate: DateTime(2000),
              maximumDate: DateTime(2100),
              // locale: const Locale('ko', 'KR'),
              onDateTimeChanged: (date) {
                  vm.setDate(date);
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MakeGiftViewModel>();

    // 앱 전역 스타일이 없을 경우를 대비한 폴백
    final titleStyle = AppTextStyles.title ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.w700);
    final titleLabelStyle = AppTextStyles.body14m.copyWith(color: AppColors.grey06);
    final buttonTitleStyle = AppTextStyles.body16m.copyWith(color: Colors.grey);
    final textFieldStyle = AppTextStyles.body16mBlack;
    final bodyStyle = AppTextStyles.body14m ?? const TextStyle(fontSize: 16);

    return GestureDetector(
      onTap: () {
        // 화면 아무 곳이나 탭하면 포커스 해제 → 키보드 내려감
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true, // ✅ 키보드에 따라 화면 자동 조정
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true, // 타이틀 중앙 정렬
          title: Text('기록', style: AppTextStyles.body17bBlack),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            Consumer<MakeGiftViewModel>(
              builder: (context, vm, child) {
                return TextButton(
                  onPressed: () async {
                    final error = vm.validate();
                    if (error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error)));
                      return;
                    }
                    await vm.save();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    '저장',
                    style: AppTextStyles.body17mBlack.copyWith(
                      color: vm.canSave ? AppColors.mainBlue : Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ],
        ),

        // 전체 화면을 스크롤 가능하게 함
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ✅ 이름 입력
                const SizedBox(height: 6),
                // - 타이틀 레이블
                Text('이름 입력', style: titleLabelStyle),
                const SizedBox(height: 8),
                // - 텍스트필드
                TextField(
                  controller: vm.nameController,
                  decoration: InputDecoration(
                    hintText: '이름을 입력해주세요',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: AppColors.grey01,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: vm.nameHasText ? Colors.blue : Colors.transparent,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: vm.nameHasText ? Colors.blue : Colors.transparent,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  cursorColor: AppColors.mainBlue,
                  style: textFieldStyle
                ),


                const SizedBox(height: 36),

                // ✅ 유형 선택 (전한 마음 / 받은 마음)
                Text('유형 선택', style: titleLabelStyle),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => vm.toggleIsSent(true),
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: vm.isSent ? AppColors.mainBlue.withValues(alpha: 0.15) : AppColors.white09,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('전한 마음', style: buttonTitleStyle.copyWith(color: vm.isSent ? AppColors.mainBlue : Colors.grey)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => vm.toggleIsSent(false),
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: !vm.isSent ? AppColors.mainBlue.withValues(alpha: 0.15) : AppColors.white09,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('받은 마음', style: buttonTitleStyle.copyWith(color: !vm.isSent ? AppColors.mainBlue : Colors.grey)),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 36),

                // ✅ 금액 입력
                Text('금액 입력', style: titleLabelStyle),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFFAFBFD),
                  ),
                  child: TextField(
                    controller: vm.amountController,
                    keyboardType: TextInputType.number,
                    onChanged: vm.onAmountChanged,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: '200,000',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: AppColors.grey01,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: vm.amountHasText ? Colors.blue : Colors.transparent,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: vm.amountHasText ? Colors.blue : Colors.transparent,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      suffixText: '원',
                      suffixStyle: bodyStyle.copyWith(color: Colors.grey[500]),
                    ),
                    cursorColor: AppColors.mainBlue,
                    style: textFieldStyle,
                  ),
                ),

                const SizedBox(height: 36),

                // ✅ 경조사 종류 선택
                Text('경조사 종류 선택', style: titleLabelStyle),
                const SizedBox(height: 8),
                Row(
                  spacing: 12,
                  children: List.generate(4, (index) {
                    final labels = ['결혼식', '돌잔치', '장례식', '기타'];
                    final selected = vm.eventType == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => vm.setEventType(index),
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.mainBlue.withValues(alpha: 0.15) : AppColors.white09,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            labels[index],
                            style: buttonTitleStyle.copyWith(color: selected ? AppColors.mainBlue : Colors.grey),
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 36),

                // ✅ 날짜 입력 (버튼 형태)
                Text('날짜 입력', style: titleLabelStyle),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _pickDate(context, vm),
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.grey01,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.mainBlue, // 테두리 색상
                        width: 1,           // 테두리 두께
                      ),
                    ),
                    child: Text(
                      DateFormat('yyyy.MM.dd').format(vm.selectedDate),
                      style: AppTextStyles.body18mBlack,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // ✅ 메모 입력
                Text('메모 입력', style: titleLabelStyle),
                const SizedBox(height: 12),
                Container(
                  height: 260, // 스크롤 영역이므로 충분한 높이
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFBFD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: vm.memoController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      hintText: '추가로 기록할 내용이 있나요?',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: AppColors.grey01,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: vm.memoHasText ? Colors.blue : Colors.transparent,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: vm.memoHasText ? Colors.blue : Colors.transparent,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    cursorColor: AppColors.mainBlue,
                    style: textFieldStyle
                  ),
                ),

                const SizedBox(height: 28), // 추가 여유 공간
              ],
            ),
          ),
        ),
      ),
    );
  }
}
