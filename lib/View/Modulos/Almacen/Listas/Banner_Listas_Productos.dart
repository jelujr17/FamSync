
import 'package:famsync/Model/Almacen/listas.dart';
import 'package:famsync/Model/Almacen/producto.dart';
import 'package:famsync/View/Modulos/Almacen/Listas/Ventana_Lista.dart';
import 'package:flutter/material.dart';

class ListasBanner extends StatefulWidget {
  final List<Listas> listas;
  final List<Productos> productos;

  const ListasBanner({
    super.key,
    required this.listas,
    required this.productos,
  });

  @override
  _ListasBannerState createState() => _ListasBannerState();
}

class _ListasBannerState extends State<ListasBanner> {
  void actualizarBanner() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String titulo =
        widget.listas.isNotEmpty ? "Tus listas:" : "No tienes listas aún";
    String contenido = widget.listas.isNotEmpty
        ? widget.listas.map((e) => e.Nombre).join(", ")
        : "¡Crea una nueva!";

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return VentanaListas(
              listas: widget.listas,
              productos: widget.productos,
              actualizarBanner: actualizarBanner,
            );
          },
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF4A3298),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text.rich(
          TextSpan(
            style: const TextStyle(color: Colors.white),
            children: [
              TextSpan(text: "$titulo\n"),
              TextSpan(
                text: contenido,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}