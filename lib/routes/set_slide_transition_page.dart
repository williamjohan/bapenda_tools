import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class STSlideTransitionPage<T> extends CustomTransitionPage<T> {
  STSlideTransitionPage({
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
    super.key,
  }) : super(
         transitionDuration: const Duration(milliseconds: 300),
         reverseTransitionDuration: const Duration(milliseconds: 300),
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           const begin = Offset(1.0, 0.0);
           const end = Offset.zero;
           const curve = Curves.easeInOutCubic;
           var tween = Tween(
             begin: begin,
             end: end,
           ).chain(CurveTween(curve: curve));
           var offsetAnimation = animation.drive(tween);

           return SlideTransition(position: offsetAnimation, child: child);
         },
       );
}
