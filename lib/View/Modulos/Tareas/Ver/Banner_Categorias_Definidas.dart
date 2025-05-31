import 'package:famsync/Model/Perfiles.dart';
import 'package:famsync/View/Modulos/Tareas/Ver/Tareas_Filtradas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BannerCategoriasDefinidas extends StatelessWidget {
  const BannerCategoriasDefinidas(
      {super.key,
      required this.perfil,
      required this.titulo,
      required this.color,
      required this.iconSrc,
      required this.colorTexto,
      required this.descripcion,
      required this.cantidadTareas});

  final String titulo, iconSrc, descripcion;
  final Color color, colorTexto;
  final int cantidadTareas;
  final Perfiles perfil;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TareasFiltradas(
              perfil: perfil,
              filtro: titulo,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        height: 260,
        width: 260,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: colorTexto, // Asegúrate de que sea visible
              blurRadius: 12, // Aumenta el desenfoque para una sombra más suave
              offset: const Offset(0, 0), // Sombra uniforme en todos los lados
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 6, right: 8),
                child: Column(
                  children: [
                    // Título con tamaño de texto más grande
                    Text(
                      titulo,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: colorTexto,
                            fontWeight: FontWeight.w600,
                            fontSize: 22, // Tamaño aumentado
                          ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 8),
                      child: Text(
                        descripcion,
                        style: TextStyle(
                          color: colorTexto,
                          fontSize: 16, // Tamaño aumentado
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Cantidad de tareas con tamaño de texto más grande
                    Text(
                      "${cantidadTareas.toString()} tareas",
                      style: TextStyle(
                        color: colorTexto,
                        fontSize: 18, // Tamaño aumentado
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SvgPicture.string(iconSrc,
                color: colorTexto, height: 50, width: 50),
          ],
        ),
      ),
    );
  }
}
