import 'package:famsync/Model/Perfiles.dart';
import 'package:flutter/material.dart';

class PerfilesProvider with ChangeNotifier {
  List<Perfiles> _perfiles = [];

  List<Perfiles> get perfiles => _perfiles;

  Future<void> cargarPerfiles(String UID) async {
    try {
      _perfiles = await ServicioPerfiles().getPerfiles(UID);
      print("Perfiles cargados: ${_perfiles.length}");
      notifyListeners();
    } catch (e) {
      print("Error al cargar perfiles: $e");
      _perfiles = [];
      notifyListeners();
    }
  }

  void agregarPerfil(Perfiles perfil) {
    _perfiles.add(perfil);
    notifyListeners();
  }

  void eliminarPerfil(String id) {
    _perfiles.removeWhere((perfil) => perfil.PerfilID == id);
    notifyListeners();
  }

  void actualizarPerfiles(Perfiles perfil) {
    final index = _perfiles.indexWhere((p) => p.PerfilID == perfil.PerfilID);
    if (index != -1) {
      _perfiles[index] = perfil;
      notifyListeners();
    }
  }
}
