import 'dart:math';

import 'package:famsync/Model/Almacen/producto.dart';
import 'package:famsync/Model/Almacen/Tiendas.dart';
import 'package:famsync/Model/Perfiles.dart';
import 'package:famsync/View/Modulos/Almacen/almacen.dart';
import 'package:flutter/material.dart';

class ProductosPorTienda extends StatefulWidget {
  final Tiendas tienda;
  final List<Productos> productos;
  final Function(Productos) onTap;
  final Perfiles perfil;

  const ProductosPorTienda({
    super.key,
    required this.tienda,
    required this.productos,
    required this.onTap,
    required this.perfil,
  });

  @override
  State<ProductosPorTienda> createState() => _ProductosPorTiendaState();
}

class _ProductosPorTiendaState extends State<ProductosPorTienda> {
  late int cantidad;
  bool pulsado = true;

  @override
  void initState() {
    super.initState();
    cantidad = min(
        4, widget.productos.length); // Se calcula antes de construir el widget
  }

  @override
  void didUpdateWidget(ProductosPorTienda oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productos != widget.productos) {
      setState(() {
        cantidad = min(4, widget.productos.length);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionTitle(
              titulo: widget.tienda.nombre,
              accion: () {
                setState(() {
                  if (pulsado) {
                    cantidad = widget.productos.length;
                  } else {
                    cantidad = min(4, widget.productos.length);
                  }
                  pulsado = !pulsado;
                });
              },
              pulsado: pulsado),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cantidad,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 20,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (context, index) {
              return ProductoCard(
                  producto: widget.productos[index],
                  onTap: () => widget.onTap(widget.productos[index]),
                  perfil: widget.perfil);
            },
          ),
        ),
      ],
    );
  }
}
