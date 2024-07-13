import 'package:flutter/material.dart';
import 'package:smart_family/Model/perfiles.dart';

class SeleccionPerfilScreen extends StatefulWidget {
  final int usuarioId;

  SeleccionPerfilScreen({required this.usuarioId});

  @override
  _SeleccionPerfilScreenState createState() => _SeleccionPerfilScreenState();
}

class _SeleccionPerfilScreenState extends State<SeleccionPerfilScreen> {
  late Future<List<Perfiles>> _perfiles;

  @override
  void initState() {
    super.initState();
    _perfiles = ServicioPerfiles().getPerfiles(widget.usuarioId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecciona tu perfil'),
        backgroundColor: Colors.blueAccent, // Color de fondo del appbar
        elevation: 0, // Sin sombra
      ),
      backgroundColor: Colors.white, // Color de fondo general
      body: FutureBuilder<List<Perfiles>>(
        future: _perfiles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final perfiles = snapshot.data ?? [];
            return GridView.builder(
              padding: EdgeInsets.all(20.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Número de columnas
                crossAxisSpacing: 20.0, // Espaciado entre columnas
                mainAxisSpacing: 20.0, // Espaciado entre filas
              ),
              itemCount: perfiles.length + 1, // Añadir 1 para el botón de añadir perfil
              itemBuilder: (context, index) {
                if (index == perfiles.length) {
                  return AddProfileButton(
                    onTap: () {
                      // Lógica para añadir un nuevo perfil
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Placeholder(), // Sustituir por la pantalla para añadir perfil
                        ),
                      );
                    },
                  );
                } else {
                  return PerfilItem(
                    perfil: perfiles[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Placeholder(), // Sustituir por la pantalla que sigue a la selección de perfil
                        ),
                      );
                    },
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}

class PerfilItem extends StatelessWidget {
  final Perfiles perfil;
  final VoidCallback onTap;

  PerfilItem({required this.perfil, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: <Widget>[
          Expanded(
            child: ClipOval(
              child: Container(
                color: Colors.blue, // Color de fondo del avatar
                child: Center(
                  child: Text(
                    'A', // Ejemplo de texto o imagen de avatar
                    style: TextStyle(
                      color: Colors.white, // Color del texto o icono
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            perfil.Nombre,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class AddProfileButton extends StatelessWidget {
  final VoidCallback onTap;

  AddProfileButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: <Widget>[
          Expanded(
            child: ClipOval(
              child: Container(
                color: Colors.grey[300],
                child: Icon(
                  Icons.add,
                  size: 50.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            "Añadir perfil",
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
