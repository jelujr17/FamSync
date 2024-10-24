import 'package:famsync/Model/listas.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/Modulos/Almacen/VerLista.dart';
import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';

class ListasPage extends StatefulWidget {
  final Perfiles perfil;

  const ListasPage({super.key, required this.perfil});

  @override
  _ListasPageState createState() => _ListasPageState();
}

class _ListasPageState extends State<ListasPage> {
  late Future<List<Listas>> _listasFuture;

  @override
  void initState() {
    super.initState();
    _listasFuture =
        ServiciosListas().getListas(widget.perfil.UsuarioId, widget.perfil.Id);
  }

  void _showAgregarListaDialog() {
    final TextEditingController nombreController = TextEditingController();
    final List<int> visible = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colores.fondo, // Color principal
          title: const Text('Agregar Nueva Lista',
              style: TextStyle(color: Colores.texto)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la lista',
                  labelStyle: TextStyle(color: Colores.texto),
                ),
                style: const TextStyle(color: Colores.texto),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colores.botonesSecundarios, // Botón color secundario
                ),
                onPressed: () async {
                  // Lógica para agregar la nueva lista
                  bool result = await ServiciosListas().registrarLista(
                      nombreController.text,
                      widget.perfil.Id,
                      widget.perfil.UsuarioId,
                      visible);
                  if (result) {
                    Navigator.pop(context); // Cierra el diálogo
                    setState(() {
                      _listasFuture = ServiciosListas()
                          .getListas(widget.perfil.UsuarioId, widget.perfil.Id);
                    });
                  } else {
                    print('Error al agregar la lista');
                  }
                },
                child: const Text('Agregar',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  void showPopup(Listas lista) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Esto permite controlar el tamaño de la ventana emergente
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize:
              0.6, // Ajusta el tamaño inicial (0.6 significa 60% de la pantalla)
          minChildSize: 0.4, // Tamaño mínimo al que se puede reducir la hoja
          maxChildSize: 0.9, // Tamaño máximo al que se puede expandir la hoja
          builder: (BuildContext context, ScrollController scrollController) {
            return DetallesListaDialog(lista: lista);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Elimina la flecha de retroceso
        backgroundColor: const Color(0xFFABC270), // Color principal
        title: const Text('Mis Listas', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Listas>>(
        future: _listasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Mostrar el error exacto que se recibe
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
                    color: const Color(0xFFFEC868), // Color de las tarjetas
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      title: Text(
                        lista.Nombre,
                        style: const TextStyle(
                          color: Color(0xFF473C33), // Color del texto
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        showPopup(lista);
                      },
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAgregarListaDialog,
        backgroundColor: const Color(0xFFFDA769), // Color del botón flotante
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
