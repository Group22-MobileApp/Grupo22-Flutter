import 'dart:js';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ConnectionManager {
  static const platform = MethodChannel('connection_manager');

  Future<String> getConnectionType() async {
    String connectionType = '';
    try {
      connectionType = await platform.invokeMethod('getConnectionType');
    } on PlatformException catch (e) {
      connectionType = "Error: ${e.message}";
    }
    return connectionType;
  }

  Future<bool> checkInternetConnection() async {
    try {
      var response = await http.get(Uri.parse('https://www.google.com'));
      if (response.statusCode == 200) {
        return true; // Hay conexión a Internet
      } else {
        print("Error de conexion a la red de internet");
        return false; // No hay conexión a Internet
      }
    } catch (e) {
      print("Error al verificar la conexión a Internet: $e");
      return false;
    }
  }

  Future<int> getBatteryLevel() async {
    int batteryLevel = 0;
    try {
      batteryLevel = await platform.invokeMethod('getBatteryLevel');
    } on PlatformException catch (e) {
      batteryLevel = -1;
      print('Error getting battery level: ${e.message}');
    }
    return batteryLevel;
  }

  //methos to call garbage collector
  Future<void> callGarbageCollector() async {
    try {
      await platform.invokeMethod('callGarbageCollector');
    } on PlatformException catch (e) {
      print('Error calling garbage collector: ${e.message}');
    }
  }

  //Method to show dialog when the battery is low
  Future<void> batteryMessage(BuildContext context) async {
    int batteryLevel = await getBatteryLevel();
    if (batteryLevel < 10) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Batería Baja! '),
            backgroundColor: Colors.white,
            content: const Text(
                'Tu batería está por agotarse, por favor conecta tu dispositivo antes de realizar tu publicación.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
