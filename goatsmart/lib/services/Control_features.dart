import 'package:flutter/services.dart';

class ConnectionManager {
  static const platform = const MethodChannel('connection_manager');

  Future<String> getConnectionType() async {
    String connectionType = '';
    try {
      connectionType = await platform.invokeMethod('getConnectionType');
    } on PlatformException catch (e) {
      connectionType = "Error: ${e.message}";
    }
    return connectionType;
  }

  Future<bool> isInternetConnected() async {
    bool isConnected = false;
    try {
      isConnected = await platform.invokeMethod('isInternetConnected');
    } on PlatformException catch (e) {
      isConnected = false;
    }
    return isConnected;
  }

  Future<int> getBatteryLevel() async {
    int batteryLevel = 0;
    try {
      batteryLevel = await platform.invokeMethod('getBatteryLevel');
    } on PlatformException catch (e) {
      batteryLevel = -1;
    }
    return batteryLevel;
  }
}