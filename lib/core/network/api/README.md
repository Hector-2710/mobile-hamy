# API (api-hamy)

Carpeta reservada para elementos específicos de la API (p.ej. clientes/endpoints agrupados por recurso, DTOs generados desde OpenAPI en el futuro).

Base implementada en `core/network/`:
- `api_client.dart` — cliente Dio (base URL, auth interceptor, manejo 401)
- `api_endpoints.dart` — rutas `/api/v1/...` según `openapi.yaml`
- `api_exception.dart` — normalización de errores `{ error: { code, message } }`

Spec de referencia: `/home/hector/hamy/api-hamy/docs/openapi.yaml` (pendiente profundizar/generar modelos completos desde el spec).
