import 'package:famsync/Model/Categorias.dart';

import 'package:famsync/Model/Perfiles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CategoriaPage extends StatefulWidget {
  final Perfiles perfil;

  const CategoriaPage({super.key, required this.perfil});

  @override
  _CategoriaPageState createState() => _CategoriaPageState();
}

class _CategoriaPageState extends State<CategoriaPage> {
  late ServiciosCategorias _serviciosTiendas;
  late Future<List<Categorias>> _categoriasFuture;
  List<Categorias> _categorias = [];
  List<Categorias> _categoriasFiltradas = [];
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController();
  Color _selectedColor = Colors.blue;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _serviciosTiendas = ServiciosCategorias();
    _categoriasFuture =
        _serviciosTiendas.getCategorias(user!.uid, widget.perfil.PerfilID);

    _categoriasFuture.then((data) {
      setState(() {
        _categorias = data;
        _categoriasFiltradas = data;
      });
    });
    _searchController.addListener(_filterCategories);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterCategories() {
    String searchText = _searchController.text.toLowerCase();
    setState(() {
      _categoriasFiltradas = _categorias
          .where((categoria) =>
              categoria.nombre.toLowerCase().contains(searchText))
          .toList();
    });
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
    );
  }

  void _showCreateCategoryDialog() {
    TextEditingController nombreController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Crear Categoría'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'nombre'),
                ),
                const SizedBox(height: 20),
                const Text('Color'),
                GestureDetector(
                  onTap: () {
                    _showColorPickerDialog((color) {
                      setState(() {
                        _selectedColor = color;
                      });
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    height: 40,
                    color: _selectedColor,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (nombreController.text.isEmpty) {
                    _showToast('Todos los campos son obligatorios');
                    return;
                  }
                  bool result = await ServiciosCategorias().registrarCategoria(
                    user!.uid,
                    widget.perfil.PerfilID,
                    nombreController.text,
                    _selectedColor.value.toRadixString(16),
                  );
                  if (result) {
                    _showToast('Categoría creada con éxito');
                    Navigator.pop(context);
                    setState(() {
                      _categoriasFuture = ServiciosCategorias()
                          .getCategorias(user!.uid, widget.perfil.PerfilID);
                      _reloadCategories();
                    });
                  } else {
                    _showToast('Error al crear la categoría');
                  }
                },
                child: const Text('Crear'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancelar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showColorPickerDialog(ValueChanged<Color> onColorSelected) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccione un color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedColor,
              onColorChanged: (Color color) {
                onColorSelected(color); // Notificar cambio de color
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Seleccionar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _reloadCategories() {
    setState(() {
      _categoriasFuture = ServiciosCategorias()
          .getCategorias(user!.uid, widget.perfil.PerfilID);
    });
    _categoriasFuture.then((data) {
      setState(() {
        _categorias = data;
        _categoriasFiltradas = data;
      });
    });
  }

  void _showCategoryDetailsDialog(Categorias categoria) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de ${categoria.nombre}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('nombre: ${categoria.nombre}'),
            Text('Color: ${categoria.Color}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteCategoryDialog(Categorias categoria) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Categoría'),
        content: Text(
            '¿Estás seguro de que quieres eliminar la categoría ${categoria.nombre}?'),
        actions: [
          TextButton(
            onPressed: () async {
              bool result = await ServiciosCategorias()
                  .eliminarCategoria(user!.uid, categoria.CategoriaID);
              if (result) {
                _showToast('Categoría eliminada con éxito');
                Navigator.pop(context);
                _reloadCategories();
              } else {
                _showToast('Error al eliminar la categoría');
              }
            },
            child: const Text('Eliminar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _mostrarMenuFiltro() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 300,
          child: const Column(
            children: [
              Text(
                'Filtrar Productos',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadCategories,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _mostrarMenuFiltro,
                ),
                hintText: 'Buscar productos...',
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _categoriasFiltradas.length,
              itemBuilder: (context, index) {
                Categorias categoria = _categoriasFiltradas[index];
                return ListTile(
                  title: Text(categoria.nombre),
                  subtitle: Text('Color: ${categoria.Color}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _showDeleteCategoryDialog(categoria),
                  ),
                  onTap: () => _showCategoryDetailsDialog(categoria),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateCategoryDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
