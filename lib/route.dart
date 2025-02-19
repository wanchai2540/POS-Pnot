import 'package:flutter/material.dart';
import 'package:kymscanner/presentation/detail_items_scan/detailItemScan.dart';
import 'package:kymscanner/presentation/home/home.dart';
import 'package:kymscanner/presentation/login.dart';
import 'package:kymscanner/presentation/release_items/releaseItems.dart';
import 'package:kymscanner/presentation/scan_and_release/scanAndRelease.dart';
import 'package:kymscanner/presentation/scan_find_items/repack.dart';
import 'package:kymscanner/presentation/scan_find_items/report.dart';
import 'package:kymscanner/presentation/scan_find_items/scanFindItems.dart';
import 'package:kymscanner/presentation/splash.dart';

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
          Map args = settings.arguments as Map;
          return DetailScanItemPage(uuid: args["uuid"], hawb: args["hawb"]);
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
    // case '/report':
    //   return PageRouteBuilder(
    //     settings: settings,
    //     pageBuilder: (context, animation, secondaryAnimation) {
    //       return ReportPage();
    //     },
    //   );
    // case '/repack':
    //   return PageRouteBuilder(
    //     settings: settings,
    //     pageBuilder: (context, animation, secondaryAnimation) {
    //       return RepackPage();
    //     },
    //   );
  }
  return null;
}
