import 'package:dio/dio.dart';

/// Excepción normalizada a partir de respuestas de api-hamy.
/// Formato esperado: { "error": { "code": "...", "message": "..." } }
class ApiException implements Exception {
  const ApiException({required this.message, this.code, this.statusCode});

  final String message;
  final String? code;
  final int? statusCode;

  bool get isUnauthorized => statusCode == 401 || code == 'unauthorized';
  bool get isForbidden => statusCode == 403 || code == 'forbidden';
  bool get isNotFound => statusCode == 404 || code == 'not_found';
  bool get isConflict => statusCode == 409 || code == 'conflict';
  bool get isInvalid => statusCode == 422 || code == 'invalid';

  factory ApiException.fromDioException(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      final err = data['error'];
      if (err is Map<String, dynamic>) {
        return ApiException(
          message: (err['message'] as String?) ?? _fallbackMessage(statusCode),
          code: err['code'] as String?,
          statusCode: statusCode,
        );
      } else if (err is String && err.isNotEmpty) {
        return ApiException(
          message: err,
          statusCode: statusCode,
        );
      } else if (data['message'] is String && (data['message'] as String).isNotEmpty) {
        return ApiException(
          message: data['message'] as String,
          code: data['code'] as String?,
          statusCode: statusCode,
        );
      }
    } else if (data is String && data.isNotEmpty) {
      return ApiException(
        message: data,
        statusCode: statusCode,
      );
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'La conexión tardó demasiado. Intenta de nuevo.',
          statusCode: statusCode,
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'No se pudo conectar con el servidor.',
        );
      case DioExceptionType.cancel:
        return const ApiException(message: 'Solicitud cancelada.');
      case DioExceptionType.badCertificate:
        return const ApiException(message: 'Certificado no válido.');
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        return ApiException(
          message: _fallbackMessage(statusCode),
          statusCode: statusCode,
        );
      default:
        return ApiException(
          message: _fallbackMessage(statusCode),
          statusCode: statusCode,
        );
    }
  }

  static String _fallbackMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Solicitud inválida.';
      case 401:
        return 'Necesitas iniciar sesión.';
      case 403:
        return 'No tienes permisos para esta acción.';
      case 404:
        return 'No se encontró el recurso.';
      case 409:
        return 'Conflicto con el estado actual.';
      case 422:
        return 'Datos inválidos.';
      case 500:
      case 502:
      case 503:
        return 'Error del servidor. Intenta más tarde.';
      default:
        return 'Ocurrió un error inesperado.';
    }
  }

  @override
  String toString() =>
      'ApiException(code: $code, status: $statusCode, message: $message)';
}
