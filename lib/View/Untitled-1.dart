import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Selector de Avatar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AvatarSelectionPage(),
    );
  }
}

class AvatarSelectionPage extends StatefulWidget {
  @override
  _AvatarSelectionPageState createState() => _AvatarSelectionPageState();
}

class _AvatarSelectionPageState extends State<AvatarSelectionPage> {
  int selectedAvatarIndex = 0;

  final List<String> avatarImages = [
    'assets/images/main.png',
    'assets/avatar2.png',
    'assets/avatar3.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona tu Avatar'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Selecciona un avatar:',
            style: TextStyle(fontSize: 18),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Cambiado a 2 para mostrar dos avatares por fila
                crossAxisSpacing: 40,
                mainAxisSpacing: 30,
              ),
              padding: const EdgeInsets.all(75),
              itemCount: avatarImages.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedAvatarIndex = index;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selectedAvatarIndex == index
                            ? Colors.blue
                            : Colors.transparent,
                        width: 3,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        avatarImages[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                // Aquí puedes manejar lo que sucede cuando se selecciona un avatar
                print('Avatar seleccionado: ${avatarImages[selectedAvatarIndex]}');
              },
              child: const Text('Confirmar selección'),
            ),
          ),
        ],
      ),
    );
  }
}
