import 'dart:io';
import 'package:famsync/Model/Categorias.dart';
import 'package:famsync/Model/Perfiles.dart';
import 'package:famsync/Model/Tareas.dart';
import 'package:famsync/Provider/Perfiles_Provider.dart';
import 'package:famsync/Provider/Categorias_Provider.dart';
import 'package:famsync/components/colores.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartaTareaEvento extends StatefulWidget {
  final Perfiles perfil;
  final int orden;
  final Tareas tarea;

  const CartaTareaEvento({
    super.key,
    required this.perfil,
    required this.orden,
    required this.tarea,
  });

  @override
  State<CartaTareaEvento> createState() => CartaTareaEentoState();
}

class CartaTareaEentoState extends State<CartaTareaEvento> {
  List<Perfiles> perfilesDestinatarios = [];
  List<File> avatares = [];
  late Categorias categoria = Categorias(
      CategoriaID: "0",
      Color: widget.orden.isEven ? "FFDB89" : "030303",
      nombre: "Sin categoría",
      PerfilID: "0");
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final perfilesProvider =
          Provider.of<PerfilesProvider>(context, listen: false);
      final categoriasProvider =
          Provider.of<CategoriasProvider>(context, listen: false);
      // Cargar perfiles
      await perfilesProvider.cargarPerfiles(user!.uid);
      // Cargar categorías
      await categoriasProvider.cargarCategorias(
          user!.uid, widget.perfil.PerfilID);

