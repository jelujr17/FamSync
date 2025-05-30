import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Variables para autenticación por teléfono
  String? _verificationId;
  //Completer<Map<String, dynamic>>? _phoneVerificationCompleter;

  // Añadir esta variable para web

  // Método mejorado de inicio de sesión
  Future<Map<String, dynamic>> login(String correo, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: correo,
        password: password,
      );
      return {
        'success': true,
        'user': result.user,
        'message': 'Inicio de sesión exitoso'
      };
    } on FirebaseAuthException catch (e) {
      String message = 'Error al iniciar sesión';

      switch (e.code) {
        case 'user-not-found':
          message = 'No existe una cuenta con este correo';
          break;
        case 'wrong-password':
          message = 'Contraseña incorrecta';
          break;
        case 'invalid-email':
          message = 'El formato del correo es inválido';
          break;
        case 'user-disabled':
          message = 'Esta cuenta ha sido deshabilitada';
          break;
        default:
          message = 'Error: ${e.message}';
      }

      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Error inesperado: $e'};
    }
  }

  // Método mejorado de registro

  // Método para enviar correo de recuperación de contraseña
  Future<Map<String, dynamic>> resetPassword(String correo) async {
    try {
      await _auth.sendPasswordResetEmail(email: correo);
      return {
        'success': true,
        'message': 'Se ha enviado un correo para restablecer tu contraseña'
      };
    } on FirebaseAuthException catch (e) {
      String message = 'Error al enviar correo';

      if (e.code == 'user-not-found') {
        message = 'No existe una cuenta con este correo';
      }

      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Error inesperado: $e'};
    }
  }

  // Método para iniciar autenticación por teléfono
  Future<Map<String, dynamic>> startPhoneAuthentication(
    String phoneNumber, {
    required Function(String verificationId) onCodeSent,
    required Function(PhoneAuthCredential credential) onVerificationCompleted,
    required Function(String message) onError,
  }) async {
    try {
      // En web, necesitamos manejar el flujo diferente
      ConfirmationResult confirmationResult =
          await _auth.signInWithPhoneNumber(phoneNumber);

      // Guardar el ID para verificación posterior
      _verificationId = confirmationResult.verificationId;

      // Notificar que el código fue enviado
      onCodeSent(_verificationId!);

      return {'success': true, 'message': 'Proceso de verificación iniciado'};
    } catch (e) {
      onError('Error inesperado: $e');
      return {'success': false, 'message': 'Error inesperado: $e'};
    }
  }

  // Método para verificar el código SMS recibido
  Future<Map<String, dynamic>> verifyPhoneCode(String smsCode) async {
    try {
      if (_verificationId == null) {
        return {
          'success': false,
          'message': 'No hay un proceso de verificación activo'
        };
      }

      // Crear credencial con el código recibido
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      // Iniciar sesión con la credencial
      final result = await _auth.signInWithCredential(credential);

      return {
        'success': true,
        'user': result.user,
        'message': 'Número de teléfono verificado correctamente'
      };
    } on FirebaseAuthException catch (e) {
      String message = 'Error al verificar el código';

      switch (e.code) {
        case 'invalid-verification-code':
          message = 'El código ingresado no es válido';
          break;
        case 'invalid-verification-id':
          message = 'ID de verificación inválido';
          break;
        default:
          message = 'Error: ${e.message}';
      }

      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Error inesperado: $e'};
    }
  }

  // Método para vincular teléfono a una cuenta existente
  Future<Map<String, dynamic>> linkPhoneToAccount(
    String phoneNumber, {
    required Function(String verificationId) onCodeSent,
    required Function(String message) onError,
  }) async {
    try {
      // Verificar que hay un usuario con sesión iniciada
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return {
          'success': false,
          'message': 'No hay un usuario con sesión iniciada'
        };
      }

      if (kIsWeb) {
        // Para web
        ConfirmationResult confirmationResult =
            await _auth.signInWithPhoneNumber(phoneNumber);

        _verificationId = confirmationResult.verificationId;
        onCodeSent(_verificationId!);
      } else {
        // Para móvil
        await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            try {
              await currentUser.linkWithCredential(credential);
              // Éxito automático
            } catch (e) {
              onError('Error al vincular teléfono: $e');
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            onError('Error en la verificación: ${e.message}');
          },
          codeSent: (String verificationId, int? resendToken) {
            _verificationId = verificationId;
            onCodeSent(verificationId);
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            _verificationId = verificationId;
          },
          timeout: const Duration(seconds: 60),
        );
      }

      return {'success': true, 'message': 'Proceso de verificación iniciado'};
    } catch (e) {
      onError('Error inesperado: $e');
      return {'success': false, 'message': 'Error inesperado: $e'};
    }
  }

  // Método para verificar y vincular teléfono
  Future<Map<String, dynamic>> verifyAndLinkPhone(String smsCode) async {
    try {
      if (_verificationId == null) {
        return {
          'success': false,
          'message': 'No hay un proceso de verificación activo'
        };
      }

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return {
          'success': false,
          'message': 'No hay un usuario con sesión iniciada'
        };
      }

      // Crear credencial con el código
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      // Vincular la credencial al usuario actual
      await currentUser.linkWithCredential(credential);

      return {'success': true, 'message': 'Teléfono vinculado correctamente'};
    } catch (e) {
      return {'success': false, 'message': 'Error al vincular teléfono: $e'};
    }
  }

  // Añade este método para el registro completo
  Future<Map<String, dynamic>> registerWithEmailAndPhone(
      String email, String password, String phoneNumber,
      {String? nombre}) async {
    print(
        '[Registro] Iniciando registro con email: $email y teléfono: $phoneNumber');
    try {
      // Paso 1: Crear cuenta con correo y contraseña
      print('[Registro] Creando usuario con email y contraseña...');
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      //iNICIALIZAR LAS COLECCIONES DE FIRESTORE
      print('[Registro] Usuario creado: ${user?.uid}');
      if (user != null) {
        final usuarioDoc =
            FirebaseFirestore.instance.collection('usuarios').doc(user.uid);
        print('[Registro] Guardando datos en Firestore...');
        await usuarioDoc.set({
          'nombre': nombre ?? '',
          'email': email,
          'phone': phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
        });

        crearColeccionPerfilesInicial(user.uid);
        print('[Registro] Datos guardados en Firestore');

        // Actualizar el nombre del usuario si se proporciona
        if (nombre != null && nombre.isNotEmpty) {
          print('[Registro] Actualizando displayName...');
          await user.updateDisplayName(nombre);
          await user.reload(); // Recargar para obtener los datos actualizados
        }
      }

      // --- COMENTADO: Lógica de registro y verificación de teléfono ---
      /*
      // Paso 2: Iniciar el proceso de vinculación con teléfono
      _phoneVerificationCompleter = Completer<Map<String, dynamic>>();

      if (kIsWeb) {
        // Para web
        print("[Registro] Iniciando verificación de teléfono: $phoneNumber en web");
        ConfirmationResult confirmationResult =
            await _auth.signInWithPhoneNumber(phoneNumber);

        _verificationId = confirmationResult.verificationId;
        print("[Registro] verificationId recibido: $_verificationId");

        // Retornar de inmediato con la información de verificación pendiente
        return {
          'success': true,
          'user': user,
          'requiresVerification': true,
          'verificationId': _verificationId,
          'message':
              'Usuario registrado. Se requiere verificación del teléfono.'
        };
      } else {
        print("[Registro] Iniciando verificación de teléfono en móvil");
        // Para móvil
        await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            print('[Registro] Verificación automática completada');
            // Auto-verificación completada (solo en algunos dispositivos Android)
            try {
              await user?.linkWithCredential(credential);
              if (!_phoneVerificationCompleter!.isCompleted) {
                _phoneVerificationCompleter!.complete({
                  'success': true,
                  'user': user,
                  'message': 'Registro y verificación completados'
                });
              }
            } catch (e) {
              print('[Registro] Error al vincular teléfono: $e');
              if (!_phoneVerificationCompleter!.isCompleted) {
                _phoneVerificationCompleter!.complete({
                  'success': false,
                  'message': 'Error al vincular teléfono: $e'
                });
              }
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            print('[Registro] Error en la verificación: ${e.message}');
            if (!_phoneVerificationCompleter!.isCompleted) {
              _phoneVerificationCompleter!.complete({
                'success': false,
                'message': 'Error en la verificación: ${e.message}'
              });
            }
          },
          codeSent: (String verificationId, int? resendToken) {
            print('[Registro] Código enviado, verificationId: $verificationId');
            _verificationId = verificationId;
            if (!_phoneVerificationCompleter!.isCompleted) {
              _phoneVerificationCompleter!.complete({
                'success': true,
                'user': user,
                'requiresVerification': true,
                'verificationId': verificationId,
                'message':
                    'Usuario registrado. Se requiere verificación del teléfono.'
              });
            }
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            print('[Registro] Timeout de auto-retrieval, verificationId: $verificationId');
            _verificationId = verificationId;
          },
          timeout: const Duration(seconds: 60),
        );

        // Esperar resultado de la verificación telefónica
        print('[Registro] Esperando resultado de la verificación telefónica...');
        return await _phoneVerificationCompleter!.future;
      }
      */
      // --- FIN COMENTADO ---

      // Solo retorna éxito del registro con correo
      return {
        'success': true,
        'user': user,
        'message': 'Usuario registrado correctamente (solo correo)'
      };
    } on FirebaseAuthException catch (e) {
      String message = 'Error al registrar';
      print(
          '[Registro][FirebaseAuthException] code: ${e.code}, message: ${e.message}');

      switch (e.code) {
        case 'email-already-in-use':
          message = 'Ya existe una cuenta con este correo';
          break;
        case 'invalid-email':
          message = 'El formato del correo es inválido';
          break;
        case 'weak-password':
          message = 'La contraseña es demasiado débil';
          break;
        default:
          message = 'Error1: ${e.code} - ${e.message}';
      }

      return {'success': false, 'message': message};
    } catch (e) {
      print('[Registro][Exception] $e');
      return {'success': false, 'message': 'Error inesperado: $e'};
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  // Stream para escuchar cambios en la autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();


  Future<void> crearColeccionPerfilesInicial(String uid) async {
  await FirebaseFirestore.instance
    .collection('usuarios')
    .doc(uid)
    .collection('perfiles')
    .doc('placeholder')
    .set({'init': true});
}

}
