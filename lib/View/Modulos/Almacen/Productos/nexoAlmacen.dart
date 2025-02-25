// funciones_auxiliares.dart
import 'package:famsync/Model/Almacen/listas.dart';
import 'package:famsync/Model/Almacen/producto.dart';
import 'package:famsync/View/Modulos/Almacen/almacen.dart';
import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';

class NexoAlmacen {
  // Función para añadir producto a una lista
  void seleccionarLista(
      Productos producto, int usuarioId, int perfilId, BuildContext context) {
    Future<List<Listas>> listasFuture =
        ServiciosListas().getListas(usuarioId, perfilId);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colores.fondo,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Ajusta el tamaño del diálogo
            children: [
              // AppBar personalizada
              ClipPath(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colores.botones,
                        Colores.botonesSecundarios,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: const Center(
                    child: Text(
                      'Mis Listas',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colores.fondo,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 3.0,
                            color: Colores.texto,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Contenido del diálogo
              SizedBox(
                width: double.maxFinite,
                height: 400, // Ajusta la altura según sea necesario
                child: buildListDialogContent(listasFuture, producto),
              ),
              // Botón de cerrar
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cerrar',
                    style: TextStyle(color: Colores.texto),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Función para construir el contenido del diálogo
  Widget buildListDialogContent(
      Future<List<Listas>> listasFuture, Productos producto) {
    return FutureBuilder<List<Listas>>(
      future: listasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay listas disponibles'));
        } else {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Listas lista = snapshot.data![index];
                return Card(
                  // Cambia el color del Card
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    title: Text(
                      lista.Nombre,
                      style: const TextStyle(
                        color: Colores.texto,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () async {
                      bool intento = await ServiciosListas()
                          .incluirProducto(producto, lista);
                      if (intento) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Producto insertado correctamente.')),
                        );
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Ha ocurrido un error al insertar el producto en la lista.')),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}
