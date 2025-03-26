import 'package:famsync/Model/Almacen/tiendas.dart';
import 'package:flutter/material.dart';

class TiendasProvider with ChangeNotifier {
  List<Tiendas> _tiendas = [];

  List<Tiendas> get tiendas => _tiendas;

  Future<void> cargarTiendas(BuildContext context, int usuarioId, int perfilId) async {
    try {
      _tiendas = await ServiciosTiendas().getTiendas(context, usuarioId);
      print("Tiendas cargados: ${_tiendas.length}");
      notifyListeners();
    } catch (e) {
      print("Error al cargar tiendas: $e");
      _tiendas = [];
      notifyListeners();
    }
  }

  void agregarProducto(Tiendas tienda) {
    _tiendas.add(tienda);
    notifyListeners();
  }

  void eliminarProducto(int id) {
    _tiendas.removeWhere((tienda) => tienda.Id == id);
    notifyListeners();
  }

  void actualizarProducto(Tiendas tienda) {
    final index = _tiendas.indexWhere((t) => t.Id == tienda.Id);
    if (index != -1) {
      _tiendas[index] = tienda;
      notifyListeners();
    }
  }
}
