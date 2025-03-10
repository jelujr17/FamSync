
import 'package:famsync/Model/Almacen/producto.dart';
import 'package:flutter/material.dart';

class CampoTienda extends StatefulWidget {
  final String? Function(String?)? validator;
  final List<String> nombresTienda;
  final Function(String) onTiendaSeleccionada;
  final Productos producto;

  const CampoTienda({
    super.key,
    required this.validator,
    required this.nombresTienda,
    required this.onTiendaSeleccionada,
    required this.producto,
  });

  @override
  CampoTiendaState createState() => CampoTiendaState();
}

class CampoTiendaState extends State<CampoTienda> {
  late TextEditingController _tiendaController;
  String? tiendaSeleccionada;

  @override
  void initState() {
    super.initState();
    _tiendaController = TextEditingController(text: widget.producto.Tienda);
    tiendaSeleccionada = widget.producto.Tienda;
  }

  @override
  void dispose() {
    _tiendaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: DropdownButtonFormField<String>(
        value: tiendaSeleccionada,
        decoration: InputDecoration(
          labelText: 'Selecciona una tienda',
          labelStyle: const TextStyle(fontSize: 16, color: Colors.black87),
          hintText: 'Ingresa una tienda para el producto',
          hintStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          prefixIcon: Icon(Icons.store, color: Colors.yellow),
          filled: true,
          fillColor: Colors.grey.shade100,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.yellow, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
        items: widget.nombresTienda.map((String tienda) {
          return DropdownMenuItem<String>(
            value: tienda,
            child: Text(tienda),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null && newValue != tiendaSeleccionada) {
            setState(() {
              tiendaSeleccionada = newValue;
            });
            widget.onTiendaSeleccionada(newValue);
          }
        },
        validator: widget.validator,
      ),
    );
  }
}
