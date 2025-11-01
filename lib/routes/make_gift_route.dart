import 'package:flutter/material.dart';
import '../screens/screen_make_gift.dart'; // 화면 import
import '../models/gift.dart';

Route createMakeGiftRoute({Gift? existingGift, bool isEditMode = false}) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => MakeGiftScreen(
      existingGift: existingGift,
      isEditMode: isEditMode,
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
