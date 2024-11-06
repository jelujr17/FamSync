import 'package:famsync/Model/Categorias.dart';
import 'package:famsync/Model/modulos.dart';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/navegacion.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CategoriaPage extends StatefulWidget {
  final Perfiles perfil;

  CategoriaPage({required this.perfil});

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
  final ServiciosModulos _serviciosModulos = ServiciosModulos();

  Future<List<Modulos>>? _modulosFuture;

  @override
  void initState() {
    super.initState();
    _serviciosTiendas = ServiciosCategorias();
    _categoriasFuture = _serviciosTiendas.getCategorias(widget.perfil.Id);
    _modulosFuture = _serviciosModulos.getModulos();

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
              categoria.Nombre.toLowerCase().contains(searchText))
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
    String? selectedColor;
    Modulos? selectedModulo;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Categoría'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            DropdownButtonFormField<String>(
              value: selectedColor,
              decoration: const InputDecoration(labelText: 'Color'),
              items: [
                'Rojo',
                'Azul',
                'Verde',
                'Amarillo',
                'Naranja',
              ].map((color) {
                return DropdownMenuItem(
                  value: color,
                  child: Text(color),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedColor = value;
                });
              },
              validator: (value) =>
                  value == null ? 'Seleccione un color' : null,
            ),
            FutureBuilder<List<Modulos>>(
              future: _modulosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Error al cargar los módulos');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No hay módulos disponibles');
                } else {
                  return DropdownButtonFormField<Modulos>(
                    decoration: const InputDecoration(labelText: 'Módulo'),
                    items: snapshot.data!.map((modulo) {
                      return DropdownMenuItem<Modulos>(
                        value: modulo,
                        child: Text(modulo.Nombre),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedModulo = value;
                      });
                    },
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (nombreController.text.isEmpty ||
                  selectedColor == null ||
                  selectedModulo == null) {
                _showToast('Todos los campos son obligatorios');
                return;
              }
              bool result = await _serviciosTiendas.registratCategoria(
                selectedModulo!.Id,
                nombreController.text,
                selectedColor!,
                widget.perfil.Id,
              );
              if (result) {
                _showToast('Categoría creada con éxito');
                Navigator.pop(context);
                setState(() {
                  _categoriasFuture =
                      _serviciosTiendas.getCategorias(widget.perfil.Id);
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
      ),
    );
  }

  void _reloadCategories() {
    setState(() {
      _categoriasFuture = _serviciosTiendas.getCategorias(widget.perfil.Id);
    });
    _categoriasFuture.then((data) {
      setState(() {
        _categorias = data;
        _categoriasFiltradas = data;
      });
    });
  }

  void _showDeleteCategoryDialog(Categorias categoria) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Categoría'),
        content: Text(
            '¿Estás seguro de que quieres eliminar la categoría ${categoria.Nombre}?'),
        actions: [
          TextButton(
            onPressed: () async {
              bool result =
                  await _serviciosTiendas.eliminarCategoria(categoria.Id);
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
          // ignore: prefer_const_constructors
          child: Column(
            children: const [
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
                  title: Text(categoria.Nombre),
                  subtitle: Text('Color: ${categoria.Color}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _showDeleteCategoryDialog(categoria),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateCategoryDialog,
        tooltip: 'Crear Categoría',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        pageController: _pageController,
        pagina: 1,
        perfil: widget.perfil,
      ),
    );
  }
}
