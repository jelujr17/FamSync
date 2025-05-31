import 'package:flutter/material.dart';
import 'package:famsync/Model/Almacen/Listas.dart';

class ListasProvider with ChangeNotifier {
  List<Listas> _listas = [];

  List<Listas> get listas => _listas;

  Future<void> cargarListas(String UID, String PerfilID) async {
    try {
      _listas = await ServiciosListas().getListas(UID, PerfilID);
      print("Listas cargadas: ${_listas.length}");
      notifyListeners();
    } catch (e) {
      print("Error al cargar las listas: $e");
      _listas = [];
      notifyListeners();
    }
  }

  void agregarLista(Listas lista) {
    _listas.add(lista);
    notifyListeners();
  }

  void eliminarLista(String id) {
    _listas.removeWhere((lista) => lista.ListaID == id);
    notifyListeners();
  }

  void actualizarLista(Listas lista) {
    final index = _listas.indexWhere((l) => l.ListaID == lista.ListaID);
    if (index != -1) {
      _listas[index] = lista;
      notifyListeners();
    }
  }
}
