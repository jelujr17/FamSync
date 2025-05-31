import 'package:famsync/Model/Perfiles.dart';
import 'package:famsync/Provider/Listas_Provider.dart';
import 'package:famsync/Provider/Productos_Provider.dart';
import 'package:famsync/View/Modulos/Almacen/Listas/Ventana_Lista.dart';
import 'package:famsync/components/colores.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListasBanner extends StatefulWidget {
  final Perfiles perfil;

  const ListasBanner({
    super.key,
    required this.perfil,
  });

  @override
  _ListasBannerState createState() => _ListasBannerState();
}

class _ListasBannerState extends State<ListasBanner> {
      final user = FirebaseAuth.instance.currentUser;

  void actualizarBanner() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productoProvider =
          Provider.of<ProductosProvider>(context, listen: false);
      productoProvider.cargarProductos(user!.uid, widget.perfil.PerfilID);

      final listasProvider =
          Provider.of<ListasProvider>(context, listen: false);
      listasProvider.cargarListas(user!.uid, widget.perfil.PerfilID);
    });
  }

  @override
  Widget build(BuildContext context) {
    final listasProvider = Provider.of<ListasProvider>(context, listen: false);
    final productoProvider =
        Provider.of<ProductosProvider>(context, listen: false);
    String titulo = listasProvider.listas.isNotEmpty
        ? "Tus listas:"
        : "No tienes listas aún";
    String contenido = listasProvider.listas.isNotEmpty
        ? listasProvider.listas.map((e) => e.nombre).join(", ")
        : "¡Crea una nueva!";

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return VentanaListas(
              actualizarBanner: actualizarBanner,
              perfil: widget.perfil,
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
          color: Colores.texto,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text.rich(
          TextSpan(
            style: const TextStyle(color: Colores.fondoAux),
            children: [
              TextSpan(text: "$titulo\n"),
              TextSpan(
                text: contenido,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colores.fondo),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
