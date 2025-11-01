import 'package:flutter/material.dart';
import 'package:how_much_pay/routes/make_gift_route.dart';
import 'package:provider/provider.dart';
import '../models/gift.dart';
import '../models/user_info.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../utils/date_utils.dart';
import '../viewmodels/history_view_model.dart';
import '../repositories/gift_repository.dart';

class ScreenHistory extends StatefulWidget {
  const ScreenHistory({super.key});

  @override
  State<ScreenHistory> createState() => _ScreenHistoryState();
}

class _ScreenHistoryState extends State<ScreenHistory> {
  late final HistoryViewModel viewModel;

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, HistoryViewModel viewModel, Gift gift) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: true, // 외부 터치로 닫기 허용
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // -------------------------------
                // 🧾 제목
                // -------------------------------
                Text(
                    '해당 기록을 삭제할까요?',
                    style: AppTextStyles.body17bBlack,
                    textAlign: TextAlign.center
                ),

                const SizedBox(height: 12),

                // -------------------------------
                // 💬 설명 텍스트 (선택사항)
                // -------------------------------
                Text(
                  '삭제된 기록은 복구할 수 없습니다.',
                  style: AppTextStyles.body14m.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 28),

                // -------------------------------
                // 버튼 영역
                // -------------------------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 취소 버튼
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          '취소',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 확인 버튼
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: const Text(
                          '확인',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    // ✅ 확인 시 삭제 실행
    if (shouldDelete == true) {
      try {
        await viewModel.deleteGift(gift.id);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('기록이 삭제되었습니다.'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }


  @override
  void initState() {
    super.initState();
    viewModel = HistoryViewModel(repository: GiftRepository());
    viewModel.loadData(); // 초기 로드
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: viewModel, // initState에서 만든 인스턴스 재사용
        child: Consumer<HistoryViewModel>(
            builder: (context, viewModel, child) {
              print('Consumer ViewModel hashCode: ${viewModel.hashCode}');

              if (viewModel.isLoading) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }


              final grouped = viewModel.groupByMonth();

              return Scaffold(
                backgroundColor: AppColors.mainBackground, // 배경색
                body: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// 1️⃣ 상단 앱 이름
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 26, left: 16, right: 16, bottom: 16),
                        child: Text(
                            '얼마냈지',
                            style: AppTextStyles.mg24Black
                        ),
                      ),

                      /// 2️⃣ 전한 마음 / 받은 마음
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child:
                            // 전한 마음
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '전한 마음',
                                  style: AppTextStyles.body16bBlack,
                                ),
                                Text(
                                    '${viewModel.totalGiven}원',
                                    style: AppTextStyles.title20b.copyWith(
                                        color: AppColors.errorRed
                                    )
                                ),
                              ],
                            ),
                            ),

                            Expanded(child:
                            // 받은 마음
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '받은 마음',
                                  style: AppTextStyles.body16bBlack,
                                ),
                                Text(
                                    '${viewModel.totalReceived}원',
                                    style: AppTextStyles.title20b.copyWith(
                                        color: AppColors.mainBlue
                                    )
                                ),
                              ],
                            ),
                            )

                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// 3️⃣ 스크롤 가능한 TableView 영역
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          itemCount: grouped.keys.length, // 월 단위 그룹 수
                          itemBuilder: (context, monthIndex) {
                            String monthKey = grouped.keys.elementAt(
                                monthIndex);
                            List<Gift> giftsInMonth = grouped[monthKey]!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                /// 🔹 월 Header Cell
                                Container(
                                  width: double.infinity,
                                  height: 60,
                                  alignment: Alignment.bottomLeft,
                                  padding: const EdgeInsets.only(
                                      bottom: 8, left: 20, right: 20),
                                  child: Text(
                                      '${monthKey.substring(0, 4)}년 ${monthKey
                                          .substring(4, 6)}월',
                                      style: AppTextStyles.title20b.copyWith(
                                          color: Colors.black)
                                  ),
                                ),

                                /// 🔹 Gift Cell
                                ...List.generate(giftsInMonth.length, (index) {
                                  final gift = giftsInMonth[index];
                                  final partner = viewModel.users[gift.partnerName] ?? UserInfo(name: '알수없음');


                                  return Container(
                                    height: 122,
                                    child: Row(

                                      children: [
                                        // -----------------------------
                                        // 1️⃣ 좌측: 날짜
                                        // -----------------------------
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20.0),
                                          child: SizedBox(
                                            width: 40,
                                            child: Column(
                                              children: [
                                                const SizedBox(height: 26),
                                                Text(
                                                  formatDayToEnglish(gift.date),
                                                  style: AppTextStyles
                                                      .body14mBlack,
                                                  textAlign: TextAlign
                                                      .left, // 좌측 정렬
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // -----------------------------
                                        // 2️⃣ 가운데: 구분선 (셀 위치별 길이 조절)
                                        // -----------------------------
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            // Stack 내 자식 중앙 정렬
                                            children: [
                                              // 1️⃣ 구분선
                                              Container(
                                                width: 1,
                                                // 구분선 길이는 셀 위치에 따라 조절
                                                margin: (giftsInMonth.length == 1)
                                                    ? EdgeInsets.only(top: 33, bottom: 87)
                                                    : (index == 0)
                                                    ? EdgeInsets.only(top: 33)
                                                    : (index ==
                                                    giftsInMonth.length - 1)
                                                    ? EdgeInsets.only(
                                                    bottom: 87)
                                                    : EdgeInsets.zero,
                                                color: AppColors.mainBlue,
                                              ),

                                              // 2️⃣ 구분선 위 원(circle)
                                              Column(
                                                children: [
                                                  const SizedBox(height: 33),
                                                  Container(
                                                    width: 6,
                                                    height: 6,
                                                    decoration: BoxDecoration(
                                                        color: AppColors
                                                            .mainBlue, // 원하는 색상
                                                        shape: BoxShape.circle
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        // -----------------------------
                                        // 3️⃣ 우측: 상대 이름 + 금액 + 준/받음 + 이벤트
                                        // -----------------------------
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () async {
                                              // ✅ 클릭 시 수정 화면으로 이동
                                              await Navigator.of(context).push(
                                                createMakeGiftRoute(
                                                  existingGift: gift, // Gift 전달
                                                  isEditMode: true,   // 수정 모드임을 명시
                                                ),
                                              );

                                              // 돌아오면 데이터 새로고침
                                              await context.read<HistoryViewModel>().loadData();
                                              setState(() {});
                                            },
                                            child: Container(
                                              margin: EdgeInsets.only(left: 4,
                                                  right: 20,
                                                  top: 5,
                                                  bottom: 8),
                                              padding: EdgeInsets.only(top: 16.0,
                                                  left: 16.0,
                                                  right: 16.0,
                                                  bottom: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.white, // 배경색
                                                borderRadius: BorderRadius
                                                    .circular(12), // 모서리 둥글기
                                                boxShadow: [ // 그림자 optional
                                                  BoxShadow(
                                                    color: Colors.black12,
                                                    blurRadius: 4,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Stack(
                                                children: [
                                                  // -----------------------------
                                                  // 실제 카드 모양의 내용 부분
                                                  // -----------------------------
                                                  Column(
                                                  crossAxisAlignment: CrossAxisAlignment
                                                      .start,
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .start,
                                                  children: [
                                                    // 상대 이름
                                                    Text(
                                                      '${partner.name}',
                                                      style: AppTextStyles
                                                          .body16bBlack,
                                                    ),

                                                    const SizedBox(height: 4),

                                                    // 금액
                                                    Text(
                                                      '${gift.amount}원',
                                                      style: AppTextStyles
                                                          .body16mBlack,
                                                    ),

                                                    const SizedBox(height: 4),
                                                    // 위아래 간격

                                                    // 이벤트 타입 + 준/받음 표시
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment
                                                          .start,
                                                      children: [
                                                        // 준/받음 표시
                                                        Container(
                                                          padding: EdgeInsets.all(
                                                              2.0),
                                                          decoration: BoxDecoration(
                                                            color: AppColors
                                                                .backgroundGray,
                                                            // 회색 배경
                                                            borderRadius: BorderRadius
                                                                .circular(
                                                                4), // 모서리 둥글기 4px
                                                          ),
                                                          child: Text(
                                                            gift.giftTypeEnum ==
                                                                GiftType.given
                                                                ? '전한 마음'
                                                                : '받은 마음',
                                                            style: AppTextStyles
                                                                .body14b.copyWith(
                                                              color: gift
                                                                  .giftTypeEnum ==
                                                                  GiftType.given
                                                                  ? AppColors
                                                                  .errorRed
                                                                  : AppColors
                                                                  .mainBlue,
                                                            ),
                                                          ),
                                                        ),

                                                        const SizedBox(width: 12),

                                                        // 이벤트 타입
                                                        Text(
                                                          "#${gift.eventTypeEnum
                                                              .koreanName}",
                                                          // wedding, firstBirth 등
                                                          style: AppTextStyles
                                                              .body14m.copyWith(
                                                              color: AppColors
                                                                  .grey06),
                                                        ),


                                                      ],
                                                    ),
                                                  ],
                                                ),

                                                  // -----------------------------
                                                  // 우측 상단의 X 버튼 (Column과 독립적)
                                                  // -----------------------------
                                                  Positioned(
                                                    top: 2,
                                                    right: 2,
                                                    child: GestureDetector(
                                                      onTap: () async {
                                                        // ✅ 팝업 띄우는 로직 (AlertDialog 등)
                                                        // viewModel은 Consumer의 파라미터로 이미 주입되어 있으므로 사용 가능.
                                                        // 만약 context.read<HistoryViewModel>() 형태를 선호하면 그것도 가능.
                                                        await _showDeleteConfirmationDialog(context, viewModel, gift);
                                                        // 주의: 여기서 setState()할 필요 없음 — ViewModel이 갱신하고 notifyListeners() 호출함.
                                                      },
                                                      child: Icon(
                                                        Icons.close,
                                                        color: Colors.grey,
                                                        size: 20,
                                                      ),
                                                    ),
                                                  ),

                                                ]
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () async {
                    // 🎯 새 화면으로 이동하고 결과를 기다림
                    await Navigator.of(context).push(createMakeGiftRoute());

                    // 🎯 새 Gift 화면이 닫히면 (pop) → DB에서 다시 데이터 불러오기
                    await context.read<HistoryViewModel>().loadData();
                    setState(() {

                    });
                  },
                  backgroundColor: AppColors.mainBlue,
                  shape: const CircleBorder(),
                  child: Icon(Icons.add, color: Colors.white),
                ),
              );
            }
        )
    );
  }
}