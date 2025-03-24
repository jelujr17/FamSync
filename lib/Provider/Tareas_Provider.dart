import 'package:famsync/Model/tareas.dart';
import 'package:flutter/material.dart';

class TareasProvider with ChangeNotifier {
  List<Tareas> _tareas = [];

  List<Tareas> get tareas => _tareas;

  Future<void> cargarTareas(int usuarioId, int perfilId) async {
    try {
      _tareas = await ServicioTareas().getTareas(perfilId);
      print("Tareas cargadas: ${_tareas.length}");
      notifyListeners();
    } catch (e) {
      print("Error al cargar las tareas: $e");
      _tareas = [];
      notifyListeners();
    }
  }

  void agragarTarea(Tareas tarea) {
    _tareas.add(tarea);
    notifyListeners();
  }

  void eliminarTarea(int id) {
    _tareas.removeWhere((tarea) => tarea.Id == id);
    notifyListeners();
  }

  void actualizarTarea(Tareas tarea) {
    final index = _tareas.indexWhere((t) => t.Id == tarea.Id);
    if (index != -1) {
      _tareas[index] = tarea;
      notifyListeners();
    }
  }
}
