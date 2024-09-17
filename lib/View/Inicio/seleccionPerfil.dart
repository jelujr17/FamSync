import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:smart_family/Model/perfiles.dart';
import 'package:smart_family/View/Inicio/EditProfile.dart';
import 'package:smart_family/View/Inicio/NewProfile.dart';
import 'package:smart_family/View/Inicio.dart';
import 'package:smart_family/components/colores.dart';

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
  bool _isEditMode = true; // Variable para controlar el modo de edición

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
      _isEditMode = !_isEditMode;
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
                    backgroundColor: Colores.botonesSecundarios,
                  ),
                  child: Text(_isEditMode ? 'Configurar perfiles' : 'Listo'),
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
      onTap: () {
        print("index: $index");
        if (_isEditMode == true) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: InicioScreen(perfil: perfil),
            ),
          );
        } else {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: EditarPerfilScreen(
                  Id: perfil.Id, IdUsuario: widget.IdUsuario),
            ),
          );
        }
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: _isEditMode ? Colores.principal : Colores.botones,
            child: !_isEditMode
                ? const Icon(
                    Icons.edit,
                    size: 30,
                    color: Colors.white,
                  )
                : Text(
                    perfil.Nombre[0],
                    style: const TextStyle(
                      color: Colores.texto,
                      fontSize: 30,
                    ),
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
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            child: CrearPerfilScreen(IdUsuario: widget.IdUsuario),
          ),
        );
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
