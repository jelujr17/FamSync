// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class Eventos {
  final int Id;
  final String Nombre;
  final String Descripcion;
  final String FechaInicio;
  final String FechaFin;
  final int IdUsuarioCreador;
  final int IdPerfilCreador;
  final int? IdCategoria;
  final List<int> Participantes;
  final int? IdTarea;

  Eventos({
    required this.Id,
    required this.Nombre,
    required this.Descripcion,
    required this.FechaInicio,
    required this.FechaFin,
    required this.IdUsuarioCreador,
    required this.IdPerfilCreador,
    required this.IdCategoria,
    required this.Participantes,
    required this.IdTarea,
  });
}

class ServicioEventos {
  // Datos estáticos para simular respuestas de la API
  final List<Eventos> _eventosEstaticos = [
    Eventos(
      Id: 1,
      Nombre: "Cena familiar",
      Descripcion: "Cena familiar de fin de semana",
      FechaInicio: "2025-05-30T19:00:00",
      FechaFin: "2025-05-30T22:00:00",
      IdUsuarioCreador: 1,
      IdPerfilCreador: 1,
      IdCategoria: 4, // Eventos familiares
      Participantes: [1, 2, 3],
      IdTarea: 3,
    ),
    Eventos(
      Id: 2,
      Nombre: "Consulta médica",
      Descripcion: "Revisión anual con el pediatra",
      FechaInicio: "2025-06-05T10:00:00",
      FechaFin: "2025-06-05T11:00:00",
      IdUsuarioCreador: 1,
      IdPerfilCreador: 1,
      IdCategoria: 5, // Citas médicas
      Participantes: [1, 2],
      IdTarea: null,
    ),
    Eventos(
      Id: 3,
      Nombre: "Fiesta de cumpleaños",
      Descripcion: "Celebración de cumpleaños en casa",
      FechaInicio: "2025-06-15T16:00:00",
      FechaFin: "2025-06-15T20:00:00",
      IdUsuarioCreador: 1,
      IdPerfilCreador: 2,
      IdCategoria: 4, // Eventos familiares
      Participantes: [1, 2, 3, 4],
      IdTarea: null,
    ),
    Eventos(
      Id: 4,
      Nombre: "Reunión de trabajo",
      Descripcion: "Presentación del proyecto trimestral",
      FechaInicio: "2025-05-29T09:00:00",
      FechaFin: "2025-05-29T11:00:00",
      IdUsuarioCreador: 2,
      IdPerfilCreador: 3,
      IdCategoria: 9, // Personal (Usuario 2)
      Participantes: [3],
      IdTarea: null,
    ),
    Eventos(
      Id: 5,
      Nombre: "Compras semanales",
      Descripcion: "Ir al supermercado para compras de la semana",
      FechaInicio: "2025-05-28T16:00:00",
      FechaFin: "2025-05-28T18:00:00",
      IdUsuarioCreador: 1,
      IdPerfilCreador: 1,
      IdCategoria: 1, // Hogar
      Participantes: [1],
      IdTarea: 2,
    ),
  ];

