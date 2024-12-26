import 'package:flutter/services.dart';

class CustomButtonListener {
  static const MethodChannel _channel = MethodChannel('hardware_button_channel');
  static Function(String? event)? onButtonPressed;

  static void initialize() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onBarcodeScanned') {
        final scannedData = call.arguments as String?;
        onButtonPressed?.call(scannedData.toString());
      }
    });
  }
}
