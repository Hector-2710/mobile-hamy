import 'api_exception.dart';

/// Traduce errores de api-hamy (fuera del flujo de login) a mensajes claros
/// en español.
///
/// La API devuelve sus mensajes en inglés; aquí se mapean los códigos y los
/// mensajes conocidos del servicio a textos comprensibles.
String localizedApiError(Object error) {
  if (error is ApiException) {
    final status = error.statusCode;
    final raw = error.message.toLowerCase();

    if (error.isUnauthorized) {
      return 'Tu sesión ha caducado. Entra de nuevo para continuar.';
    }
    if (error.isForbidden) {
      return 'No tienes permisos para esta acción.';
    }
    if (error.isNotFound) {
      return 'No se encontró lo que buscabas.';
    }
    if (error.isConflict) {
      return 'Eso ya existe o entra en conflicto con el álbum.';
    }
    if (status == 400 || status == 422 || error.isInvalid) {
      if (raw.contains('must have an account')) {
        return 'Ese correo no tiene cuenta en hamy todavía. Debe registrarse '
            'primero.';
      }
      if (raw.contains('provide exactly one') ||
          raw.contains('provide user_id')) {
        return 'Escribe un correo electrónico válido.';
      }
      if (raw.contains('size must be')) {
        return 'La foto pesa demasiado: el máximo son 25 MB.';
      }
      if (raw.contains('filename') || raw.contains('content_type')) {
        return 'Ese archivo no parece una foto válida.';
      }
      if (raw.contains('owner cannot leave')) {
        return 'El álbum necesita dueño: elimínalo o pásaselo a otra persona '
            'antes de salir.';
      }
      if (raw.contains('title')) {
        return 'El título del álbum es obligatorio.';
      }
      return 'Revisa los datos e inténtalo de nuevo.';
    }
    if (status != null && status >= 500) {
      return 'Error del servidor. Intenta de nuevo en unos segundos.';
    }
    return error.message;
  }

  return 'No se pudo completar la acción. Revisa tu conexión e inténtalo de '
      'nuevo.';
}
