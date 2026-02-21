// // ignore_for_file: avoid_unnecessary_containers, sort_child_properties_last

// import 'package:dotted_line/dotted_line.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:kymscanner/constant.dart';
// import 'package:kymscanner/data/api/api.dart';
// import 'package:kymscanner/main.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:kymscanner/data/models/home_model.dart';
// import 'package:kymscanner/presentation/home/bloc/home_bloc.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:uuid/uuid.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> with RouteAware {
//   DateTime selectedDate = DateTime.now();
//   String _appVersion = '';
//   final TextEditingController _controllerRemark = TextEditingController();
//   List<Map<String, dynamic>> periodReleaseDialog = [];
//   late SharedPreferences prefs;

//   @override
//   void initState() {
//     super.initState();
//     _fetchAppVersion();
//   }

//   @override
//   void didChangeDependencies() async {
//     _startEventHome();
//     _setUpVariables();
//     periodReleaseDialog = await _getPeriodReleaseForDialog() ?? [];
//     routeObserver.subscribe(this, ModalRoute.of(context)!);
//     super.didChangeDependencies();
//   }

//   @override
//   void didPopNext() async {
//     periodReleaseDialog = await _getPeriodReleaseForDialog() ?? [];
//     final ModalRoute<dynamic>? route = ModalRoute.of(context);
//     if (route != null && route.isCurrent == false) {
//       _startEventHome();
//       _setUpVariables();
//     }
//   }

