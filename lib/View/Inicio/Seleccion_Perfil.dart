// ignore_for_file: file_names

import 'package:famsync/View/Inicio/Home.dart';
import 'package:famsync/View/Inicio/Nuevo_Perfil.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:famsync/Model/Perfiles.dart';
import 'package:famsync/components/colores.dart';
import 'package:flutter/foundation.dart'; // <--- Importante

class SeleccionPerfil extends StatefulWidget {
  final String UID;

  const SeleccionPerfil({super.key, required this.UID});

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
    perfiles = await ServicioPerfiles().getPerfiles(widget.UID);
    setState(() {});
  }

  void _toggleEditMode() {
    setState(() {
      _editMode = !_editMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    // Porcentaje del ancho de pantalla (ajusta el valor según lo que necesites)
    final double avatarSize = kIsWeb
        ? screenWidth * 0.12 // 12% del ancho en web
        : screenWidth * 0.28; // 28% del ancho en móvil

    final double fontSize = avatarSize * 0.35;
    final int crossAxisCount = kIsWeb ? 5 : 2;

    return Scaffold(
      backgroundColor: Colores.fondo,
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
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 1500),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        ...perfiles
                            .map((perfil) =>
                                _buildPerfilItem(perfil, avatarSize, fontSize)),
                        _buildNuevoPerfilButton(avatarSize, fontSize),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerfilItem(Perfiles perfil, double avatarSize, double fontSize) {
    return GestureDetector(
      onTap: () {
        if (!_editMode) {
          _verificarPin(perfil);
        } else {
          // Aquí puedes poner otra acción para el modo edición
        }
      },
      child: Column(
        children: [
          SizedBox(
            width: avatarSize,
            height: avatarSize,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colores.texto,
              ),
              child: Center(
                child: Text(
                  (perfil.nombre.isNotEmpty ? perfil.nombre[0] : '?'),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            perfil.nombre,
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

  Widget _buildNuevoPerfilButton(
    double avatarSize,
    double fontSize,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            child: CrearPerfilScreen(
              UID: widget.UID,
            ),
          ),
        );
      },
      child: Column(
        children: [
          SizedBox(
            width: avatarSize,
            height: avatarSize,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colores.texto,
              ),
              child: const Center(
                child: Icon(
                  Icons.add,
                  size: 50,
                  color: Colores.fondoAux,
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
                    "Introduzca el PIN de ${perfil.nombre}",
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
