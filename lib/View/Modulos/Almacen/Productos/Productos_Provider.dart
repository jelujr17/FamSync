import 'package:famsync/Model/Almacen/producto.dart';
import 'package:flutter/material.dart';

class ProductosProvider extends ChangeNotifier {
  List<Productos> _productos = []; // Lista para almacenar productos
  List<Productos> get productos => _productos;

  // Cargar productos con los dos parámetros
  Future<void> cargarProductos(int idUsuarioCreador, int idPerfil) async {
    try {
      // Aquí llamas al servicio de API con los parámetros correspondientes
      final List<Productos> productosObtenidos =
          await ServicioProductos().getProductos(idUsuarioCreador, idPerfil);

      _productos = productosObtenidos; // Guardamos los productos en memoria
      notifyListeners(); // Notificamos a todos los widgets escuchando este Provider
    } catch (error) {
      // Manejo de errores si ocurre algún problema en la carga de productos
      print("Error al cargar productos: $error");
    }
  }

  // Métodos para actualizar productos pueden ir aquí más adelante
}
