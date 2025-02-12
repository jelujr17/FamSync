// funciones_auxiliares.dart

import 'package:shared_preferences/shared_preferences.dart';

class NexoInicio {
  // Función para añadir producto a una lista

  Future<bool> primeraVezResumen() async {
    final SharedPreferences preferencias =
        await SharedPreferences.getInstance();

    String? primeraVezResumern = preferencias.getString("PrimeraVezResumen");

    if (primeraVezResumern == null) {
      preferencias.setString("PrimeraVezResumen", DateTime.now().toString());
      return true;
    } else if (primeraVezResumern == DateTime.now().toString()) {
      preferencias.setString("PrimeraVezResumen", DateTime.now().toString());
      return true;
    }
    else {
      return false;
    }
  }
}
