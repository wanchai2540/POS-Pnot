import 'package:flutter/services.dart';

class CustomButtonListener {
  static const MethodChannel _channel = MethodChannel('hardware_button_channel');
  static Function(String? event)? onButtonPressed;

  /// Initialize the listener
  static void initialize() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onBarcodeScanned') {
        final scannedData = call.arguments as String?;
        onButtonPressed?.call(scannedData.toString());
      }
    });
  }

  /// Dispose the listener
  static void dispose() {
    // Remove the method call handler
    _channel.setMethodCallHandler(null);
    onButtonPressed = null; // Clear the callback
  }
}
