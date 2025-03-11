import 'package:famsync/Model/perfiles.dart';
import 'package:flutter/material.dart';

class PerfilesProvider with ChangeNotifier {
  List<Perfiles> _perfiles = [];

  List<Perfiles> get perfiles => _perfiles;

  Future<void> cargarPerfiles(int usuarioId) async {
    try {
      _perfiles = await ServicioPerfiles().getPerfiles(usuarioId);
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

  void eliminarPerfil(int id) {
    _perfiles.removeWhere((perfil) => perfil.Id == id);
    notifyListeners();
  }

  void actualizarPerfiles(Perfiles perfil) {
    final index = _perfiles.indexWhere((p) => p.Id == perfil.Id);
    if (index != -1) {
      _perfiles[index] = perfil;
      notifyListeners();
    }
  }
}