      // Llamar a obtenerAvatares después de cargar los perfiles
      obtenerAvatares();
      obtenerCategoria();
    });
  }

  Future<String?> obtenerCategoriaNombre() async {
    try {
      final categoriasProvider =
          Provider.of<CategoriasProvider>(context, listen: false);
      final categoria = categoriasProvider.categorias
          .firstWhere((cat) => cat.CategoriaID == widget.tarea.CategoriaID);
      return categoria.nombre;
    } catch (e) {
      print("Error al obtener la categoría: $e");
      return null;
    }
  }

  void obtenerCategoria() async {
    try {
      final categoriasProvider =
          Provider.of<CategoriasProvider>(context, listen: false);
      categoria = categoriasProvider.categorias
          .firstWhere((cat) => cat.CategoriaID == widget.tarea.CategoriaID);
      print("Categoría obtenida: ${categoria.nombre}");
    } catch (e) {
      categoria = Categorias(
        CategoriaID: "0",
        Color: widget.orden.isEven ? "FFDB89" : "030303",
        nombre: "Sin categoría",
        PerfilID: "0",
      );
      print("Error al obtener la categoría: $e");
    }
  }

  void obtenerAvatares() async {
    try {
      final perfilesProvider =
          Provider.of<PerfilesProvider>(context, listen: false);

      // Filtrar los perfiles destinatarios
      perfilesDestinatarios = perfilesProvider.perfiles
          .where(
              (perfil) => widget.tarea.destinatario.contains(perfil.PerfilID))
          .toList();

      print(
          "Perfiles destinatarios: ${perfilesDestinatarios.map((p) => p.PerfilID)}");

      // Cargar las imágenes de los perfiles
      final imagenesCargadas = await Future.wait(
        perfilesDestinatarios.map(
          (perfil) async {
            try {
              final imagen = await ServicioPerfiles()
                  .getFotoPerfil(user!.uid, perfil.FotoPerfil);
              print("Imagen cargada para perfil ${perfil.PerfilID}: $imagen");
              return imagen;
            } catch (e) {
              print(
                  "Error al cargar imagen para perfil ${perfil.PerfilID}: $e");
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

  Color getContrastingTextColor(Color color) {
    // Calcula el brillo del color
    final double brightness =
        (color.red * 0.299 + color.green * 0.587 + color.blue * 0.114) / 255;

    // Si el brillo es alto, usa un color oscuro; de lo contrario, usa un color claro
    return brightness > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8), // Espaciado externo
      decoration: BoxDecoration(
        color: widget.orden.isEven ? Colores.fondoAux : Colores.texto,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: widget.orden.isEven
                ? Colores.texto.withOpacity(0.5)
                : Colores.fondoAux.withOpacity(0.5),
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
                  widget.tarea.nombre,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.orden.isEven ? Colores.texto : Colores.fondo,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // prioridad
          Container(
            constraints: const BoxConstraints(
                minWidth: 150), // Ancho mínimo para consistencia
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: widget.tarea.prioridad == 1 || widget.tarea.progreso == 100
                  ? Colores.hecho.withOpacity(0.2)
                  : widget.tarea.prioridad == 2
                      ? Colores.naranja.withOpacity(0.2)
                      : Colores.eliminar.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.orden.isEven ? Colores.texto : Colores.fondoAux,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.tarea.progreso == 100
                      ? Icons.check_circle
                      : widget.tarea.prioridad == 1
                          ? Icons.start
                          : widget.tarea.prioridad == 2
                              ? Icons.warning
                              : Icons.error,
                  color: widget.tarea.prioridad == 1 ||
                          widget.tarea.progreso == 100
                      ? Colores.hecho
                      : widget.tarea.prioridad == 2
                          ? Colores.naranja
                          : Colores.eliminar,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.tarea.progreso == 100
                      ? 'Tarea Completada'
                      : widget.tarea.prioridad == 1
                          ? 'Baja'
                          : widget.tarea.prioridad == 2
                              ? 'Media'
                              : 'Alta',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: widget.tarea.prioridad == 1 ||
                            widget.tarea.progreso == 100
                        ? Colores.hecho
                        : widget.tarea.prioridad == 2
                            ? Colores.naranja
                            : Colores.eliminar,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Avatares y categoría
          Row(
            children: [
              // Avatares
              if (avatares.isNotEmpty)
                Row(
                  children: perfilesDestinatarios.map((perfil) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: FileImage(
                              avatares[perfilesDestinatarios.indexOf(perfil)],
                            ),
                            onBackgroundImageError: (_, __) {
                              print("Error al cargar la imagen del avatar");
                            },
                          ),
                          const SizedBox(
                              height:
                                  4), // Espaciado entre el avatar y el nombre
                          Text(
                            perfil.nombre, // Muestra el nombre del perfil
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.orden.isEven
                                  ? Colores.texto
                                  : Colores.fondo,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )
              else
                Row(
                  children: List.generate(
                    widget.tarea.destinatario.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colores.fondo,
                            child: Icon(
                              Icons.person,
                              color: widget.orden.isEven
                                  ? Colores.texto
                                  : Colores.fondo,
                              size: 16,
                            ),
                          ),
                          const SizedBox(
                              height:
                                  4), // Espaciado entre el avatar y el texto
                          Text(
                            "Usuario ${index + 1}", // Texto genérico si no hay avatar
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.orden.isEven
                                  ? Colores.texto
                                  : Colores.fondo,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Espaciador para empujar la categoría hacia la mitad horizontal
              Spacer(),

              // Categoría
              Container(
                constraints: const BoxConstraints(
                    minWidth: 150), // Ancho mínimo para consistencia
                child: FutureBuilder(
                  future: obtenerCategoriaNombre(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text(
                        'Cargando categoría...',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      );
                    } else if (snapshot.hasError) {
                      return const Text(
                        'Error al cargar categoría',
                        style: TextStyle(fontSize: 14, color: Colors.red),
                      );
                    } else {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Color(int.parse("0xFF${categoria.Color}"))
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: widget.orden.isEven
                                ? Colores.texto.withOpacity(0.5)
                                : Colores.fondoAux.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          snapshot.data ?? categoria.nombre,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: widget.orden.isEven
                                ? Colores.texto
                                : Colores.fondoAux,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Barra de progreso
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: widget.tarea.progreso / 100,
                  backgroundColor: Colores.fondo,
                  color: widget.orden.isEven ? Colores.texto : Colores.fondoAux,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "${widget.tarea.progreso}%",
                style: TextStyle(
                  fontSize: 14,
                  color: widget.orden.isEven ? Colores.texto : Colores.fondo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Descripción
          Text(
            "Descripción: ${widget.tarea.descripcion}",
            style: TextStyle(
              fontSize: 14,
              color: widget.orden.isEven ? Colores.texto : Colores.fondo,
            ),
          ),
        ],
      ),
    );
  }
}
