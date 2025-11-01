import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../repositories/gift_repository.dart';
import '../viewmodels/friends_view_model.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// 🎯 ScreenFriends
/// 유저별 주고받은 금액 요약을 보여주는 화면
class ScreenFriends extends StatefulWidget {
  const ScreenFriends({super.key});

  @override
  State<ScreenFriends> createState() => _ScreenFriendsState();
}

class _ScreenFriendsState extends State<ScreenFriends> {
  late final FriendsViewModel viewModel;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    viewModel = FriendsViewModel(repository: GiftRepository());
    viewModel.loadFriends();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<FriendsViewModel>(
        builder: (context, vm, _) {
          return GestureDetector(
            // ✅ 빈 화면을 탭했을 때 키보드 내려가기
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              backgroundColor: AppColors.mainBackground,
              body: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// 1️⃣ 상단 앱 이름
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 26, left: 16, right: 16, bottom: 16),
                      child: Text(
                          '마음을 전한 사람들',
                          style: AppTextStyles.mg24Black
                      ),
                    ),


                    /// 🔍 SearchBar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: '이름을 입력하세요',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          vm.searchFriends(value.trim());
                        },
                      ),
                    ),

                    SizedBox(height: 16),

                    /// 📋 리스트
                    Expanded(
                      child: vm.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : vm.filteredFriends.isEmpty
                          ? const Center(
                        child: Text('검색 결과가 없습니다.',
                            style: TextStyle(color: Colors.grey)),
                      )
                          : ListView.builder(
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: vm.filteredFriends.length,
                        itemBuilder: (context, index) {
                          final friend = vm.filteredFriends[index];
                          return _FriendCell(friend: friend);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 🧱 FriendCell: 한 명의 유저 정보를 표시하는 셀
class _FriendCell extends StatelessWidget {
  final FriendSummary friend;

  const _FriendCell({required this.friend});

  @override
  Widget build(BuildContext context) {
    final totalSent = friend.totalSent;
    final totalReceived = friend.totalReceived;

    // 🔹 Progress bar 계산
    final maxValue = totalSent > totalReceived ? totalSent : totalReceived;
    final sentRatio = maxValue == 0 ? 0.0 : totalSent / maxValue;
    final receivedRatio = maxValue == 0 ? 0.0 : totalReceived / maxValue;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 이름
          Text(friend.name, style: AppTextStyles.body17bBlack),
          const SizedBox(height: 8),

          /// 준 금액
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('전한 마음', style: TextStyle(fontSize: 14)),
              Text('${NumberFormat('#,###').format(friend.totalSent)}원',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),

          _ProgressBar(
              color: AppColors.errorRed, value: sentRatio, height: 6),

          const SizedBox(height: 10),

          /// 받은 금액
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('받은 마음', style: TextStyle(fontSize: 14)),
              Text('${NumberFormat('#,###').format(friend.totalReceived)}원',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          _ProgressBar(
              color: AppColors.mainBlue, value: receivedRatio, height: 6),
        ],
      ),
    );
  }
}

/// 📊 Custom ProgressBar 위젯
class _ProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final Color color;

  const _ProgressBar({
    required this.value,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth * value;
      return Stack(
        children: [
          Container(
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
        ],
      );
    });
  }
}
