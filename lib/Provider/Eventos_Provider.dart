import 'package:famsync/Model/Calendario/Eventos.dart';
import 'package:flutter/material.dart';

class EventosProvider with ChangeNotifier {
  List<Eventos> _eventos = [];

  List<Eventos> get eventos => _eventos;

  Future<void> cargarEventos(String UID, String PerfilID) async {
    try {
      _eventos = await ServicioEventos().getEventos(UID, PerfilID);
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

  void eliminarEvento(String id) {
    _eventos.removeWhere((evento) => evento.EventoID == id);
    notifyListeners();
  }

  void actualizarEvento(Eventos evento) {
    final index = _eventos.indexWhere((t) => t.EventoID == evento.EventoID);
    if (index != -1) {
      _eventos[index] = evento;
      notifyListeners();
    }
  }
}
