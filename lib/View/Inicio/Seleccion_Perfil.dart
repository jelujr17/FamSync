// ignore_for_file: file_names

import 'dart:io';

import 'package:famsync/View/Inicio/Home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/Inicio/Nuevo_Perfil.dart';
import 'package:famsync/components/colores.dart';

class SeleccionPerfil extends StatefulWidget {
  final int IdUsuario;

  const SeleccionPerfil({super.key, required this.IdUsuario});

  @override
  _SeleccionPerfilState createState() => _SeleccionPerfilState();
}

class _SeleccionPerfilState extends State<SeleccionPerfil> {
  List<Perfiles> perfiles = [];
  bool _editMode = false;

  @override
  void initState() {
    super.initState();
    reload();
  }

  void reload() async {
    perfiles = await ServicioPerfiles().getPerfiles(context, widget.IdUsuario);
    setState(() {});
  }

  void _toggleEditMode() {
    setState(() {
      _editMode = !_editMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colores.fondo, // Fondo blanco
      body: SafeArea(
        child: Column(
          children: [
            // Título de la aplicación
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'FamSync',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colores.texto,
                    ),
                  ),
                  if (perfiles.isNotEmpty)
                    TextButton(
                      onPressed: _toggleEditMode,
                      style: TextButton.styleFrom(
                        foregroundColor: Colores.fondoAux,
                      ),
                      child: Text(
                        _editMode ? 'Cancelar' : 'Editar',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colores.eliminar),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            // Texto "¿Quién está viendo?"
            Text(
              'Selecciona tu perfil',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colores.texto,
              ),
            ),
            const SizedBox(height: 100),
            // Grid de perfiles
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount:
                    perfiles.length + 1, // Incluye el botón "Nuevo perfil"
                itemBuilder: (context, index) {
                  if (index == perfiles.length) {
                    return _buildNuevoPerfilButton();
                  } else {
                    return _buildPerfilItem(perfiles[index]);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerfilItem(Perfiles perfil) {
    return GestureDetector(
      onTap: () {
        if (!_editMode) {
          _verificarPin(perfil);
        } else {
          // Acción de edición (puedes personalizarla)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Editar perfil: ${perfil.Nombre}')),
          );
        }
      },
      child: Column(
        children: [
          Expanded(
            child: FutureBuilder<File>(
              future:
                  ServicioPerfiles().obtenerImagen(context, perfil.FotoPerfil),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Muestra un indicador de carga mientras se obtiene la imagen
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colores.botones,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasError || !snapshot.hasData) {
                  // Muestra un fondo de color si hay un error o no hay imagen
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colores.botones,
                    ),
                    child: Center(
                      child: Text(
                        perfil.Nombre[0],
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                } else {
                  // Muestra la imagen obtenida
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: FileImage(snapshot.data!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          Text(
            perfil.Nombre,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colores.texto,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNuevoPerfilButton() {
    return GestureDetector(
      onTap: () {
        if (perfiles.length < 4) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: CrearPerfilScreen(IdUsuario: widget.IdUsuario),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ya existen 4 perfiles')),
          );
        }
      },
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colores.fondoAux,
              ),
              child: const Center(
                child: Icon(
                  Icons.add,
                  size: 50,
                  color: Colores.texto,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Nuevo perfil',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colores.texto,
            ),
          ),
        ],
      ),
    );
  }

  void _verificarPin(Perfiles perfil) async {
    TextEditingController textController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible:
          false, // Evita que el usuario cierre el diálogo tocando fuera
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor:
              Colors.transparent, // Hace el fondo del diálogo transparente
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: 300), // Ancho máximo del diálogo
            child: Container(
              decoration: BoxDecoration(
                color: Colores.fondo, // Color de fondo del diálogo
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colores.texto.withOpacity(0.3),
                    offset: const Offset(0, 30),
                    blurRadius: 60,
                  ),
                  const BoxShadow(
                    color: Colores.texto,
                    offset: Offset(0, 30),
                    blurRadius: 60,
                  ),
                ],
              ),
              padding:
                  const EdgeInsets.all(20), // Espaciado interno del diálogo
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Verificación",
                    style: TextStyle(
                      color: Colores.texto,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Introduzca el PIN de ${perfil.Nombre}",
                    style: TextStyle(
                      color: Colores.texto,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: "Escribe el PIN...",
                      hintStyle:
                          TextStyle(color: Colores.texto.withOpacity(0.6)),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colores.texto),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Colores.texto, width: 2.0),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true, // Oculta el texto para mayor seguridad
                    style: TextStyle(color: Colores.texto),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Cierra el diálogo
                        },
                        child: Text(
                          "Cancelar",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (textController.text == perfil.Pin.toString()) {
                            
                            Navigator.of(context).pop(); // Cierra el diálogo
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.fade,
                                child: Home(perfil: perfil),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pin incorrecto')),
                            );
                          }
                        },
                        child: Text(
                          "Iniciar",
                          style: TextStyle(color: Colores.texto),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
