import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/button_listener.dart';
import 'package:pos/presentation/detail_items_scan/bloc/detail_item_scan_bloc.dart';
import 'package:pos/presentation/home/bloc/home_bloc.dart';
import 'package:pos/presentation/scan_find_items/bloc/scan_find_items_page_bloc.dart';
import 'package:pos/route.dart';

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
        BlocProvider<HomeBloc>(create: (BuildContext context) => HomeBloc()),
        BlocProvider<ScanFindItemsPageBloc>(create: (BuildContext context) => ScanFindItemsPageBloc()),
        BlocProvider<DetailItemScanBloc>(create: (BuildContext context) => DetailItemScanBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFF5ECD5)),
          useMaterial3: true,
        ),
        initialRoute: "/splash",
        onGenerateRoute: (route) => onGenerateRoute(route),
      ),
    );
  }
}
