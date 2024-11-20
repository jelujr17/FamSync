import 'dart:io';

import 'package:famsync/Model/Calendario/eventos.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';
import 'package:intl/intl.dart'; // Para formatear fechas

class CurvedAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 20);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 20,
      size.width,
      size.height - 20,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class DetalleEventoPage extends StatefulWidget {
  final NeatCleanCalendarEvent evento;
  final Perfiles perfil;
  final Eventos eventoSeleccionado;

  const DetalleEventoPage(
      {super.key,
      required this.evento,
      required this.perfil,
      required this.eventoSeleccionado});

  @override
  _DetallesEventoState createState() => _DetallesEventoState();
}

class _DetallesEventoState extends State<DetalleEventoPage> {
  List<Perfiles> participantes = [];

  @override
  void initState() {
    super.initState();
    obtenerParticipantes();
  }

  void obtenerParticipantes() async {
    // Ejemplo: Obtén la lista desde tu API
    participantes =
        await ServicioPerfiles().getPerfiles(widget.perfil.UsuarioId);
    List<int> aux = widget.eventoSeleccionado.Participantes;
    participantes.removeWhere((participante) => !aux.contains(participante.Id));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: ClipPath(
          clipper: CurvedAppBarClipper(),
          child: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              widget.evento.summary,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colores.fondo,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 3.0,
                    color: Colores.texto,
                  ),
                ],
              ),
            ),
            centerTitle: true,
            elevation: 4,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.evento.color!,
                    Colores.botonesSecundarios,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Descripción del evento
            _buildCardSection(
              context,
              'Descripción:',
              widget.evento.description,
            ),
            const SizedBox(height: 16),

            // Fechas mejoradas
            _buildDateSection(
              context,
              'Fecha de inicio:',
              DateTime.parse(widget.eventoSeleccionado.FechaInicio),
              Icons.calendar_today,
            ),
            const SizedBox(height: 8),
            _buildDateSection(
              context,
              'Fecha de finalización:',
              DateTime.parse(widget.eventoSeleccionado.FechaFin),
              Icons.event_available,
            ),
            const SizedBox(height: 16),
            _buildParticipantesSection(
              context,
              'Participante/s:',
              participantes,
              widget.eventoSeleccionado.IdPerfilCreador,
              Icons.person,
            ),
          ],
        ),
      ),
    );
  }

  // Método para crear las secciones dentro de las tarjetas
  Widget _buildCardSection(BuildContext context, String title, String content) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.black87,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para mostrar las fechas de inicio y fin con íconos y formato mejorado
  Widget _buildDateSection(
      BuildContext context, String title, DateTime date, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colores.botones,
              size: 28,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatearFecha(date),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantesSection(BuildContext context, String title,
      List<Perfiles> participantes, int idCreador, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Row(
              children: [
                Icon(
                  icon,
                  color: Colores.botones,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Contenido de los participantes
            participantes.isEmpty
                ? const Text(
                    'No hay participantes para este evento.',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  )
                : Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0), // Desplaza a la derecha
                    child: Wrap(
                      spacing: 16.0, // Espacio horizontal entre elementos
                      runSpacing: 16.0, // Espacio vertical entre líneas
                      children: participantes.map((perfil) {
                        final bool esCreador = perfil.Id == idCreador;

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(
                                  2), // Espacio para el borde
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: esCreador
                                    ? Border.all(
                                        color:
                                            Colores.botones, // Color del borde
                                        width: 3, // Grosor del borde
                                      )
                                    : null, // Sin borde si no es el creador
                              ),
                              child: CircleAvatar(
                                radius: 25, // Ajusta el tamaño del avatar
                                backgroundImage: FileImage(
                                  File(
                                    'C:\\Users\\mario\\Documents\\Imagenes_FamSync\\Perfiles\\${perfil.FotoPerfil}',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              perfil.Nombre,
                              style: const TextStyle(fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // Formatear la fecha y hora para presentación mejorada
  String _formatearFecha(DateTime fecha) {
    final DateFormat dateFormat = DateFormat('dd MMMM yyyy, HH:mm');
    return dateFormat.format(fecha);
  }
}
