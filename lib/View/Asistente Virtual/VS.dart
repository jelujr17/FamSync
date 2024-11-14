import 'package:flutter/material.dart';

class VirtualAssistantPage extends StatefulWidget {
  @override
  _VirtualAssistantPageState createState() => _VirtualAssistantPageState();
}

class _VirtualAssistantPageState extends State<VirtualAssistantPage> {
  // Controlador de texto
  final TextEditingController _textController = TextEditingController();
  List<String> messages = []; // Lista para almacenar los mensajes del chat

  // Método para agregar mensajes a la lista de chat
  void _sendMessage(String message) {
    if (message.isNotEmpty) {
      setState(() {
        messages.add(message);
      });
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Yaya - Asistente Virtual"),
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      body: Column(
        children: [
          // Área de chat (Lista de mensajes)
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                bool isUserMessage = index % 2 == 0;
                return Align(
                  alignment: isUserMessage
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4.0),
                    padding: EdgeInsets.all(10.0),
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
            padding: const EdgeInsets.all(8.0),
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
                  icon: Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: () => _sendMessage(_textController.text),
                ),
              ],
            ),
          ),
        ],
      ),
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
