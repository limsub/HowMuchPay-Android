// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'screen_friends.dart'; // 스플래시 이후 이동할 화면
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({Key? key}) : super(key: key);
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // 2초 후 홈 화면으로 이동
//     Timer(const Duration(seconds: 2), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const FriendsScreen()),
//       );
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white, // 원하는 배경색
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // 앱 아이콘 또는 로고
//             Image.asset(
//               'assets/images/app_icon.png',
//               width: 120,
//               height: 120,
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Pay Note',
//               style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
