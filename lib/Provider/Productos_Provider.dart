import 'package:flutter/material.dart';
import 'package:famsync/Model/Almacen/producto.dart';

class ProductosProvider with ChangeNotifier {
  List<Productos> _productos = [];

  List<Productos> get productos => _productos;

  Future<void> cargarProductos(int usuarioId, int perfilId) async {
    try {
      _productos = await ServicioProductos().getProductos(usuarioId, perfilId);
      print("Productos cargados: ${_productos.length}");
      notifyListeners();
    } catch (e) {
      print("Error al cargar productos: $e");
      _productos = [];
      notifyListeners();
    }
  }

  void agregarProducto(Productos producto) {
    _productos.add(producto);
    notifyListeners();
  }

  void eliminarProducto(int id) {
    _productos.removeWhere((producto) => producto.Id == id);
    notifyListeners();
  }

  void actualizarProducto(Productos producto) {
    final index = _productos.indexWhere((p) => p.Id == producto.Id);
    if (index != -1) {
      _productos[index] = producto;
      notifyListeners();
    }
  }
}
