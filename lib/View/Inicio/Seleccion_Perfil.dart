// ignore_for_file: file_names

import 'dart:io';

import 'package:famsync/View/Inicio/Home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/Inicio/Nuevo_Perfil.dart';
import 'package:famsync/components/colores.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      backgroundColor: Colors.white, // Fondo blanco
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
                      color: Colores.principal,
                    ),
                  ),
                  if (perfiles.isNotEmpty)
                    TextButton(
                      onPressed: _toggleEditMode,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: Text(
                        _editMode ? 'Cancelar' : 'Editar',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Texto "¿Quién está viendo?"
            Text(
              '¿Quién está viendo?',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 30),
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
              color: Colors.black,
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
                color: Colors.grey[300],
              ),
              child: const Center(
                child: Icon(
                  Icons.add,
                  size: 50,
                  color: Colors.black,
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
              color: Colors.black,
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
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Verificación"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("Introduzca el pin de ${perfil.Nombre}"),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                decoration: const InputDecoration(
                  hintText: "Escribe el PIN...",
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Iniciar"),
              onPressed: () async {
                if (textController.text == perfil.Pin.toString()) {
                  final SharedPreferences preferencias =
                      await SharedPreferences.getInstance();
                  await preferencias.remove('IdPerfil');
                  await preferencias.setInt('IdPerfil', perfil.Id);
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
            ),
          ],
        );
      },
    );
  }
}
