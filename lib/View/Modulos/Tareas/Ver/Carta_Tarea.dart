import 'dart:io';

import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/Provider/Perfiles_Provider.dart';
import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartaTarea extends StatefulWidget {
  final String titulo, descripcion;
  final int prioridad, progreso;
  final List<int> destinatarios;
  final Perfiles perfil;
  final int orden;

  const CartaTarea({
    super.key,
    required this.titulo,
    required this.prioridad,
    required this.progreso,
    required this.descripcion,
    required this.destinatarios,
    required this.perfil,
    required this.orden,
  });

  @override
  State<CartaTarea> createState() => CartaTareaState();
}

class CartaTareaState extends State<CartaTarea> {
  List<Perfiles> perfilesDestinatarios = [];
  List<File> avatares = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final perfilesProvider =
          Provider.of<PerfilesProvider>(context, listen: false);

      // Cargar perfiles
      await perfilesProvider.cargarPerfiles(widget.perfil.UsuarioId);

      // Llamar a obtenerAvatares después de cargar los perfiles
      obtenerAvatares();
    });
  }

  void obtenerAvatares() async {
    try {
      final perfilesProvider =
          Provider.of<PerfilesProvider>(context, listen: false);

      // Filtrar los perfiles destinatarios
      perfilesDestinatarios = perfilesProvider.perfiles
          .where((perfil) => widget.destinatarios.contains(perfil.Id))
          .toList();

      print(
          "Perfiles destinatarios: ${perfilesDestinatarios.map((p) => p.Id)}");

      // Cargar las imágenes de los perfiles
      final imagenesCargadas = await Future.wait(
        perfilesDestinatarios.map(
          (perfil) async {
            try {
              final imagen =
                  await ServicioPerfiles().obtenerImagen(perfil.FotoPerfil);
              print("Imagen cargada para perfil ${perfil.Id}: $imagen");
              return imagen;
            } catch (e) {
              print("Error al cargar imagen para perfil ${perfil.Id}: $e");
              return null; // Devuelve null si falla
            }
          },
        ),
      );

      if (mounted) {
        setState(() {
          avatares =
              imagenesCargadas.whereType<File>().toList(); // Filtra los nulos
        });
      }
    } catch (e) {
      print('Error al cargar avatares: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8), // Espaciado externo
      decoration: BoxDecoration(
        color: widget.orden.isEven ? Colores.negro : Colores.amarillo,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: widget.orden.isEven
                ? Colores.amarillo.withOpacity(0.5)
                : Colores.negro.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título e ícono de opciones
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.titulo,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.orden.isEven
                        ? Colores.amarillo
                        : Colores.grisOscuro,
                  ),
                ),
              ),
              Icon(
                Icons.more_vert,
                color:
                    widget.orden.isEven ? Colores.amarillo : Colores.grisOscuro,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Prioridad
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color:
                    widget.orden.isEven ? Colores.amarillo : Colores.grisOscuro,
              ),
              const SizedBox(width: 4),
              Text(
                widget.prioridad.toString(),
                style: TextStyle(
                  color: widget.orden.isEven
                      ? Colores.amarillo
                      : Colores.grisOscuro,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Avatares
          Row(
            children: avatares.isNotEmpty
                ? avatares.map((avatar) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundImage: FileImage(avatar),
                        onBackgroundImageError: (_, __) {
                          print("Error al cargar la imagen del avatar");
                        },
                      ),
                    );
                  }).toList()
                : List.generate(
                    widget.destinatarios.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colores.grisOscuro,
                        child: Icon(
                          Icons.person,
                          color: widget.orden.isEven
                              ? Colores.amarillo
                              : Colores.grisOscuro,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 16),

          // Barra de progreso
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: widget.progreso / 100,
                  backgroundColor: Colors.grey.shade300,
                  color: widget.orden.isEven
                      ? Colores.amarillo
                      : Colores.grisOscuro,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "${widget.progreso}%",
                style: TextStyle(
                  fontSize: 14,
                  color: widget.orden.isEven
                      ? Colores.amarillo
                      : Colores.grisOscuro,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Descripción
          Text(
            widget.descripcion,
            style: TextStyle(
              fontSize: 14,
              color:
                  widget.orden.isEven ? Colores.amarillo : Colores.grisOscuro,
            ),
          ),
        ],
      ),
    );
  }
}
