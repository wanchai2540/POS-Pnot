// ignore_for_file: avoid_unnecessary_containers, sort_child_properties_last

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/data/models/home_model.dart';
import 'package:pos/presentation/home/bloc/home_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime selectedDate = DateTime.now();
  int _total = 0;
  int _green = 0;
  int _red = 0;
  int _other = 0;
  int _ups = 0;
  int _skl = 0;
  int _l = 0;

  int _foundItems = 0;
  int _readyLeave = 0;
  int _leave = 0;

  @override
  void didChangeDependencies() {
    _startEventHome();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                              height: MediaQuery.of(context).size.height * 0.1,
                              alignment: Alignment.center,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
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
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
                                  ),
                                  SizedBox(width: 20),
                                  Text(
                                    "${selectedDate.toLocal()}".split(' ')[0],
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.06,
                              alignment: Alignment.center,
                              child: Text("Total: ${model.totalPickup.toString()}"),
                            ),
                            _colorItems(model.countGreen, model.countRed, model.countOther),
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
                              child: Text("Pick Up"),
                            ),
                            _releaseItemss(model.countPickupByUps, model.countPickupBySkl, model.countPickupByL),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.06,
                              alignment: Alignment.center,
                              child: DottedLine(
                                lineThickness: 2,
                                dashLength: 3,
                              ),
                            ),
                            _countStatusText("เจอของ", model.scannedPickup, 6),
                            _countStatusText("ของพร้อมปล่อย", model.pendingReleasePickup, 6),
                            _countStatusText("ปล่อยของ", model.releasePickup, 6),
                            _countStatusText("พบปัญหา", model.problemPickup, 6),
                            _countStatusText("อื้นๆ", model.otherPickup, 6),
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

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  Widget _countStatusText(String title, int count, int maxCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "$title (",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "$count",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "/ $maxCount)",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
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
              ),
            ),
            Text(
              ": $green",
              style: TextStyle(
                fontWeight: FontWeight.bold,
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
              ),
            ),
            Text(
              ": $red",
              style: TextStyle(
                fontWeight: FontWeight.bold,
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
              ),
            ),
            Text(
              ": $other",
              style: TextStyle(
                fontWeight: FontWeight.bold,
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
              ),
            ),
            Text(
              ": $ups",
              style: TextStyle(
                fontWeight: FontWeight.bold,
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
              ),
            ),
            Text(
              ": $skl",
              style: TextStyle(
                fontWeight: FontWeight.bold,
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
              ),
            ),
            Text(
              ": $l",
              style: TextStyle(
                fontWeight: FontWeight.bold,
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
          Navigator.pushNamed(context, "/scanFindItems",
              // arguments: {"datePick": "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}"});
              arguments: {"datePick": "2024-12-05"});
        },
        child: Text("สแกนหาของ"),
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
          Navigator.pushNamed(context, "/scanAndRelease",
              arguments: {"datePick": "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}"});
        },
        child: Text("สแกนพร้อมปล่อยของ"),
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
          Navigator.pushNamed(context, "/releaseItems",
              arguments: {"datePick": "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}"});
        },
        child: Text("ปล่อยของ"),
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
    String date = "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
    context.read<HomeBloc>().add(HomeLoadingEvent(date: date));
  }
}
