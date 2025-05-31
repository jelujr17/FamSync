import 'package:famsync/Model/Categorias.dart';
import 'package:flutter/material.dart';

class CategoriasProvider with ChangeNotifier {
  List<Categorias> _categorias = [];

  List<Categorias> get categorias => _categorias;

  Future<void> cargarCategorias(String UID, String PerfilID) async {
    try {
      _categorias = await ServiciosCategorias().getCategorias(UID, PerfilID);
      print("Categorias cargados: ${_categorias.length}");
      notifyListeners();
    } catch (e) {
      print("Error al cargar categorias: $e");
      _categorias = [];
      notifyListeners();
    }
  }

  void agregarCategoria(Categorias categoria) {
    _categorias.add(categoria);
    notifyListeners();
  }

  void eliinarCategoria(String id) {
    _categorias.removeWhere((categoria) => categoria.CategoriaID == id);
    notifyListeners();
  }

  void actualizarCategoria(Categorias categoria) {
    final index =
        _categorias.indexWhere((c) => c.CategoriaID == categoria.CategoriaID);
    if (index != -1) {
      _categorias[index] = categoria;
      notifyListeners();
    }
  }
}
