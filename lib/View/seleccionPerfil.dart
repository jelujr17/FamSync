// ignore_for_file: library_private_types_in_public_api, non_constant_identifier_names

import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:smart_family/Model/perfiles.dart';
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
    print("Entra ${widget.IdUsuario}");
    perfiles = await ServicioPerfiles().getPerfiles(widget.IdUsuario);
    print("la verdadera vuelta ${perfiles.length}");

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
        vsync: this, // Usa el proveedor de ticker de _SeleccionPerfilState
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: perfiles.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay perfiles disponibles',
                        style: TextStyle(color: Colores.texto, fontSize: 20),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: perfiles.length,
                      itemBuilder: (context, index) {
                        return ProfileTile(perfil: perfiles[index]);
                      },
                    ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                // Lógica para agregar un nuevo perfil
              },
              icon: const Icon(Icons.add),
              label: const Text('Gestionar perfiles'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colores.botonesSecundarios,
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

class ProfileTile extends StatelessWidget {
  final Perfiles perfil;

  const ProfileTile({Key? key, required this.perfil}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Lógica para seleccionar el perfil
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.transparent,
            child: Text(perfil.Nombre[0],
                style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          const SizedBox(height: 10),
          Text(
            perfil.Nombre,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

