import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SecondaryCourseCard extends StatelessWidget {
  const SecondaryCourseCard({
    super.key,
    required this.title,
    this.iconsSrc = "assets/icons/ios.svg",
    required this.colorl,
    required this.textColor,
    required this.onIconPressed, // Añadir el callback para el icono
  });

  final String title, iconsSrc;
  final Color colorl;
  final Color textColor;
  final VoidCallback onIconPressed; // Definir el callback para el icono

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
                const Text(
                  "Watch video - 15 mins",
                  style: TextStyle(
                    color: Colors.white60,
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
            child: SvgPicture.asset(iconsSrc),
          ),
        ],
      ),
    );
  }
}