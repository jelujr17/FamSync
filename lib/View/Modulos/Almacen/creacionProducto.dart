import 'dart:io';
import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/Model/tiendas.dart';
import 'package:famsync/components/colores.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';

class ProductCreationCarousel extends StatefulWidget {
  final Perfiles perfil;

  const ProductCreationCarousel({super.key, required this.perfil});

  @override
  _ProductCreationCarouselState createState() =>
      _ProductCreationCarouselState();
}

class _ProductCreationCarouselState extends State<ProductCreationCarousel> {
  final PageController _pageController = PageController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _dropdownSearchFieldController =
      TextEditingController();

  final List<XFile> _imagenesSeleccionadas = [];
  final ImagePicker _picker = ImagePicker();
  int _currentPageIndex = 0;
  List<int> _perfilSeleccionado = [];
  List<File> _imagenesFiles = [];
  List<Tiendas> tiendasDisponibles = [];
  Tiendas? _tiendaSeleccionada; // Variable para la tienda seleccionada
  String? tiendaSeleccionada;

  List<String> nombresTienda = [];
  SuggestionsBoxController suggestionBoxController = SuggestionsBoxController();

  Future<void> _seleccionarImagenes() async {
    final List<XFile> imagenes = await _picker.pickMultiImage();
    setState(() {
      _imagenesSeleccionadas.addAll(imagenes);
      _imagenesFiles = imagenes.map((xFile) => File(xFile.path)).toList();
      print('Imágenes seleccionadas: $_imagenesFiles');
    });
  }

  @override
  void initState() {
    super.initState();
    obtenerTiendas();
    obtenerNombresTiendas();
    _pageController.addListener(() {
      setState(() {
        _currentPageIndex = _pageController.page!.toInt();
      });
    });
  }

  List<String> getSuggestions(String query) {
    List<String> matches = <String>[];
    matches.addAll(
        nombresTienda); // Asegúrate de que nombresTienda esté correctamente poblada

    matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }

  void obtenerTiendas() async {
    tiendasDisponibles =
        await ServiciosTiendas().getTiendas(widget.perfil.UsuarioId);
    obtenerNombresTiendas(); // Asegúrate de que esto se llame después de obtener las tiendas

    setState(() {});
  }

  void obtenerNombresTiendas() {
    nombresTienda = tiendasDisponibles.map((e) => e.Nombre).toList();
    print(nombresTienda);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nombreController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  bool _validarCampos() {
    if (_nombreController.text.isEmpty ||
        _tiendaSeleccionada == null ||
        _precioController.text.isEmpty) {
      return false;
    }
    return true;
  }

  void _mostrarAlerta() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Campos incompletos'),
          content: const Text(
              'Por favor, complete todos los campos antes de continuar.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        height: 550,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Crear Producto',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextField(
                          controller: _nombreController,
                          decoration: InputDecoration(
                            labelText: 'Nombre del producto',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.shopping_cart),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // DropdownButton para seleccionar la tienda
                        DropDownSearchFormField(
                          textFieldConfiguration: TextFieldConfiguration(
                            decoration: InputDecoration(
                              labelText: 'Selecciona una tienda',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons
                                  .store), // Puedes cambiar el ícono si lo deseas
                            ),
                            controller: _dropdownSearchFieldController,
                          ),
                          suggestionsCallback: (pattern) {
                            return getSuggestions(
                                pattern); // Debe devolver una lista de nombres de tienda
                          },
                          itemBuilder: (context, String suggestion) {
                            return ListTile(
                              title: Text(suggestion),
                            );
                          },
                          itemSeparatorBuilder: (context, index) {
                            return const Divider();
                          },
                          transitionBuilder:
                              (context, suggestionsBox, controller) {
                            return suggestionsBox;
                          },
                          onSuggestionSelected: (String suggestion) {
                            _dropdownSearchFieldController.text = suggestion;
                            tiendaSeleccionada =
                                suggestion; // Actualiza la variable de tienda seleccionada
                          },
                          suggestionsBoxController: suggestionBoxController,
                          validator: (value) => value!.isEmpty
                              ? 'Por favor selecciona una tienda'
                              : null,
                          displayAllSuggestionWhenTap: true,
                        ),

                        const SizedBox(height: 16),
                        TextField(
                          controller: _precioController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*')),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Precio',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.attach_money),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Segunda pantalla: Selección de perfiles
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Selecciona los perfiles visibles:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: FutureBuilder<List<Perfiles>>(
                            future: ServicioPerfiles()
                                .getPerfiles(widget.perfil.UsuarioId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return const Center(
                                    child:
                                        Text('No hay perfiles disponibles.'));
                              }

                              List<Perfiles> perfiles = snapshot.data!;
                              for (int i = 0; i < perfiles.length; i++) {
                                if (perfiles[i].Id == widget.perfil.Id) {
                                  perfiles.removeAt(i);
                                }
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: perfiles.length,
                                itemBuilder: (context, index) {
                                  final perfil = perfiles[index];

                                  return Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        perfil.FotoPerfil.isNotEmpty &&
                                                File('C:\\Users\\mario\\Documents\\Imagenes_FamSync\\Perfiles\\${perfil.FotoPerfil}')
                                                    .existsSync()
                                            ? ClipOval(
                                                child: Image.file(
                                                  File(
                                                      'C:\\Users\\mario\\Documents\\Imagenes_FamSync\\Perfiles\\${perfil.FotoPerfil}'),
                                                  width: 40,
                                                  height: 40,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : const Icon(
                                                Icons.image_not_supported,
                                                size: 40),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            perfil.Nombre,
                                            style: const TextStyle(
                                              color: Colores.texto,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        Checkbox(
                                          value: _perfilSeleccionado
                                              .contains(perfil.Id),
                                          onChanged: (bool? value) {
                                            setState(() {
                                              if (value == true) {
                                                _perfilSeleccionado
                                                    .add(perfil.Id);
                                              } else {
                                                _perfilSeleccionado
                                                    .remove(perfil.Id);
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tercera pantalla: Selección de imágenes
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _seleccionarImagenes,
                          icon: const Icon(Icons.image),
                          label: const Text('Seleccionar imágenes'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _imagenesSeleccionadas.isNotEmpty
                            ? SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _imagenesSeleccionadas.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.file(
                                              File(_imagenesSeleccionadas[index]
                                                  .path),
                                              width: 70,
                                              height: 70,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            child: IconButton(
                                              icon: const Icon(
                                                  Icons.remove_circle,
                                                  color: Colors.red),
                                              onPressed: () {
                                                setState(() {
                                                  _imagenesSeleccionadas
                                                      .removeAt(index);
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                            : const Text('No hay imágenes seleccionadas.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _currentPageIndex > 0
                      ? () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _currentPageIndex < 2
                      ? () {
                          if (_validarCampos()) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _mostrarAlerta();
                          }
                        }
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
