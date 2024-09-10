import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Paquete para seleccionar imágenes desde la galería o cámara
import 'dart:io'; // Para manejar archivos
import 'package:intl/intl.dart'; // Paquete para formatear fechas
import 'package:smart_family/Model/perfiles.dart';
import 'package:smart_family/View/seleccionPerfil.dart';

import 'package:smart_family/components/colores.dart';

class EditarPerfilScreen extends StatefulWidget {
  final int Id;
  final int IdUsuario;

  const EditarPerfilScreen(
      {super.key, required this.Id, required this.IdUsuario});

  @override
  _EditarPerfilScreenState createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();

  bool _isPinVisible = false; // Variable para controlar la visibilidad del PIN
  File? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        DateTime localDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
        );
        _fechaController.text = DateFormat('dd/MM/yyyy').format(localDate);
      });
    }
  }

  Future<void> _editarPerfil() async {
    final String nombre = _nombreController.text;
    final String pin = _pinController.text;
    final String nuevopin = _newPinController.text;
    final String fechaNacimientoStr = _fechaController.text;

    if (nombre.isNotEmpty && pin.isNotEmpty && fechaNacimientoStr.isNotEmpty) {
      try {
        DateFormat format = DateFormat("dd/MM/yyyy");
        DateTime fechaNacimiento = format.parse(fechaNacimientoStr);

        Perfiles? perfil = await ServicioPerfiles().getPerfilById(widget.Id);
        if (perfil != null) {
          int pin_actual = perfil.Pin;

          if (pin_actual == int.parse(pin)) {
            bool editado = await ServicioPerfiles().editarPerfil(
              widget.Id,
              nombre,
              1,
              int.parse(nuevopin),
              fechaNacimientoStr,
            );
            if (editado) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Perfil editado exitosamente')),
              );
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SeleccionPerfil(
                            IdUsuario: widget.IdUsuario,
                          )));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error al editar un perfil')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PIN incorrecto')),
            );
          }
        } else {
          print('Perfil no encontrado.');
        }
      } catch (e) {
        print('Formato de fecha incorrecto: $e');
      }
    } else {
      print('Por favor completa todos los campos.');
    }
  }

  Future<void> _eliminarPerfil() async {
    // Mostrar ventana emergente de confirmación
    bool confirm = await _mostrarConfirmacionEliminar();
    if (confirm) {
      bool eliminado = await ServicioPerfiles().eliminarPerfil(widget.Id);
      if (eliminado) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil eliminado exitosamente')),
        );
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SeleccionPerfil(
                      IdUsuario: widget.IdUsuario,
                    )));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar un perfil')),
        );
      }
    }
  }

  Future<bool> _mostrarConfirmacionEliminar() async {
    TextEditingController pinController = TextEditingController();
    Perfiles? perfilEliminar = await ServicioPerfiles().getPerfilById(widget.Id);

    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmar eliminación'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                      '¿Estás seguro de que quieres eliminar este perfil? Esta acción no se puede deshacer.'),
                  const SizedBox(height: 20),
                  TextField(
                    controller: pinController,
                    decoration: const InputDecoration(
                      labelText: 'Ingresa el PIN para confirmar',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Eliminar cancelado
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    if (pinController.text.isNotEmpty &&
                        pinController.text == perfilEliminar!.Pin.toString()) {
                      Navigator.of(context).pop(true); // Confirmar eliminación
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('PIN incorrecto')),
                      );
                    }
                  },
                  child: const Text('Eliminar',
                      style: TextStyle(color: Colores.eliminar)),
                ),
              ],
            );
          },
        ) ??
        false; // Si se cierra el diálogo sin respuesta, devolver false
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Editar Perfil'),
        backgroundColor: Colores.principal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colores.principal,
                  backgroundImage:
                      _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
                      ? const Icon(
                          Icons.add_a_photo,
                          size: 50,
                          color: Colores.texto,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del perfil',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _pinController,
                decoration: InputDecoration(
                  labelText: 'PIN Actual',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPinVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPinVisible = !_isPinVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isPinVisible,
                keyboardType: TextInputType.number,
                maxLength: 4,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _newPinController,
                decoration: InputDecoration(
                  labelText: 'PIN Nuevo',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPinVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPinVisible = !_isPinVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isPinVisible,
                keyboardType: TextInputType.number,
                maxLength: 4,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _fechaController,
                decoration: const InputDecoration(
                  labelText: 'Fecha de Nacimiento',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _editarPerfil,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colores.botonesSecundarios,
                ),
                child: const Text('Editar Perfil'),
              ),
              const SizedBox(height: 200),
              ElevatedButton(
                onPressed: _eliminarPerfil,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colores.eliminar,
                ),
                child: const Text('Eliminar Perfil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
