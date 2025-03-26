import 'package:flutter/material.dart';

class SecondaryCourseCard extends StatelessWidget {
  const SecondaryCourseCard({
    super.key,
    required this.title,
    required this.cantidadTareas,
    required this.colorl,
    required this.textColor,
    required this.colorCategoria,
    required this.onIconPressed,
  });

  final String title;
  final int cantidadTareas;
  final Color colorl, textColor, colorCategoria;
  final VoidCallback onIconPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: colorl,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Tareas totales: $cantidadTareas",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 40,
            child: VerticalDivider(
              // thickness: 5,
              color: Colors.white70,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onIconPressed, // Definir la acción al presionar el icono
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorCategoria, // Color del rombo
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(
                    8), // Bordes redondeados para suavizar el rombo
              ),
              transform: Matrix4.translationValues(20, -10, 0) *
                  Matrix4.rotationZ(0.785398), // Mueve el rombo y lo rota
              alignment: Alignment.center,
              child: Transform.rotate(
                angle:
                    -0.785398, // Rota el ícono para que quede en su orientación normal
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: getContrastingTextColor(
                      colorCategoria), // Color del ícono
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color getContrastingTextColor(Color color) {
  // Calcula el brillo del color
  final double brightness =
      (color.red * 0.299 + color.green * 0.587 + color.blue * 0.114) / 255;

  // Si el brillo es alto, usa un color oscuro; de lo contrario, usa un color claro
  return brightness > 0.5 ? Colors.black : Colors.white;
}
