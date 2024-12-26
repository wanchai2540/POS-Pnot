import 'package:flutter/material.dart';
import 'package:pos/presentation/detail_items_scan/detailItemScan.dart';
import 'package:pos/presentation/home/home.dart';
import 'package:pos/presentation/login.dart';
import 'package:pos/presentation/release_items/releaseItems.dart';
import 'package:pos/presentation/scan_and_release/scanAndRelease.dart';
import 'package:pos/presentation/scan_find_items/scanFindItems.dart';
import 'package:pos/presentation/splash.dart';

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/splash':
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) {
          return SplashPage();
        },
      );
    case '/login':
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) {
          return LoginPage();
        },
      );
    case '/home':
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) {
          return HomePage();
        },
      );
    case '/scanFindItems':
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) {
          return ScanFindItemsPage();
        },
      );
    case '/detailItemScan':
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) {
          return DetailScanItemPage();
        },
      );
    case '/scanAndRelease':
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) {
          return ScanAndReleasePage();
        },
      );
    case '/releaseItems':
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) {
          return ReleaseItemsPage();
        },
      );
  }
  return null;
}
