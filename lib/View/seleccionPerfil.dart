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
  int selectedProfileIndex = -1;

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
                        crossAxisSpacing: 40,
                        mainAxisSpacing: 30,
                      ),
                      padding: const EdgeInsets.all(75),
                      itemCount: perfiles.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedProfileIndex = index;
                            });
                          },
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: selectedProfileIndex == index
                                        ? Colors.blue
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.blueAccent,
                                  child: Text(
                                    perfiles[index].Nombre[0],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                perfiles[index].Nombre,
                                style: const TextStyle(
                                  color: Colores.texto,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () {
                  if (selectedProfileIndex >= 0) {
                    // Aquí puedes manejar lo que sucede cuando se selecciona un perfil
                    print(
                        'Perfil seleccionado: ${perfiles[selectedProfileIndex].Nombre}');
                  } else {
                    // Mostrar un mensaje de error o alerta
                    print('Por favor selecciona un perfil');
                  }
                },
                child: const Text('Confirmar selección'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colores.botonesSecundarios,
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

