import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Paquete para seleccionar imágenes desde la galería o cámara
import 'dart:io'; // Para manejar archivos
import 'package:intl/intl.dart'; // Paquete para formatear fechas
import 'package:smart_family/Model/perfiles.dart';
import 'package:smart_family/View/Inicio/seleccionPerfil.dart';

import 'package:smart_family/components/colores.dart';

class CrearPerfilScreen extends StatefulWidget {
  final int IdUsuario;

  const CrearPerfilScreen({super.key, required this.IdUsuario});

  @override
  _CrearPerfilScreenState createState() => _CrearPerfilScreenState();
}

class _CrearPerfilScreenState extends State<CrearPerfilScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  bool _isPinVisible = false; // Variable para controlar la visibilidad del PIN
  XFile? _image;

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      // Asegurarse de que la fecha seleccionada se interprete en la zona horaria local
      setState(() {
        // Convertir la fecha seleccionada al formato local antes de mostrarla
        DateTime localDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
        );

        _fechaController.text = DateFormat('dd/MM/yyyy').format(localDate);
      });
    }
  }

  Future<void> _crearPerfil() async {
    final String nombre = _nombreController.text;
    final String pin = _pinController.text;
    final String fechaNacimientoStr = _fechaController.text;

    if (nombre.isNotEmpty && pin.isNotEmpty && fechaNacimientoStr.isNotEmpty && _image != null) {
      try {
        // Utiliza DateFormat para convertir el String a DateTime
        DateFormat format = DateFormat("dd/MM/yyyy");
        DateTime fechaNacimiento = format.parse(fechaNacimientoStr);

        print('Nombre del perfil: $nombre');
        print('PIN del perfil: $pin');
        print('Fecha de Nacimiento: $fechaNacimiento');
        print("Id usuario: ${widget.IdUsuario}");

        // Llama a tu servicio con la imagen
        bool creado = await ServicioPerfiles().registrarPerfil(
          widget.IdUsuario,
          nombre,
          File(_image!.path), // Pasar la imagen aquí
          int.parse(pin),
          fechaNacimientoStr, // Enviar la fecha tal como está
          1 // Asumiendo que quieres enviar un valor de Infantil
        );

        if (creado) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil creado exitosamente')),
          );
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SeleccionPerfil(IdUsuario: widget.IdUsuario,)));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al crear un perfil')),
          );
        }
      } catch (e) {
        // Maneja el error de formato de fecha
        print('Formato de fecha incorrecto: $e');
      }
    } else {
      // Mostrar un mensaje de error o alerta si faltan campos
      print('Por favor completa todos los campos.');
    }
  }

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _image = pickedImage; // Guardar la imagen seleccionada
      });
    }
  }

  // Método para seleccionar la imagen
  void _pickImage() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 100,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Tomar foto'),
                onTap: () {
                  _getImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
                title: Text('Seleccionar de la galería'),
                onTap: () {
                  _getImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Crear Nuevo Perfil'),
        backgroundColor: Colores.principal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Usamos SingleChildScrollView para evitar overflow en pantallas pequeñas
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colores.principal,
                  backgroundImage: _image != null ? FileImage(File(_image!.path)) : null,
                  child: _image == null
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
                  labelText: 'PIN',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPinVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPinVisible = !_isPinVisible; // Cambia la visibilidad del PIN
                      });
                    },
                  ),
                ),
                obscureText: !_isPinVisible, // Cambia la visibilidad del PIN
                keyboardType: TextInputType.number,
                maxLength: 4, // Longitud máxima de 4 dígitos
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _fechaController,
                decoration: const InputDecoration(
                  labelText: 'Fecha de Nacimiento',
                  border: OutlineInputBorder(),
                ),
                readOnly: true, // Para que el usuario no pueda escribir directamente
                onTap: () => _selectDate(context), // Mostrar el selector de fecha al tocar
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _crearPerfil,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colores.botonesSecundarios,
                ),
                child: const Text('Crear Perfil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
