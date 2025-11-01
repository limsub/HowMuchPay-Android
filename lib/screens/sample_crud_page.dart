import 'dart:math';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/gift.dart';
import '../models/user_info.dart';

/// 🧪 SampleCrudPage
/// 버튼을 눌러 SQLite CRUD 동작을 테스트할 수 있는 화면
class SampleCrudPage extends StatelessWidget {
  const SampleCrudPage({super.key});

  // ✅ DatabaseHelper 싱글톤 인스턴스
  DatabaseHelper get db => DatabaseHelper.instance;

  // ✅ 랜덤 ID 생성 함수 (yyyyMMddHHmmss 형태)
  String _generateRandomId() {
    final now = DateTime.now();
    return "${now.year}${now.month}${now.day}${now.hour}${now.minute}${now.second}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SQLite CRUD 테스트")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// 🔴 CREATE 버튼
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                final gift = Gift(
                  id: _generateRandomId(),
                  partnerName: "user01",
                  giftType: Random().nextInt(2),
                  amount: 50000 + Random().nextInt(100000),
                  eventType: Random().nextInt(4),
                  date: "20250922",
                  memo: "자동 생성된 데이터",
                );
                await db.insertGift(gift);
                print("✅ CREATE 완료: ${gift.toMap()}");
              },
              child: const Text("CREATE (빨간색)"),
            ),

            const SizedBox(height: 16),

            /// 🔵 READ 버튼
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () async {
                final list = await db.getAllGifts();
                print("✅ READ 결과 (${list.length}건):");
                for (final g in list) {
                  print(" - ${g.toMap()}");
                }
              },
              child: const Text("READ (파란색)"),
            ),

            const SizedBox(height: 16),

            /// 🟢 DELETE 버튼
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                final list = await db.getAllGifts();
                if (list.isNotEmpty) {
                  final target = list.last;
                  await db.deleteGift(target.id);
                  print("✅ DELETE 완료: ${target.id}");
                } else {
                  print("❌ 삭제할 데이터 없음");
                }
              },
              child: const Text("DELETE (초록색)"),
            ),

            const SizedBox(height: 16),

            /// 🟡 UPDATE 버튼
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
              onPressed: () async {
                final list = await db.getAllGifts();
                if (list.isNotEmpty) {
                  final target = list.last;
                  final updated = Gift(
                    id: target.id,
                    partnerName: target.partnerName,
                    giftType: target.giftType,
                    amount: target.amount + 10000,
                    eventType: target.eventType,
                    date: target.date,
                    memo: "수정된 데이터",
                  );
                  await db.updateGift(updated);
                  print("✅ UPDATE 완료: ${updated.toMap()}");
                } else {
                  print("❌ 수정할 데이터 없음");
                }
              },
              child: const Text("UPDATE (노란색)"),
            ),
          ],
        ),
      ),
    );
  }
}

