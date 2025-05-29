// Nuevo archivo: VerificarCodigoScreen.dart
import 'package:famsync/Model/FirebaseAuthService.dart';
import 'package:famsync/View/Inicio/Seleccion_Perfil.dart';
import 'package:famsync/components/colores.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerificarCodigoScreen extends StatefulWidget {
  final String verificationId;
  final String email;
  final String telefono;
  final User usuario;
  
  const VerificarCodigoScreen({
    Key? key, 
    required this.verificationId,
    required this.email,
    required this.telefono,
    required this.usuario
  }) : super(key: key);
  
  @override
  _VerificarCodigoScreenState createState() => _VerificarCodigoScreenState();
}

class _VerificarCodigoScreenState extends State<VerificarCodigoScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificar teléfono'),
        backgroundColor: Colores.fondo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hemos enviado un código de verificación al número ${widget.telefono}',
              style: TextStyle(fontSize: 16, color: Colores.texto),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: TextStyle(color: Colores.texto),
              decoration: InputDecoration(
                labelText: 'Código de verificación',
                labelStyle: TextStyle(color: Colores.texto),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colores.fondoAux, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colores.texto, width: 2.0),
                ),
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: isLoading ? null : verificarCodigo,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colores.fondoAux,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? CircularProgressIndicator(color: Colores.texto)
                  : Text('Verificar', style: TextStyle(color: Colores.texto)),
            ),
          ],
        ),
      ),
    );
  }
  
  void verificarCodigo() async {
    setState(() {
      isLoading = true;
    });
    
    final authService = FirebaseAuthService();
    
    try {
      // Crear credencial con el código SMS
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _codeController.text.trim(),
      );
      
      // Vincular la credencial telefónica a la cuenta existente
      await widget.usuario.linkWithCredential(credential);
      
      // Guardar el UID
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('uid', widget.usuario.uid);
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Teléfono verificado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navegar a la pantalla de selección de perfil
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SeleccionPerfil(IdUsuario: int.parse(widget.usuario.uid)),
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      
      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al verificar el código: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}