// 📦 sqflite 패키지와 path 패키지를 불러옵니다.
// sqflite → SQLite DB 사용 가능하게 하는 패키지
// path → 파일 경로를 쉽게 관리하는 유틸리티
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// 📘 models.dart 불러오기 (Gift, UserInfo 클래스 사용하기 위해)
import '../models/gift.dart';
import '../models/user_info.dart';

/// 🧩 DatabaseHelper 클래스
/// 앱 전체에서 DB에 접근할 수 있는 "싱글톤" 객체를 제공합니다.
class DatabaseHelper {
  // ✅ private 생성자 — 외부에서 직접 new로 생성할 수 없도록 막음
  DatabaseHelper._privateConstructor();

  // ✅ 싱글톤 인스턴스 (static → 클래스 차원의 공용 변수)
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // ✅ SQLite Database 객체를 담을 변수 (초기에 null)
  static Database? _database;

  // ✅ 데이터베이스를 불러오는 getter 함수
  Future<Database> get database async {
    // DB가 이미 열려 있다면 그대로 리턴
    if (_database != null) return _database!;

    // 처음 접근 시 DB 초기화
    _database = await _initDatabase();
    return _database!;
  }

  // ✅ 실제 DB 파일을 생성 및 초기화하는 함수
  Future<Database> _initDatabase() async {
    // 앱 내부 저장소의 DB 경로 얻기
    final dbPath = await getDatabasesPath();

    // 'how_much_pay.db'라는 이름으로 DB 생성
    final path = join(dbPath, 'how_much_pay.db');

    // openDatabase: DB를 열거나, 없으면 새로 생성
    return await openDatabase(
      path,
      version: 1, // 버전 1로 설정
      onCreate: _onCreate, // 처음 생성 시 실행할 함수 지정
    );
  }

  // ✅ DB 최초 생성 시 실행되는 함수 (테이블 생성)
  Future _onCreate(Database db, int version) async {
    // 🎁 Gift 테이블 생성
    await db.execute('''
      CREATE TABLE Gift (
        id TEXT PRIMARY KEY,
        partnerName TEXT,
        giftType INTEGER,
        amount INTEGER,
        eventType INTEGER,
        date TEXT,
        memo TEXT
      )
    ''');

    // 👤 UserInfo 테이블 생성
    await db.execute('''
      CREATE TABLE UserInfo (
        id TEXT PRIMARY KEY,
        name TEXT
      )
    ''');
  }

  // ✅ CREATE (데이터 추가)
  Future<void> insertGift(Gift gift) async {
    final db = await instance.database;
    await db.insert('Gift', gift.toMap());
  }

  // ✅ READ (모든 데이터 조회)
  Future<List<Gift>> getAllGifts() async {
    final db = await instance.database;
    final result = await db.query('Gift');
    final gifts = result.map((map) => Gift.fromMap(map)).toList();
    print('[DB] getAllGifts: ${gifts.length} items fetched ✅');
    return gifts;
  }

  // ✅ UPDATE (특정 데이터 수정)
// ✅ 기존 데이터를 삭제 후 새로 insert하는 방식으로 update 처리
  Future<void> updateGift(Gift gift) async {
    final db = await instance.database;

    // 1️⃣ 기존 데이터 삭제
    await deleteGift(gift.id);

    // 2️⃣ 새 데이터 insert
    await insertGiftWithUserCheck(gift);
    print('[DB] updateGift: id=${gift.id}, re-inserted ✅');
  }

  // ✅ DELETE (특정 데이터 삭제)
  Future<void> deleteGift(String id) async {
    final db = await instance.database;
    final count = await db.delete(
      'Gift',
      where: 'id = ?',
      whereArgs: [id],
    );
    print('[DB] deleteGift: id=$id, deleted rows=$count ✅');
  }

  Future<void> insertGiftWithUserCheck(Gift gift) async {
    final db = await instance.database;

    final existingUser = await db.query(
      'UserInfo',
      where: 'name = ?',
      whereArgs: [gift.partnerName],
    );

    if (existingUser.isEmpty) {
      final user = UserInfo(name: gift.partnerName);
      await db.insert('UserInfo', user.toMap());
      print('[DB] insertGiftWithUserCheck: User created name=${gift.partnerName} ✅');
    } else {
      print('[DB] insertGiftWithUserCheck: User already exists name=${gift.partnerName} ✅');
    }

    await db.insert('Gift', gift.toMap());
    print('[DB] insertGiftWithUserCheck: Gift inserted id=${gift.id}, partner=${gift.partnerName}, amount=${gift.amount} ✅');
  }
}