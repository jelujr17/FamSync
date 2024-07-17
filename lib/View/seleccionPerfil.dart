import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:smart_family/Model/perfiles.dart';

class SeleccionPerfil extends StatefulWidget {
  final int IdUsuario;

  const SeleccionPerfil({Key? key, required this.IdUsuario}) : super(key: key);

  @override
  _SeleccionPerfilState createState() => _SeleccionPerfilState();
}

class _SeleccionPerfilState extends State<SeleccionPerfil>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  List<Perfiles> perfiles = [];

  @override
  void initState() {
    super.initState();
    reload();

    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(_controller);
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
    Size size = MediaQuery.of(context).size;

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
            AppBar(
              title: const Text('Selecciona tu perfil'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            Expanded(
              child: perfiles.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay perfiles disponibles',
                        style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 20),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: perfiles.length,
                      itemBuilder: (context, index) {
                        return ProfileTile(perfil: perfiles[index]);
                      },
                    ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Lógica para agregar un nuevo perfil
              },
              icon: const Icon(Icons.add),
              label: const Text('Agregar perfil'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.grey[800],
              ),
            ),
            TextButton(
              onPressed: () {
                // Lógica para administrar perfiles
              },
              child: const Text(
                'Administrar perfiles',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
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
            child: Text(perfil.Nombre[0], style: TextStyle(color: Colors.white, fontSize: 24)),
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

class ServicioPerfiles {
  Future<List<Perfiles>> getPerfiles(int idUsuario) async {
    // Aquí iría la lógica para obtener los perfiles del usuario
    // Por simplicidad, devolveré una lista vacía
    await Future.delayed(Duration(seconds: 1)); // Simulando una operación asíncrona
    return [];
  }
}
