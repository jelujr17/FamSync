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

  int contarTareasPorEstado(String estado, List<Tareas> tareas) {
    switch (estado) {
      case "Todas":
        return tareas.length;
      case "Programadas":
        return tareas.where((tarea) => tarea.IdEvento != null).length;
      case "Por hacer":
        return tareas.where((tarea) => tarea.Progreso == 0).length;
      case "Completadas":
        return tareas.where((tarea) => tarea.Progreso == 100).length;
      case "Urgentes":
        return tareas.where((tarea) => tarea.Prioridad == 3).length;
      case "En proceso":
        return tareas
            .where((tarea) => tarea.Progreso < 0 && tarea.Progreso > 100)
            .length;
      default:
        return 0;
    }
  }
}
