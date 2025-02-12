// ignore_for_file: file_names

import 'dart:io';

import 'package:animated_background/animated_background.dart';
import 'package:famsync/View/Inicio/nexoIncio.dart';
import 'package:famsync/View/Inicio/resumen.dart';
import 'package:famsync/View/Modulos/modulos.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/Inicio/NewProfile.dart';
import 'package:famsync/components/colores.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SeleccionPerfil extends StatefulWidget {
  final int IdUsuario;

  const SeleccionPerfil({super.key, required this.IdUsuario});

  @override
  _SeleccionPerfilState createState() => _SeleccionPerfilState();
}

class _SeleccionPerfilState extends State<SeleccionPerfil>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  List<Perfiles> perfiles = [];
  int selectedProfileIndex = -1;
  bool _predeterminado = true; // Variable para controlar el modo de edición

  @override
  void initState() {
    super.initState();
    reload();

    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void reload() async {
    perfiles = await ServicioPerfiles().getPerfiles(widget.IdUsuario);
    setState(() {});
  }

  void _toggleEditMode() {
    setState(() {
      _predeterminado = !_predeterminado;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtener las dimensiones de la pantalla
    var screenSize = MediaQuery.of(context).size;
    var buttonWidth = screenSize.width * 0.6; // Ancho del botón ajustado
    var buttonHeight = screenSize.height * 0.06; // Alto del botón ajustado

    return Scaffold(
      body: AnimatedBackground(
        behaviour: RandomParticleBehaviour(
          options: const ParticleOptions(
            spawnMaxRadius: 50,
            spawnMinSpeed: 10.00,
            particleCount: 17,
            spawnMaxSpeed: 10,
            minOpacity: 0.3,
            spawnOpacity: 0.4,
            baseColor: Colors.blue,
            image: Image(image: AssetImage('assets/images/main.png')),
          ),
        ),
        vsync: this,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Selecciona tu perfil:',
              style: TextStyle(fontSize: 18),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 40,
                  mainAxisSpacing: 30,
                ),
                padding: const EdgeInsets.all(75),
                itemCount:
                    perfiles.length + 1, // Incluye el botón "Nuevo perfil"
                itemBuilder: (context, index) {
                  if (index == perfiles.length) {
                    // Botón "Nuevo perfil"
                    return _buildCenteredItem(
                        context, _buildNuevoPerfilButton());
                  } else {
                    // Perfil existente
                    return _buildCenteredItem(
                      context,
                      _buildPerfilItem(perfiles[index], index),
                    );
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                width: buttonWidth, // Ajustar el ancho del botón
                height: buttonHeight, // Ajustar la altura del botón
                child: ElevatedButton(
                  onPressed: _toggleEditMode,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: _predeterminado
                        ? Colores.botonesSecundarios
                        : Colores.eliminar,
                  ),
                  child: Text(_predeterminado
                      ? 'Establecer como predeterminado'
                      : 'Cancelar'),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // Método para construir un elemento centrado si es necesario
  Widget _buildCenteredItem(BuildContext context, Widget child) {
    // Asegúrate de que solo haya un elemento en la fila
    if (perfiles.length % 2 == 0 || perfiles.isEmpty) {
      // Si hay un número par de elementos (incluyendo el botón "Nuevo perfil") o si la lista está vacía,
      // simplemente devuelve el elemento.
      return child;
    } else {
      // Si hay un número impar de elementos, centra el elemento en un Row.
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [child],
      );
    }
  }

  // Método para construir un perfil
  Widget _buildPerfilItem(Perfiles perfil, int index) {
    return GestureDetector(
      onTap: () async {
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
                  const SizedBox(
                      height: 16), // Espacio entre el texto y el campo de texto
                  TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      hintText: "Escribe el PIN...",
                    ),
                    keyboardType: TextInputType
                        .number, // Define que sea un campo numérico
                    obscureText: true, // Para que el PIN no sea visible
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text("Iniciar"),
                  onPressed: () async {
                    if (textController.text == perfil.Pin.toString()) {
                      print("index: $index");
                      final SharedPreferences preferencias =
                          await SharedPreferences.getInstance();
                      await preferencias.remove('IdPerfil');
                      if (!_predeterminado) {
                        await preferencias.setInt('IdPerfil', perfil.Id);
                        print(preferencias.getInt('IdPerfil'));
                      }

                      bool aux = await NexoInicio().primeraVezResumen();

                      if (aux) {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.fade,
                            child: Resumen(
                              perfil: perfil,
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.fade,
                            child: Modulos(
                              perfil: perfil,
                            ),
                          ), 
                        );
                      }
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
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colores.botones,
            backgroundImage: perfil.FotoPerfil.isNotEmpty ? null : null,
            child: perfil.FotoPerfil.isEmpty
                ? Text(
                    perfil.Nombre[0], // Mostrar la inicial si no hay imagen
                    style: const TextStyle(
                      color: Colores.texto,
                      fontSize: 30,
                    ),
                  )
                : FutureBuilder<File>(
                    future: ServicioPerfiles().obtenerImagen(perfil.FotoPerfil),
                    builder:
                        (BuildContext context, AsyncSnapshot<File> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Mientras la imagen se está descargando, mostramos un indicador de carga
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        print("error al obtener la imagen");
                        // Si hay un error al cargar la imagen, mostramos un ícono de error o similar
                        print(snapshot.error);
                        print(perfil.FotoPerfil);
                        return const Icon(Icons.error, color: Colores.texto);
                      } else if (snapshot.hasData && snapshot.data != null) {
                        print("imagen descargada");
                        // Si la imagen se ha descargado correctamente, devolvemos un CircleAvatar con la imagen
                        return CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              FileImage(snapshot.data!), // Mostrar la imagen
                        );
                      } else {
                        // Si no hay datos, mostramos un espacio vacío o algún fallback
                        return const Icon(Icons.person, color: Colores.texto);
                      }
                    },
                  ),
          ),
          const SizedBox(height: 10),
          Text(
            perfil.Nombre,
            style: const TextStyle(
              color: Colores.texto,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }

  // Método para construir el botón "Nuevo perfil"
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
      child: const Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colores.principal,
            child: Icon(
              Icons.add,
              size: 50,
              color: Colores.texto,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Nuevo perfil',
            style: TextStyle(
              color: Colores.texto,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
