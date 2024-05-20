import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

class LocationPage extends StatefulWidget {
  const LocationPage({Key? key}) : super(key: key);

  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  // Define las coordenadas del centro del área y el radio en metros
  final double areaLat = 4.6016587360175505; // Latitud del centro del área
  final double areaLon = -74.06551340589863; // Longitud del centro del área
  final double areaRadius = 300; // Radio del área en metros (ejemplo: 1000 metros = 1 kilómetro)

  // Función para calcular la distancia entre dos puntos en una esfera (fórmula de Haversine)
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // Radio de la Tierra en metros
    double dLat = radians(lat2 - lat1);
    double dLon = radians(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(radians(lat1)) * cos(radians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;
    return distance;
  }

  // Función para convertir grados a radianes
  double radians(double degrees) {
    return degrees * pi / 180;
  }

  // Función para verificar si el usuario está dentro del área
  bool isUserInsideArea(double userLat, double userLon) {
    double distance = calculateDistance(areaLat, areaLon, userLat, userLon);
    return distance <= areaRadius;
  }

  Future<Position> determinePosition() async{
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied){
        return Future.error('Location permissions are denied');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  void getCurrentLocation() async {
    Position position = await determinePosition();
    double userLat = position.latitude;
    double userLon = position.longitude;
    if (isUserInsideArea(userLat, userLon)) {
      // El usuario está dentro del área
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Mensaje'),
            content: const Text('¡Estás dentro del área!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      );
    } else {
      // El usuario está fuera del área
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Importante'),
            content: const Text('¡Estás dentro de un área de Intercambio!'),
            backgroundColor: Colors.white,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      );
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Location'),
    ),
    backgroundColor: Colors.white,
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 230.0),
            child: Text(
              'Verifica si estás en una zona de Intercambio',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 350.0), // Ajusta la posición vertical del botón
            child: ElevatedButton(
              onPressed: getCurrentLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 180, 68),
              ),
              child: const Text(
                'Obtener Ubicación',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


}