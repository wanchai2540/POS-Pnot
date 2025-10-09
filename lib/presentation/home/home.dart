// ignore_for_file: avoid_unnecessary_containers, sort_child_properties_last

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kymscanner/button_listener.dart';
import 'package:kymscanner/common.dart';
import 'package:kymscanner/constant.dart';
import 'package:kymscanner/data/api/api.dart';
import 'package:kymscanner/data/models/search_model.dart';
import 'package:kymscanner/main.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:kymscanner/data/models/home_model.dart';
import 'package:kymscanner/presentation/home/bloc/home_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  ValueNotifier<DateTime> selectedDate = ValueNotifier<DateTime>(DateTime.now());
  DateTime? selectedDateAfter;

  final TextEditingController _controllerRemark = TextEditingController();
  ValueNotifier<List<Map<String, dynamic>>> periodReleaseDialog = ValueNotifier<List<Map<String, dynamic>>>([]);
  List<Map<String, dynamic>> periodReleaseDialogOriginal = [];
  late SharedPreferences prefs;
  bool _didInitReleaseDialog = false;
  bool _didRefreshReleaseDialog = false;
  bool _subscribed = false;
  ValueNotifier<bool> showSearchField = ValueNotifier<bool>(false);
  TextEditingController searchController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_subscribed) {
      final route = ModalRoute.of(context);
      if (route is PageRoute) {
        routeObserver.subscribe(this, route);
        _subscribed = true;
      }
    }
  }

  @override
  void didPopNext() {
    reloadDataFunction(null);
  }

  @override
  void dispose() {
    CustomButtonListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext contextRoot) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Color(0xFFFFFAEC),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            _body(contextRoot),
            Positioned(
              bottom: 8,
              left: 15,
              child: FutureBuilder<String>(
                future: _getAppVersion(),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: showSearchField,
        builder: (context, show, _) {
          return show
              ? Stack(
                  children: [
                    Positioned(
                      right: 0,
                      bottom: keyboardInset > 0 ? keyboardInset : 20,
                      child: _textFormFieldSearch(),
                    ),
                  ],
                )
              : FloatingActionButton(
                  onPressed: () {
                    showSearchField.value = true;
                    _onScannListener();
                  },
                  child: Icon(Icons.search),
                  backgroundColor: Colors.greenAccent,
                );
        },
      ),
    );
  }

  SizedBox _releaseItemsButton(BuildContext context, DateTime dateNow) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        onPressed: () async {
          _handleGetDataReleaseRound();
          _controllerRemark.text = "";
          await _dialogRemarkOfReleaseItem(context).then((value) async {
            if (value! == true) {
              if (context.mounted) {
                Navigator.pushNamed(context, "/releaseItems", arguments: {
                  "datePick": "${dateNow.year}-${dateNow.month}-${dateNow.day}",
                }).then((value) {
                  if (value != null && value is Map<String, dynamic>) {
                    reloadDataFunction(value["reloadData"]);
                  }
                });
              }
            }
          });
        },
        child: Text("ปล่อยของ", style: TextStyle(color: Colors.black, fontSize: 18)),
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.lightGreenAccent),
          textStyle: WidgetStateProperty.all(
            TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          shape: WidgetStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _dialogRemarkOfReleaseItem(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final remarkReleaseFormKey = GlobalKey<FormState>();

        String? selectedValue;
        bool isCustom = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('รอบที่ปล่อย', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              content: Form(
                key: remarkReleaseFormKey,
                child: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isCustom)
                        ValueListenableBuilder<List<Map<String, dynamic>>>(
                          valueListenable: periodReleaseDialog,
                          builder: (context, periodList, _) {
                            return DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'รายการ',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              items: periodList.map((value) {
                                return DropdownMenuItem<String>(
                                  value: value["value"],
                                  child: value["totalItem"] == null
                                      ? Text(value["text"])
                                      : Text("${value["text"]} || ${value["totalItem"]}"),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  if (value == 'ระบุเอง') {
                                    isCustom = true;
                                  } else {
                                    selectedValue = value;
                                  }
                                });
                              },
                              validator: (value) => value == null ? 'กรุณาเลือกตัวเลือก' : null,
                            );
                          },
                        ),
                      if (isCustom)
                        TextFormField(
                          controller: _controllerRemark,
                          decoration: InputDecoration(
                            labelText: 'ระบุค่าของคุณ',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.arrow_back),
                              tooltip: 'ย้อนกลับไปเลือกจากรายการ',
                              onPressed: () {
                                setState(() {
                                  isCustom = false;
                                  _controllerRemark.clear();
                                });
                              },
                            ),
                          ),
                          validator: (value) => (value == null || value.isEmpty) ? 'กรุณาระบุข้อความ' : null,
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('ยกเลิก'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                ElevatedButton(
                  child: const Text('ยืนยัน'),
                  onPressed: () async {
                    if (remarkReleaseFormKey.currentState!.validate()) {
                      await _resolveFinalInputValue(isCustom, selectedValue);
                      if (context.mounted) {
                        Navigator.of(context).pop(true);
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _resolveFinalInputValue(bool isCustom, String? selectedValue) async {
    String? result;
    if (isCustom) {
      // TextFormField
      String input = _controllerRemark.text.trim();
      if (input.isNotEmpty) {
        result = input;
      }
    } else {
      // Dropdown
      if (selectedValue != null && selectedValue.isNotEmpty) {
        result = selectedValue;
      }
    }
    await _handleAndSaveUserSelection(isCustom, result!);
  }

  Future<void> _handleAndSaveUserSelection(bool isCustom, String selectedValue) async {
    if (isCustom) {
      // TextFormField
      await prefs.setString(releaseRoundName, selectedValue);
      await prefs.setString(releaseRoundUUID, Uuid().v4());
    } else {
      // DropDown
      String selectedName = periodReleaseDialog.value.firstWhere(
        (item) => item['value'] == selectedValue,
      )['text'];
      await prefs.setString(releaseRoundName, selectedName);
      await prefs.setString(releaseRoundUUID, selectedValue);
    }
  }

  SizedBox _scanFindItemsButton(BuildContext context, DateTime dateNow) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, "/scanFindItems",
              arguments: {"datePick": "${dateNow.year}-${dateNow.month}-${dateNow.day}"}).then((value) {
            if (value != null && value is Map<String, dynamic>) {
              reloadDataFunction(value["reloadData"]);
            }
          });
        },
        child: Text("สแกนหาของ", style: TextStyle(color: Colors.black, fontSize: 18)),
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.lightGreenAccent),
          textStyle: WidgetStateProperty.all(
            TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          shape: WidgetStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  SizedBox _scanAndRelease(BuildContext context, DateTime dateNow) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, "/scanAndRelease",
              arguments: {"datePick": "${dateNow.year}-${dateNow.month}-${dateNow.day}"}).then((value) {
            if (value != null && value is Map<String, dynamic>) {
              reloadDataFunction(value["reloadData"]);
            }
          });
        },
        child: Text("สแกนพร้อมปล่อยของ", style: TextStyle(color: Colors.black, fontSize: 18)),
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.lightGreenAccent),
          textStyle: WidgetStateProperty.all(
            TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          shape: WidgetStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _countStatusText(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "$title (",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Text(
          "$count",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Text(
          ")",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ],
    );
  }

  Widget _releaseItemss(int ups, int skl, int l) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          children: [
            Text(
              "UPS",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              ": $ups",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              "SKL",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              ": $skl",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              "L",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              ": $l",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _colorItems(int green, int red, int other) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          children: [
            Text(
              "Green",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              ": $green",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              "Red",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              ": $red",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              "Other",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              ": $other",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _textFormFieldSearch() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.92,
      height: 50,
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        autofocus: true,
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'ค้นหา...',
          filled: true,
          fillColor: Colors.transparent,
          suffixIcon: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              searchController.clear();
              showSearchField.value = false;
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onFieldSubmitted: (value) {
          searchController.value = TextEditingValue.empty;
          showSearchField.value = false;
          _onScan(context, hawb: value.trim());
        },
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _body(BuildContext contextRoot) {
    return SizedBox(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: MediaQuery.of(contextRoot).size.height * 0.1,
                alignment: Alignment.center,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _selectDateFromDialog(contextRoot);
                          },
                          child: Text(
                            'Select date',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent,
                          ),
                        ),
                        SizedBox(width: 20),
                        ValueListenableBuilder<DateTime>(
                          valueListenable: selectedDate,
                          builder: (context, value, child) {
                            return Text(
                              "${value.toLocal()}".split(' ')[0],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.account_circle),
                      onPressed: () async {
                        confirmLogout(contextRoot);
                      },
                    ),
                  ],
                ),
              ),
              BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoadingState) {
                    return CircularProgressIndicator();
                  } else if (state is HomeErrorState) {
                    return Center(child: Text("เกิดข้อผิดพลาดบางอย่าง"));
                  } else if (state is HomeLoadedState) {
                    HomeModel model = state.model;
                    return Column(
                      children: [
                        Container(
                          height: MediaQuery.of(contextRoot).size.height * 0.06,
                          alignment: Alignment.center,
                          child: Text("Total: ${model.totalPickup.toString()}", style: TextStyle(fontSize: 20)),
                        ),
                        _colorItems(model.countGreen, model.countRed, model.countOther),
                        Container(
                          height: MediaQuery.of(contextRoot).size.height * 0.06,
                          alignment: Alignment.center,
                          child: DottedLine(
                            lineThickness: 2,
                            dashLength: 3,
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(contextRoot).size.height * 0.06,
                          alignment: Alignment.center,
                          child: Text("Pick Up", style: TextStyle(fontSize: 20)),
                        ),
                        _releaseItemss(model.countPickupByUps, model.countPickupBySkl, model.countPickupByL),
                        Container(
                          height: MediaQuery.of(contextRoot).size.height * 0.06,
                          alignment: Alignment.center,
                          child: DottedLine(
                            lineThickness: 2,
                            dashLength: 3,
                          ),
                        ),
                        _countStatusText("เจอของ", model.scannedPickup),
                        _countStatusText("ของพร้อมปล่อย", model.pendingReleasePickup),
                        _countStatusText("ปล่อยของ", model.releasePickup),
                        _countStatusText("พบปัญหา", model.problemPickup),
                        _countStatusText("อื่นๆ", model.otherPickup),
                      ],
                    );
                  }
                  return Center(child: Text("เกิดข้อผิดพลาดบางอย่าง"));
                },
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 30),
                child: Column(
                  children: [
                    _scanFindItemsButton(contextRoot, selectedDate.value),
                    SizedBox(height: 20),
                    _scanAndRelease(contextRoot, selectedDate.value),
                    SizedBox(height: 20),
                    _releaseItemsButton(contextRoot, selectedDate.value),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> confirmLogout(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            height: MediaQuery.of(context).size.height * 0.20,
            alignment: Alignment.center,
            child: Text(
              'ออกจากระบบบนอุปกรณ์นี้',
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('ออกจากระบบ'),
              onPressed: () async {
                prefs.remove("username");
                prefs.remove("password");
                prefs.remove("accessToken");
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, "/login");
              },
            ),
          ],
        );
      },
    );
  }

  Future<DateTime> _selectDateFromDialog(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
      if (context.mounted) {
        _refreshDataFromDate(selectedDate.value);
      }
    }
    return selectedDate.value;
  }

  void _handleGetDataReleaseRound() async {
    final now = DateTime.now();
    if (_didInitReleaseDialog) {
      if ((selectedDate.value.year != now.year ||
              selectedDate.value.month != now.month ||
              selectedDate.value.day != now.day) &&
          selectedDate.value != selectedDateAfter) {
        selectedDateAfter = selectedDate.value;
        _didInitReleaseDialog = true;
        periodReleaseDialog.value = await _initalReleaseRound(selectedDate.value);
      } else if (selectedDate.value.year == now.year &&
          selectedDate.value.month == now.month &&
          selectedDate.value.day == now.day) {
        periodReleaseDialog.value = periodReleaseDialogOriginal;
      }
    } else if (!_didInitReleaseDialog) {
      _didInitReleaseDialog = true;
      periodReleaseDialog.value = await _initalReleaseRound(selectedDate.value);
      periodReleaseDialogOriginal = periodReleaseDialog.value;
    }
  }

  void _refreshReleaseDialog() async {
    if (!_didRefreshReleaseDialog) {
      _didRefreshReleaseDialog = true;
      _refreshDataFromDate(selectedDate.value);
      periodReleaseDialog.value = await _initalReleaseRound(selectedDate.value);
      Future.delayed(Duration(milliseconds: 100), () {
        _didRefreshReleaseDialog = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _initalReleaseRound(DateTime dateNow) async {
    List<Map<String, dynamic>> resultReleaseRound = await _getPeriodReleaseForDialog(dateNow) ?? [];
    prefs = await SharedPreferences.getInstance();
    prefs.remove(releaseRoundName);
    prefs.remove(releaseRoundUUID);
    return resultReleaseRound;
  }

  Future<List<Map<String, dynamic>>?> _getPeriodReleaseForDialog(DateTime dateNow) async {
    String date = "${dateNow.year}-${dateNow.month}-${dateNow.day}";
    List<Map<String, dynamic>> periodRelease = await DataService().getReleaseRound(date) ?? [];
    periodRelease.addAll([
      {"text": "ระบุเอง", "value": "ระบุเอง", "totalItem": null}
    ]);
    return periodRelease;
  }

  void _refreshDataFromDate(DateTime? selectedDate) {
    DateTime dateNow = selectedDate ?? DateTime.now();
    if (context.mounted) {
      context.read<HomeBloc>().add(HomeLoadingEvent(date: "${dateNow.year}-${dateNow.month}-${dateNow.day}"));
    }
  }

  Future<String> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return 'v${packageInfo.version}+${packageInfo.buildNumber}';
  }

  void reloadDataFunction(bool? reloadData) {
    if (reloadData != null && reloadData == true) {
      _refreshReleaseDialog();
    }
  }

  void _onScannListener() {
    CustomButtonListener.onButtonPressed = (event) {
      if (event != null) {
        searchController.value = TextEditingValue.empty;
      }
    };
  }

  Future<void> _onScan(BuildContext parentContext, {required String hawb}) async {
    var dataGetScan = await DataService().getSearchItems(hawb);
    var data = dataGetScan["data"];

    try {
      if (context.mounted) {
        Navigator.of(parentContext).pushNamed("/search", arguments: {"hawb": hawb, "uuid": data["uuid"]});
      }
    } catch (e) {
      Exception(e);
    }
  }
}
