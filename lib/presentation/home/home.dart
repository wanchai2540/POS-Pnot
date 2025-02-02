// ignore_for_file: avoid_unnecessary_containers, sort_child_properties_last

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/data/models/home_model.dart';
import 'package:pos/presentation/home/bloc/home_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime selectedDate = DateTime.now();

  @override
  void didChangeDependencies() {
    _startEventHome();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFAEC),
      body: SafeArea(
        child: SizedBox(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.1,
                    alignment: Alignment.center,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _selectDate(context);
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
                                  backgroundColor: Colors.greenAccent),
                            ),
                            SizedBox(width: 20),
                            Text(
                              "${selectedDate.toLocal()}".split(' ')[0],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.account_circle),
                          onPressed: () async {
                            confirmLogout(context);
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
                              height: MediaQuery.of(context).size.height * 0.06,
                              alignment: Alignment.center,
                              child: Text(
                                  "Total: ${model.totalPickup.toString()}",
                                  style: TextStyle(fontSize: 20)),
                            ),
                            _colorItems(model.countGreen, model.countRed,
                                model.countOther),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.06,
                              alignment: Alignment.center,
                              child: DottedLine(
                                lineThickness: 2,
                                dashLength: 3,
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.06,
                              alignment: Alignment.center,
                              child: Text("Pick Up",
                                  style: TextStyle(fontSize: 20)),
                            ),
                            _releaseItemss(model.countPickupByUps,
                                model.countPickupBySkl, model.countPickupByL),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.06,
                              alignment: Alignment.center,
                              child: DottedLine(
                                lineThickness: 2,
                                dashLength: 3,
                              ),
                            ),
                            _countStatusText("เจอของ", model.scannedPickup),
                            _countStatusText(
                                "ของพร้อมปล่อย", model.pendingReleasePickup),
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
                        _scanFindItemsButton(),
                        SizedBox(height: 20),
                        _scanAndRelease(),
                        SizedBox(height: 20),
                        _releaseItemsButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
              'คุณแน่ใจใช่หรือไม่',
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
              child: const Text('ยืนยัน'),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
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

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      context.read<HomeBloc>().add(HomeLoadingEvent(
          date: "${picked.year}-${picked.month}-${picked.day}"));
    }
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
          style: TextStyle(
              color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Text(
          ")",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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

  Widget _scanFindItemsButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, "/scanFindItems", arguments: {
            "datePick":
                "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}"
          }).then((value) {
            context.read<HomeBloc>().add(HomeLoadingEvent(
                date:
                    "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}"));
          });
        },
        child: Text("สแกนหาของ",
            style: TextStyle(color: Colors.black, fontSize: 18)),
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

  Widget _scanAndRelease() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, "/scanAndRelease", arguments: {
            "datePick":
                "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}"
          }).then((value) {
            context.read<HomeBloc>().add(HomeLoadingEvent(
                date:
                    "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}"));
          });
        },
        child: Text("สแกนพร้อมปล่อยของ",
            style: TextStyle(color: Colors.black, fontSize: 18)),
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

  Widget _releaseItemsButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, "/releaseItems", arguments: {
            "datePick":
                "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}"
          }).then((value) {
            context.read<HomeBloc>().add(HomeLoadingEvent(
                date:
                    "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}"));
          });
        },
        child: Text("ปล่อยของ",
            style: TextStyle(color: Colors.black, fontSize: 18)),
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

  void _startEventHome() {
    String date =
        "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
    context.read<HomeBloc>().add(HomeLoadingEvent(date: date));
  }
}
