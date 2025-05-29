import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Variables para autenticación por teléfono
  String? _verificationId;
  int? _resendToken;
  Completer<Map<String, dynamic>>? _phoneVerificationCompleter;

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
  Future<Map<String, dynamic>> register(String correo, String password,
      {String? nombre}) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: correo,
        password: password,
      );

      // Actualizar el nombre del usuario si se proporciona
      if (nombre != null && nombre.isNotEmpty) {
        await result.user?.updateDisplayName(nombre);
        // Recargar usuario para obtener datos actualizados
        await result.user?.reload();
      }

      // Enviar correo de verificación (opcional)
      await result.user?.sendEmailVerification();

      return {
        'success': true,
        'user': _auth.currentUser, // Obtener usuario actualizado
        'message': 'Cuenta creada exitosamente'
      };
    } on FirebaseAuthException catch (e) {
      String message = 'Error al registrar';

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
        case 'operation-not-allowed':
          message = 'El registro con correo/contraseña no está habilitado';
          break;
        default:
          message = 'Error: ${e.message}';
      }

      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Error inesperado: $e'};
    }
  }

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
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verificación en algunos dispositivos Android
          onVerificationCompleted(credential);

          // Intentar iniciar sesión automáticamente
          try {
            final result = await _auth.signInWithCredential(credential);
            // Puedes manejar el resultado aquí si lo necesitas, pero no retornes un Map
            // Por ejemplo, podrías llamar a un callback o simplemente no hacer nada
          } catch (e) {
            onError('Error en verificación automática: $e');
            // No retornes un Map aquí
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          String message = 'Error en la verificación';

          switch (e.code) {
            case 'invalid-phone-number':
              message = 'El número de teléfono no es válido';
              break;
            case 'too-many-requests':
              message = 'Demasiados intentos. Inténtalo más tarde.';
              break;
            default:
              message = 'Error: ${e.message}';
          }

          onError(message);
        },
        codeSent: (String verificationId, int? resendToken) {
          // Guardar el ID de verificación para usarlo después
          _verificationId = verificationId;
          _resendToken = resendToken;

          // Notificar a la UI que el código ha sido enviado
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Actualizar el ID de verificación si el tiempo de recuperación automática expira
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
      );

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

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Intentar vincular teléfono automáticamente
          try {
            await currentUser.linkWithCredential(credential);
            // Puedes notificar el éxito usando un callback si lo deseas
          } catch (e) {
            onError('Error al vincular teléfono: $e');
            // Maneja el error, pero no retornes un Map aquí
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          onError('Error: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );

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
    try {
      // Paso 1: Crear cuenta con correo y contraseña
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;

      // Actualizar el nombre del usuario si se proporciona
      if (nombre != null && nombre.isNotEmpty && user != null) {
        await user.updateDisplayName(nombre);
        await user.reload(); // Recargar para obtener los datos actualizados
      }

      // Paso 2: Iniciar el proceso de vinculación con teléfono
      _phoneVerificationCompleter = Completer<Map<String, dynamic>>();

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Automáticamente vincula el teléfono en algunos dispositivos Android
          try {
            await user?.linkWithCredential(credential);
            _phoneVerificationCompleter!.complete({
              'success': true,
              'user': user,
              'message': 'Cuenta creada y teléfono vinculado automáticamente',
              'requiresVerification': false
            });
          } catch (e) {
            _phoneVerificationCompleter!.complete({
              'success': false,
              'message': 'Error al vincular teléfono: $e',
            });
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          _phoneVerificationCompleter!.complete({
            'success': false,
            'user': user, // La cuenta con correo sí se creó
            'message': 'Error en verificación de teléfono: ${e.message}',
            'requiresVerification': false
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;

          _phoneVerificationCompleter!.complete({
            'success': true,
            'user': user,
            'message': 'Se envió un código a tu teléfono para verificación',
            'requiresVerification': true,
            'verificationId': verificationId
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );

      // Esperar resultado de la verificación telefónica
      return await _phoneVerificationCompleter!.future;
    } on FirebaseAuthException catch (e) {
      String message = 'Error al registrar';

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
          message = 'Error: ${e.message}';
      }

      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Error inesperado: $e'};
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  // Stream para escuchar cambios en la autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
