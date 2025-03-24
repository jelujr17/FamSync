import 'package:famsync/Model/categorias.dart';
import 'package:flutter/material.dart';

class CategoriasProvider with ChangeNotifier {
  List<Categorias> _categorias = [];

  List<Categorias> get categorias => _categorias;

  Future<void> cargarCategorias(int usuarioId, int moduloId) async {
    try {
      _categorias = await ServiciosCategorias().getCategoriasByModulo(usuarioId, moduloId);
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

  void eliinarCategoria(int id) {
    _categorias.removeWhere((categoria) => categoria.Id == id);
    notifyListeners();
  }

  void actualizarCategoria(Categorias categoria) {
    final index = _categorias.indexWhere((c) => c.Id == categoria.Id);
    if (index != -1) {
      _categorias[index] = categoria;
      notifyListeners();
    }
  }
}
