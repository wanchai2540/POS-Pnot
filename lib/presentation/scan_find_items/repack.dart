// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:kymscanner/common.dart';
// import 'package:kymscanner/data/api/api.dart';
// import 'package:kymscanner/presentation/scan_find_items/bloc/scan_find_items_page_bloc.dart';

// class RepackPage extends StatefulWidget {
//   const RepackPage({super.key});

//   @override
//   State<RepackPage> createState() => _RepackPageState();
// }

// class _RepackPageState extends State<RepackPage> {
//   Map<String, dynamic> result = {};
//   List<DropdownMenuEntry<String>> reasonList = [];
//   final ValueNotifier<File?> _imageRepack = ValueNotifier<File?>(null);
//   String uuid = "";
//   String datePicked = "";
//   bool _isProcessing = false;
//   String _problemCode = "08";

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();

//     final args = ModalRoute.of(context)?.settings.arguments as Map;
//     uuid = args["uuid"];
//     datePicked = args["datePicked"];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color(0xFFF5ECD5),
//         title: Text("ยืนยันการ Repack"),
//       ),
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(height: 20),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       RichText(
//                         text: TextSpan(
//                           text: 'สาเหตุ',
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 20,
//                           ),
//                           children: [
//                             TextSpan(
//                               text: ' *',
//                               style: TextStyle(
//                                 color: Colors.red,
//                                 fontSize: 20,
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 15),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text("ยินยันการ Repack"),
//                         ],
//                       ),
//                       SizedBox(
//                         height: 30,
//                       ),
//                       ValueListenableBuilder<File?>(
//                         valueListenable: _imageRepack,
//                         builder: (context, capturedImage, child) {
//                           return Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               capturedImage == null
//                                   ? SizedBox()
//                                   : Center(
//                                       child: Image.file(
//                                         capturedImage,
//                                         height: 200,
//                                         width: 200,
//                                         fit: BoxFit.cover,
//                                       ),
//                                     ),
//                             ],
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       TextButton(
//                         child: const Text('ถ่ายรูป', style: TextStyle(fontSize: 18)),
//                         onPressed: () async {
//                           final ImagePicker picker = ImagePicker();
//                           final XFile? image = await picker.pickImage(
//                             source: ImageSource.camera,
//                             maxWidth: 1080,
//                             maxHeight: 1080,
//                             imageQuality: 100,
//                           );
//                           if (image != null) {
//                             setState(() {
//                               _imageRepack.value = File(image.path);
//                             });
//                           }
//                         },
//                       ),
//                       Row(children: [
//                         TextButton(
//                           child: const Text('ยกเลิก', style: TextStyle(fontSize: 18)),
//                           onPressed: () {
//                             setState(() {
//                               _imageRepack.value = null;
//                             });
//                             context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked));
//                             Navigator.of(context).pop();
//                           },
//                         ),
//                         TextButton(
//                           child: const Text('ยืนยัน', style: TextStyle(fontSize: 18)),
//                           onPressed: () async {
//                             if (_imageRepack.value != null) {
//                               try {
//                                 setState(() {
//                                   _isProcessing = true;
//                                 });
//                                 await DataService().sendRepack(uuid, datePicked, _imageRepack.value!).then((res) {
//                                   if (res == "success") {
//                                     setState(() {
//                                       _imageRepack.value = null;
//                                     });
//                                     DialogScan().snackBarUtil(context, 'แจ้งการ Repack สำเร็จ');
//                                     context.read<ScanFindItemsPageBloc>().add(ScanPageGetDataEvent(date: datePicked));
//                                     Navigator.of(context).pop();
//                                   } else {
//                                     DialogScan().snackBarUtil(context, 'แจ้งการ Repack ไม่สำเร็จ กรุณาลองใหม่อีกครั้ง');
//                                   }
//                                 });
//                               } catch (e) {
//                                 DialogScan().snackBarUtil(context, 'เกิดข้อผิดพลาด: ${e.toString()}');
//                               } finally {
//                                 setState(() {
//                                   _isProcessing = false;
//                                 });
//                               }
//                             } else {
//                               DialogScan().snackBarUtil(context, 'กรุณาถ่ายรูปเพื่อเปลี่ยนสถานะเป็น Repack');
//                             }
//                           },
//                         ),
//                       ])
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           ),
//           if (_isProcessing)
//             Container(
//               color: Colors.black.withOpacity(0.5),
//               child: Center(
//                 child: CircularProgressIndicator(),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
