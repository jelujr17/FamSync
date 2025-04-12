import 'package:famsync/Model/Calendario/eventos.dart';
import 'package:flutter/material.dart';

class EventosProvider with ChangeNotifier {
  List<Eventos> _eventos = [];

  List<Eventos> get eventos => _eventos;

  Future<void> cargarEventos(
      BuildContext context, int usuarioId, int perfilId) async {
    try {
      _eventos = await ServicioEventos().getEventos(context, usuarioId, perfilId);
      print("Eventos cargados: ${_eventos.length}");
      notifyListeners();
    } catch (e) {
      print("Error al cargar los eventos: $e");
      _eventos = [];
      notifyListeners();
    }
  }


  void agregarEvento(Eventos evento) {
    _eventos.add(evento);
    notifyListeners();
  }

  void eliminarEvento(int id) {
    _eventos.removeWhere((evento) => evento.Id == id);
    notifyListeners();
  }

  void actualizarEvento(Eventos evento) {
    final index = _eventos.indexWhere((t) => t.Id == evento.Id);
    if (index != -1) {
      _eventos[index] = evento;
      notifyListeners();
    }
  }

 
}
