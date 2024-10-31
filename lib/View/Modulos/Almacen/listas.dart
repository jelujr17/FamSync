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
          backgroundColor: Colores.fondo,
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
                  backgroundColor: Colores.botonesSecundarios,
                ),
                onPressed: () async {
                  bool result = await ServiciosListas().registrarLista(
                      nombreController.text,
                      widget.perfil.Id,
                      widget.perfil.UsuarioId,
                      visible);
                  if (result) {
                    Navigator.pop(context);
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

  void _showEditarListaDialog(Listas lista) {
    final TextEditingController nombreController = TextEditingController(text: lista.Nombre);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colores.fondo,
          title: const Text('Editar Lista',
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
                  backgroundColor: Colores.botonesSecundarios,
                ),
                onPressed: () async {
                  // Lógica para actualizar la lista
                  bool result = await ServiciosListas().actualizarLista(
                      lista.Id, lista.Nombre, lista.Productos, lista.Visible);
                  if (result) {
                    Navigator.pop(context);
                    setState(() {
                      _listasFuture = ServiciosListas()
                          .getListas(widget.perfil.UsuarioId, widget.perfil.Id);
                    });
                  } else {
                    print('Error al editar la lista');
                  }
                },
                child: const Text('Actualizar',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmarEliminarLista(Listas lista) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colores.fondo,
          title: const Text('Eliminar Lista',
              style: TextStyle(color: Colores.texto)),
          content: Text('¿Estás seguro de que deseas eliminar "${lista.Nombre}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                // Lógica para eliminar la lista
                bool result = await ServiciosListas().eliminarLista(lista.Id);
                if (result) {
                  Navigator.pop(context);
                  setState(() {
                    _listasFuture = ServiciosListas()
                        .getListas(widget.perfil.UsuarioId, widget.perfil.Id);
                  });
                } else {
                  print('Error al eliminar la lista');
                }
              },
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void showPopup(Listas lista) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (BuildContext context, ScrollController scrollController) {
            return DetallesListaDialog(
              lista: lista,
              onEdit: () => _showEditarListaDialog(lista),
              onDelete: () => _confirmarEliminarLista(lista),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFABC270),
        title: const Text('Mis Listas', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 4, // Sombra en el AppBar
      ),
      body: FutureBuilder<List<Listas>>(
        future: _listasFuture,
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
                    color: const Color(0xFFFEC868),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      title: Text(
                        lista.Nombre,
                        style: const TextStyle(
                          color: Color(0xFF473C33),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditarListaDialog(lista),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmarEliminarLista(lista),
                          ),
                        ],
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
        backgroundColor: const Color(0xFFFDA769),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