//   Future<void> _fetchAppVersion() async {
//     final packageInfo = await PackageInfo.fromPlatform();
//     setState(() {
//       _appVersion = 'v${packageInfo.version}+${packageInfo.buildNumber}';
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFFFFAEC),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             SizedBox(
//               child: Center(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 30),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Container(
//                         height: MediaQuery.of(context).size.height * 0.1,
//                         alignment: Alignment.center,
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 ElevatedButton(
//                                   onPressed: () {
//                                     _selectDate(context);
//                                   },
//                                   child: Text(
//                                     'Select date',
//                                     style: TextStyle(
//                                       color: Colors.black,
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 18,
//                                     ),
//                                   ),
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.greenAccent,
//                                   ),
//                                 ),
//                                 SizedBox(width: 20),
//                                 Text(
//                                   "${selectedDate.toLocal()}".split(' ')[0],
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 18,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             IconButton(
//                               icon: Icon(Icons.account_circle),
//                               onPressed: () async {
//                                 confirmLogout(context);
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                       BlocBuilder<HomeBloc, HomeState>(
//                         builder: (context, state) {
//                           if (state is HomeLoadingState) {
//                             return CircularProgressIndicator();
//                           } else if (state is HomeErrorState) {
//                             return Center(child: Text("เกิดข้อผิดพลาดบางอย่าง"));
//                           } else if (state is HomeLoadedState) {
//                             HomeModel model = state.model;
//                             return Column(
//                               children: [
//                                 Container(
//                                   height: MediaQuery.of(context).size.height * 0.06,
//                                   alignment: Alignment.center,
//                                   child: Text("Total: ${model.totalPickup.toString()}", style: TextStyle(fontSize: 20)),
//                                 ),
//                                 _colorItems(model.countGreen, model.countRed, model.countOther),
//                                 Container(
//                                   height: MediaQuery.of(context).size.height * 0.06,
//                                   alignment: Alignment.center,
//                                   child: DottedLine(
//                                     lineThickness: 2,
//                                     dashLength: 3,
//                                   ),
//                                 ),
//                                 Container(
//                                   height: MediaQuery.of(context).size.height * 0.06,
//                                   alignment: Alignment.center,
//                                   child: Text("Pick Up", style: TextStyle(fontSize: 20)),
//                                 ),
//                                 _releaseItemss(model.countPickupByUps, model.countPickupBySkl, model.countPickupByL),
//                                 Container(
//                                   height: MediaQuery.of(context).size.height * 0.06,
//                                   alignment: Alignment.center,
//                                   child: DottedLine(
//                                     lineThickness: 2,
//                                     dashLength: 3,
//                                   ),
//                                 ),
//                                 _countStatusText("เจอของ", model.scannedPickup),
//                                 _countStatusText("ของพร้อมปล่อย", model.pendingReleasePickup),
//                                 _countStatusText("ปล่อยของ", model.releasePickup),
//                                 _countStatusText("พบปัญหา", model.problemPickup),
//                                 _countStatusText("อื่นๆ", model.otherPickup),
//                               ],
//                             );
//                           }
//                           return Center(child: Text("เกิดข้อผิดพลาดบางอย่าง"));
//                         },
//                       ),
//                       Padding(
//                         padding: EdgeInsets.only(bottom: 30),
//                         child: Column(
//                           children: [
//                             _scanFindItemsButton(),
//                             SizedBox(height: 20),
//                             _scanAndRelease(),
//                             SizedBox(height: 20),
//                             _releaseItemsButton(),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//               bottom: 8,
//               right: 10,
//               child: Text(
//                 _appVersion,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<dynamic> confirmLogout(BuildContext context) {
//     return showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           content: Container(
//             height: MediaQuery.of(context).size.height * 0.20,
//             alignment: Alignment.center,
//             child: Text(
//               'ออกจากระบบบนอุปกรณ์นี้',
//             ),
//           ),
//           actions: [
//             TextButton(
//               style: TextButton.styleFrom(
//                 textStyle: Theme.of(context).textTheme.labelLarge,
//               ),
//               child: const Text('ยกเลิก'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               style: TextButton.styleFrom(
//                 textStyle: Theme.of(context).textTheme.labelLarge,
//               ),
//               child: const Text('ออกจากระบบ'),
//               onPressed: () async {
//                 prefs.remove("username");
//                 prefs.remove("password");
//                 prefs.remove("accessToken");
//                 Navigator.of(context).pop();
//                 Navigator.pushReplacementNamed(context, "/login");
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate,
//       firstDate: DateTime(2000),
//       lastDate: DateTime.now().add(Duration(days: 365)),
//     );
//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         selectedDate = picked;
//       });
//       context.read<HomeBloc>().add(HomeLoadingEvent(date: "${picked.year}-${picked.month}-${picked.day}"));
//     }
//   }

//   Widget _countStatusText(String title, int count) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text(
//           "$title (",
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//         ),
//         Text(
//           "$count",
//           style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20),
//         ),
//         Text(
//           ")",
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//         ),
//       ],
//     );
//   }

//   Widget _colorItems(int green, int red, int other) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: [
//         Row(
//           children: [
//             Text(
//               "Green",
//               style: TextStyle(
//                 color: Colors.green,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 20,
//               ),
//             ),
//             Text(
//               ": $green",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 20,
//               ),
//             ),
//           ],
//         ),
//         Row(
//           children: [
//             Text(
//               "Red",
//               style: TextStyle(
//                 color: Colors.red,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 20,
//               ),
//             ),
//             Text(
//               ": $red",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 20,
//               ),
//             ),
//           ],
//         ),
//         Row(
//           children: [
//             Text(
//               "Other",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 20,
//               ),
//             ),
//             Text(
//               ": $other",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 20,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _releaseItemss(int ups, int skl, int l) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: [
//         Row(
//           children: [
//             Text(
//               "UPS",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 20,
//               ),
//             ),
//             Text(
//               ": $ups",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 20,
//               ),
//             ),
//           ],
//         ),
//         Row(
//           children: [
//             Text(
//               "SKL",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 20,
//               ),
//             ),
//             Text(
//               ": $skl",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 20,
//               ),
//             ),
//           ],
//         ),
//         Row(
//           children: [
//             Text(
//               "L",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 20,
//               ),
//             ),
//             Text(
//               ": $l",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 20,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _scanFindItemsButton() {
//     return Container(
//       width: MediaQuery.of(context).size.width,
//       child: ElevatedButton(
//         onPressed: () {
//           Navigator.pushNamed(context, "/scanFindItems",
//               arguments: {"datePick": "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}"}).then((value) {
//             context
//                 .read<HomeBloc>()
//                 .add(HomeLoadingEvent(date: "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}"));
//           });
//         },
//         child: Text("สแกนหาของ", style: TextStyle(color: Colors.black, fontSize: 18)),
//         style: ButtonStyle(
//           backgroundColor: WidgetStateProperty.all(Colors.lightGreenAccent),
//           textStyle: WidgetStateProperty.all(
//             TextStyle(
//               color: Colors.black,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           shape: WidgetStateProperty.all<OutlinedBorder>(
//             RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//               side: BorderSide(
//                 color: Colors.black,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _scanAndRelease() {
//     return Container(
//       width: MediaQuery.of(context).size.width,
//       child: ElevatedButton(
//         onPressed: () {
//           Navigator.pushNamed(context, "/scanAndRelease",
//               arguments: {"datePick": "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}"}).then((value) {
//             context
//                 .read<HomeBloc>()
//                 .add(HomeLoadingEvent(date: "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}"));
//           });
//         },
//         child: Text("สแกนพร้อมปล่อยของ", style: TextStyle(color: Colors.black, fontSize: 18)),
//         style: ButtonStyle(
//           backgroundColor: WidgetStateProperty.all(Colors.lightGreenAccent),
//           textStyle: WidgetStateProperty.all(
//             TextStyle(
//               color: Colors.black,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           shape: WidgetStateProperty.all<OutlinedBorder>(
//             RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//               side: BorderSide(
//                 color: Colors.black,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _releaseItemsButton() {
//     return Container(
//       width: MediaQuery.of(context).size.width,
//       child: ElevatedButton(
//         onPressed: () async {
//           _controllerRemark.text = "";
//           await _dialogRemarkOfReleaseItem().then((value) async {
//             String date = "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
//             if (value! == false) {
//               context.read<HomeBloc>().add(HomeLoadingEvent(date: date));
//               return;
//             } else {
//               Navigator.pushNamed(context, "/releaseItems", arguments: {
//                 "datePick": date,
//               });
//             }
//           });
//         },
//         child: Text("ปล่อยของ", style: TextStyle(color: Colors.black, fontSize: 18)),
//         style: ButtonStyle(
//           backgroundColor: WidgetStateProperty.all(Colors.lightGreenAccent),
//           textStyle: WidgetStateProperty.all(
//             TextStyle(
//               color: Colors.black,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           shape: WidgetStateProperty.all<OutlinedBorder>(
//             RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//               side: BorderSide(
//                 color: Colors.black,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<bool?> _dialogRemarkOfReleaseItem() async {
//     return await showDialog<bool>(
//       context: context,
//       barrierDismissible: true,
//       builder: (BuildContext context) {
//         final remarkReleaseFormKey = GlobalKey<FormState>();

//         String? selectedValue;
//         bool isCustom = false;

//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//               title: const Text('รอบที่ปล่อย', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//               content: Form(
//                 key: remarkReleaseFormKey,
//                 child: SizedBox(
//                   width: double.maxFinite,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       if (!isCustom)
//                         DropdownButtonFormField<String>(
//                           decoration: InputDecoration(
//                             labelText: 'รายการ',
//                             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                           ),
//                           items: periodReleaseDialog.map((value) {
//                             return DropdownMenuItem<String>(
//                               value: value["value"],
//                               child: value["totalItem"] == null
//                                   ? Text(value["text"])
//                                   : Text("${value["text"]} || ${value["totalItem"]}"),
//                             );
//                           }).toList(),
//                           onChanged: (value) {
//                             setState(() {
//                               if (value == 'ระบุเอง') {
//                                 isCustom = true;
//                               } else {
//                                 selectedValue = value;
//                               }
//                             });
//                           },
//                           validator: (value) => value == null ? 'กรุณาเลือกตัวเลือก' : null,
//                         ),
//                       if (isCustom)
//                         TextFormField(
//                           controller: _controllerRemark,
//                           decoration: InputDecoration(
//                             labelText: 'ระบุค่าของคุณ',
//                             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                             suffixIcon: IconButton(
//                               icon: Icon(Icons.arrow_back),
//                               tooltip: 'ย้อนกลับไปเลือกจากรายการ',
//                               onPressed: () {
//                                 setState(() {
//                                   isCustom = false;
//                                   _controllerRemark.clear();
//                                 });
//                               },
//                             ),
//                           ),
//                           validator: (value) => (value == null || value.isEmpty) ? 'กรุณาระบุข้อความ' : null,
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   child: const Text('ยกเลิก'),
//                   onPressed: () => Navigator.of(context).pop(false),
//                 ),
//                 ElevatedButton(
//                   child: const Text('ยืนยัน'),
//                   onPressed: () async {
//                     if (remarkReleaseFormKey.currentState!.validate()) {
//                       await _resolveFinalInputValue(isCustom, selectedValue);
//                       Navigator.of(context).pop(true);
//                     }
//                   },
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   void _startEventHome() {
//     String date = "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
//     context.read<HomeBloc>().add(HomeLoadingEvent(date: date));
//   }

//   Future<void> _resolveFinalInputValue(bool isCustom, String? selectedValue) async {
//     String? result;
//     if (isCustom) {
//       // TextFormField
//       String input = _controllerRemark.text.trim();
//       if (input.isNotEmpty) {
//         result = input;
//       }
//     } else {
//       // Dropdown
//       if (selectedValue != null && selectedValue.isNotEmpty) {
//         result = selectedValue;
//       }
//     }
//     await _handleAndSaveUserSelection(isCustom, result!);
//   }

//   Future<void> saveSelection(String key, String value) async {
//     await prefs.setString(key, value);
//   }

//   Future<List<Map<String, dynamic>>?> _getPeriodReleaseForDialog() async {
//     String date = "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
//     List<Map<String, dynamic>> periodRelease = await DataService().getReleaseRound(date) ?? [];
//     periodRelease.addAll([
//       {"text": "ระบุเอง", "value": "ระบุเอง", "totalItem": null}
//     ]);
//     return periodRelease;
//   }

//   Future<void> _handleAndSaveUserSelection(bool isCustom, String selectedValue) async {
//     if (isCustom) {
//       // TextFormField
//       await prefs.setString(releaseRoundName, selectedValue);
//       await prefs.setString(releaseRoundUUID, Uuid().v4());
//     } else {
//       // DropDown
//       String selectedName = periodReleaseDialog.firstWhere(
//         (item) => item['value'] == selectedValue,
//       )['text'];
//       await prefs.setString(releaseRoundName, selectedName);
//       await prefs.setString(releaseRoundUUID, selectedValue);
//     }
//   }

//   Future<void> _setUpVariables() async {
//     periodReleaseDialog = await _getPeriodReleaseForDialog() ?? [];
//     prefs = await SharedPreferences.getInstance();
//     prefs.remove(releaseRoundName);
//     prefs.remove(releaseRoundUUID);
//   }
// }
