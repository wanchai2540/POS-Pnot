import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kymscanner/presentation/detail_items_scan/bloc/detail_item_scan_bloc.dart';
import 'package:kymscanner/presentation/home/bloc/home_bloc.dart';
import 'package:kymscanner/presentation/release_items/bloc/release_items_bloc.dart';
import 'package:kymscanner/presentation/scan_find_items/bloc/scan_find_items_page_bloc.dart';
import 'package:kymscanner/route.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(create: (BuildContext context) {
          String date = "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
          return HomeBloc()..add(HomeLoadingEvent(date: date));
        }),
        BlocProvider<ScanFindItemsPageBloc>(create: (BuildContext context) => ScanFindItemsPageBloc()),
        BlocProvider<DetailItemScanBloc>(create: (BuildContext context) => DetailItemScanBloc()),
        BlocProvider<ReleaseItemsBloc>(create: (BuildContext context) => ReleaseItemsBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFF5ECD5)),
          useMaterial3: true,
        ),
        initialRoute: "/splash",
        navigatorKey: navigatorKey,
        navigatorObservers: [routeObserver],
        onGenerateRoute: (route) => onGenerateRoute(route),
      ),
    );
  }
}
