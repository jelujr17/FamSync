import 'package:famsync/Model/Almacen/Tiendas.dart';
import 'package:flutter/material.dart';

class TiendasProvider with ChangeNotifier {
  List<Tiendas> _tiendas = [];

  List<Tiendas> get tiendas => _tiendas;

  Future<void> cargarTiendas(String UID, String PerfilID) async {
    try {
      _tiendas = await ServiciosTiendas().getTiendas(UID);
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

  void eliminarProducto(String id) {
    _tiendas.removeWhere((tienda) => tienda.TiendaID == id);
    notifyListeners();
  }

  void actualizarProducto(Tiendas tienda) {
    final index = _tiendas.indexWhere((t) => t.TiendaID == tienda.TiendaID);
    if (index != -1) {
      _tiendas[index] = tienda;
      notifyListeners();
    }
  }
}
