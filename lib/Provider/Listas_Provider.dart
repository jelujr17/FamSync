import 'package:flutter/material.dart';
import 'package:famsync/Model/Almacen/listas.dart';

class ListasProvider with ChangeNotifier {
  List<Listas> _listas = [];

  List<Listas> get listas => _listas;

  Future<void> cargarListas(BuildContext context, int usuarioId, int perfilId) async {
    try {
      _listas = await ServiciosListas().getListas(context, usuarioId, perfilId);
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

  void eliminarLista(int id) {
    _listas.removeWhere((lista) => lista.Id == id);
    notifyListeners();
  }

  void actualizarLista(Listas lista) {
    final index = _listas.indexWhere((l) => l.Id == lista.Id);
    if (index != -1) {
      _listas[index] = lista;
      notifyListeners();
    }
  }
}
