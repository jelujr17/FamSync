import 'package:famsync/Model/perfiles.dart';
import 'package:famsync/View/navegacion.dart';
import 'package:flutter/material.dart';

class VirtualAssistantPage extends StatefulWidget {
  final GlobalKey<NavigatorState>? navigatorKey;
  final Perfiles perfil;
  const VirtualAssistantPage(
      {super.key, required this.perfil, this.navigatorKey});

  @override
  _VirtualAssistantPageState createState() => _VirtualAssistantPageState();
}

class _VirtualAssistantPageState extends State<VirtualAssistantPage> {
  // Controlador de texto
  final TextEditingController _textController = TextEditingController();
  List<String> messages = []; // Lista para almacenar los mensajes del chat

  void _processCommand(String command) {
    // Simulación de procesamiento básico
    if (command.toLowerCase().contains("crear un evento")) {
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          messages.add("Yaya: He creado un evento basado en tu descripción.");
        });
      });
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          messages.add("Yaya: No entiendo ese comando. ¿Puedes reformularlo?");
        });
      });
    }
  }

  void _sendMessage(String message) {
    if (message.isNotEmpty) {
      setState(() {
        messages.add("Tú: $message");
      });

      // Simulación de la respuesta de Yaya
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          messages.add("Yaya: Estoy procesando tu mensaje...");
        });

        // Aquí puedes llamar a una función para procesar el mensaje
        _processCommand(message);
      });

      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yaya - Asistente Virtual"),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Área de chat (Lista de mensajes)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  bool isUserMessage = index % 2 == 0;
                  return Align(
                    alignment: isUserMessage
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: isUserMessage
                            ? Colors.blueAccent
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Text(
                        messages[index],
                        style: TextStyle(
                          color: isUserMessage ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Accesos Rápidos
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _quickActionButton(Icons.event, "Evento"),
                  _quickActionButton(Icons.shopping_cart, "Lista"),
                  _quickActionButton(Icons.calendar_today, "Calendario"),
                  _quickActionButton(Icons.help, "Ayuda"),
                ],
              ),
            ),
            // Barra de Entrada de Texto
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom +
                    8.0, // Altura de la barra
                left: 8.0,
                right: 8.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: "Escribe un mensaje...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blueAccent),
                    onPressed: () => _sendMessage(_textController.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      extendBody: true,
      bottomNavigationBar: CustomBottomNavBar(perfil: widget.perfil, pagina: 1, pageController: PageController(),),
    );
  }

  // Botón para Acciones Rápidas
  Widget _quickActionButton(IconData icon, String label) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.blueAccent),
          onPressed: () {
            _sendMessage("Abrir $label");
          },
        ),
        Text(label),
      ],
    );
  }
}
