import 'package:flutter/material.dart';
import 'screens/sample_crud_page.dart'; // 우리가 만든 샘플 화면
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:async';


// 화면 import
import 'screens/screen_history.dart';
import 'screens/screen_friends.dart';
import 'constants/app_text_styles.dart';
import 'constants/app_colors.dart';

void main() {
  // 앱 실행
  runApp(MyApp());
}

// 앱 전체를 감싸는 최상위 위젯
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '얼마냈지', // 앱 이름
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('ko', ''),
      ],
      debugShowCheckedModeBanner: false, // 우측 상단 디버그 배너 제거
      theme: ThemeData(
        primarySwatch: Colors.blue, // 앱 전체 기본 색상
      ),
      home: SplashScreen(), // 앱 시작 화면
    );
  }
}




// ===================== 스플래시 화면 =====================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer(const Duration(seconds: 2), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBlue,
      body: Center(
        child: Text(
          '얼마\n냈지',
          style: AppTextStyles.mg24White,
        ),
      ),
    );
  }
}

// ===================== 홈 페이지(탭바) =====================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ScreenHistory(), // 첫 번째 화면
    ScreenFriends(), // 두 번째 화면
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.mainBlue,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
      ),
    );
  }
}