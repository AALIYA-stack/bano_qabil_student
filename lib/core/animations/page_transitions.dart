import 'package:flutter/material.dart';

enum AppPageTransition {
  fade,
  slide,
  scale,
  fadeSlide,
}

class AppPageTransitions {
  AppPageTransitions._();

  static Route<T> fade<T>(
      Widget page,
      ) {
    return PageRouteBuilder<T>(
      pageBuilder: (
          context,
          animation,
          secondaryAnimation,
          ) {
        return page;
      },
      transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
          ) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(
        milliseconds: 300,
      ),
    );
  }

  static Route<T> slide<T>(
      Widget page,
      ) {
    return PageRouteBuilder<T>(
      pageBuilder: (
          context,
          animation,
          secondaryAnimation,
          ) {
        return page;
      },
      transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
          ) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.08, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        );

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(
        milliseconds: 350,
      ),
    );
  }

  static Route<T> scale<T>(
      Widget page,
      ) {
    return PageRouteBuilder<T>(
      pageBuilder: (
          context,
          animation,
          secondaryAnimation,
          ) {
        return page;
      },
      transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
          ) {
        final scaleAnimation = Tween<double>(
          begin: 0.94,
          end: 1,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        );

        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(
        milliseconds: 350,
      ),
    );
  }

  static Route<T> fadeSlide<T>(
      Widget page,
      ) {
    return PageRouteBuilder<T>(
      pageBuilder: (
          context,
          animation,
          secondaryAnimation,
          ) {
        return page;
      },
      transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
          ) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        );

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(
        milliseconds: 350,
      ),
    );
  }
}