  // Obtener eventos por usuario y perfil
  Future<List<Eventos>> getEventos(
      BuildContext context, int IdUsuarioCreador, int IdPerfil) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 600));

    return _eventosEstaticos
        .where((evento) =>
            evento.IdUsuarioCreador == IdUsuarioCreador &&
            evento.Participantes.contains(IdPerfil))
        .toList();
  }

  // Obtener eventos diarios
  Future<List<Eventos>> getEventosDiarios(
      BuildContext context, int IdUsuarioCreador, int IdPerfil) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 500));

    // Obtener la fecha actual para filtrar eventos de hoy
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);

    return _eventosEstaticos.where((evento) {
      // Convertir la fecha de inicio del evento a DateTime
      final fechaInicio = DateTime.parse(evento.FechaInicio);
      final fechaEvento =
          DateTime(fechaInicio.year, fechaInicio.month, fechaInicio.day);

      // Verificar si el evento es de hoy y el usuario participa
      return fechaEvento.isAtSameMomentAs(hoy) &&
          evento.IdUsuarioCreador == IdUsuarioCreador &&
          evento.Participantes.contains(IdPerfil);
    }).toList();
  }

  // Obtener evento por ID
  Future<Eventos?> getEventoById(BuildContext context, int Id) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      return _eventosEstaticos.firstWhere((evento) => evento.Id == Id);
    } catch (e) {
      return null; // Si no encuentra el evento
    }
  }

  // Registrar evento
  Future<bool> registrarEvento(
      BuildContext context,
      String Nombre,
      String Descripcion,
      String FechaInicio,
      String FechaFin,
      int IdUsuarioCreador,
      int IdPerfilCreador,
      int? IdCategoria,
      List<int> Participantes,
      int? IdTarea) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 800));

    // Simular ID generado para el nuevo evento
    final nuevoId = _eventosEstaticos.isNotEmpty
        ? _eventosEstaticos.map((e) => e.Id).reduce((a, b) => a > b ? a : b) + 1
        : 1;

    // Crear el nuevo evento
    final nuevoEvento = Eventos(
      Id: nuevoId,
      Nombre: Nombre,
      Descripcion: Descripcion,
      FechaInicio: FechaInicio,
      FechaFin: FechaFin,
      IdUsuarioCreador: IdUsuarioCreador,
      IdPerfilCreador: IdPerfilCreador,
      IdCategoria: IdCategoria,
      Participantes: Participantes,
      IdTarea: IdTarea,
    );

    // Añadir el evento a la lista estática
    _eventosEstaticos.add(nuevoEvento);

    print('Evento registrado con ID: $nuevoId');
    return true;
  }

  // Actualizar evento
  Future<bool> actualizarEvento(
      BuildContext context,
      int Id,
      String Nombre,
      String Descripcion,
      String FechaInicio,
      String FechaFin,
      int IdUsuarioCreador,
      int IdPerfilCreador,
      int? IdCategoria,
      List<int> Participantes,
      int? IdTarea) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 700));

    // Buscar índice del evento a actualizar
    final index = _eventosEstaticos.indexWhere((e) => e.Id == Id);
    if (index == -1) {
      return false; // No se encontró el evento
    }

    // Crear el evento actualizado
    final eventoActualizado = Eventos(
      Id: Id,
      Nombre: Nombre,
      Descripcion: Descripcion,
      FechaInicio: FechaInicio,
      FechaFin: FechaFin,
      IdUsuarioCreador: IdUsuarioCreador,
      IdPerfilCreador: IdPerfilCreador,
      IdCategoria: IdCategoria,
      Participantes: Participantes,
      IdTarea: IdTarea,
    );

    // Actualizar el evento en la lista estática
    _eventosEstaticos[index] = eventoActualizado;

    print('Evento con ID $Id actualizado');
    return true;
  }

  // Eliminar evento
  Future<bool> eliminarEvento(BuildContext context, int idEvento) async {
    // Simular retardo de red
    await Future.delayed(const Duration(milliseconds: 400));

    // Buscar índice del evento a eliminar
    final index = _eventosEstaticos.indexWhere((e) => e.Id == idEvento);
    if (index == -1) {
      return false; // No se encontró el evento
    }

    // Eliminar el evento de la lista estática
    _eventosEstaticos.removeAt(index);

    print('Evento con ID $idEvento eliminado');
    return true;
  }
}

// Servicio global para manejar errores de conexión (versión simulada)
class HttpService {
  static Future<http.Response> execute(
    BuildContext context,
    Future<http.Response> Function() httpCall,
  ) async {
    try {
      // Simular una respuesta HTTP exitosa
      final headers = {'content-type': 'application/json'};
      final body = utf8.encode(json.encode({'status': 'success'}));

      return http.Response.bytes(body, 200, headers: headers);
    } catch (e) {
      print('Error simulado en HttpService: $e');
      // Comentado para evitar navegación no deseada durante pruebas
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => const NoconnectionScreen()),
      // );
      throw Exception('Error simulado en la conexión con la base de datos');
    }
  }
}
