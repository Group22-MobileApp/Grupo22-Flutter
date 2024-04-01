import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  //Instancia
  static late SharedPreferences _prefs;

  // Inicializar las preferencias
  static Future init() async{
      _prefs = await SharedPreferences.getInstance();
  }

  String get lastPage {
    return _prefs.getString('lastPage') ?? 'HomePage';
  }

  set lastPage(String value) {
    _prefs.setString('lastPage', value);
  }
  
}