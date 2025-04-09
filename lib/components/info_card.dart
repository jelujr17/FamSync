import 'package:famsync/components/colores.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.name,
    required this.bio,
  });

  final String name, bio;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colores.fondoAux,
        child: Icon(
          CupertinoIcons.person,
          color: Colores.fondoAux,
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(color: Colores.fondoAux),
      ),
      subtitle: Text(
        bio,
        style: const TextStyle(color: Colores.fondoAux),
      ),
    );
  }
}
