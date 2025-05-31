import 'package:famsync/Model/Tareas.dart';
import 'package:flutter/material.dart';

class TareasProvider with ChangeNotifier {
  List<Tareas> _tareas = [];

  List<Tareas> get tareas => _tareas;

  Future<void> cargarTareas(String UID, String PerfilID) async {
    try {
      _tareas = await ServicioTareas().getTareas(UID, PerfilID);
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

  void eliminarTarea(String id) {
    _tareas.removeWhere((tarea) => tarea.TareaID == id);
    notifyListeners();
  }

  void actualizarTarea(Tareas tarea) {
    final index = _tareas.indexWhere((t) => t.TareaID == tarea.TareaID);
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
        return tareas.where((tarea) => tarea.EventoID != null).length;
      case "Por hacer":
        return tareas.where((tarea) => tarea.progreso == 0).length;
      case "Completadas":
        return tareas.where((tarea) => tarea.progreso == 100).length;
      case "Urgentes":
        return tareas.where((tarea) => tarea.prioridad == 3).length;
      case "En proceso":
        return tareas
            .where((tarea) => tarea.progreso > 0 && tarea.progreso < 100)
            .length;
      default:
        return 0;
    }
  }
}
