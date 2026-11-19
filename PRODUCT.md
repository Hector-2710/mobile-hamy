# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

## Users

Una pareja: dos personas que quieren un álbum privado de su vida juntos. Lo usan en el móvil en dos momentos distintos:

- **Capturar**: en el sitio y en el momento (una playa, una comida, una tarde cualquiera), con el móvil en la mano.
- **Revivir**: más tarde, recorriendo el archivo por meses para reencontrarse con momentos pequeños que no quieren olvidar.

Hablantes de español (España): la interfaz, la voz y las fechas son `es-ES`. Ambas personas tienen el mismo derecho sobre el álbum compartido.

## Product Purpose

Juntos convierte momentos cotidianos de una pareja en un archivo privado de recuerdos con título. El éxito es que añadir un recuerdo cueste segundos y que la pareja vuelva a abrir el álbum para recorrerlo, no solo para subir fotos.

## Positioning

Un álbum privado de dos personas, no una red social ni un almacén de archivos. La foto se guarda como **recuerdo con título**, con fecha, hora y ubicación adjuntas automáticamente, y el archivo se lee como una cronología por meses. Un producto vecino puede copiar la rejilla de fotos; no puede copiar el modelo "dos personas, un álbum, recuerdos con nombre".

## Operating Context

- App Flutter (`lib/`) cliente de la API `api-hamy` (Go + Postgres + MinIO), con subida directa a MinIO mediante URLs prefirmadas.
- Desarrollo local: `docker compose up` levanta la API en `localhost:8080`; el emulador Android la alcanza en `10.0.2.2:8080`.
- Sesión autenticada con JWT guardado en `flutter_secure_storage`.
- El álbum se comparte por invitación: la persona invitada debe tener ya una cuenta.
- Roles del backend: `owner`, `editor`, `viewer`; las invitaciones pasan de `invited` a `active`.

## Capabilities and Constraints

- **Alcance confirmado del cliente**: cliente multi-álbum completo: lista de álbumes, crear/editar, portada, miembros, invitaciones y roles, además de la cronología de fotos.
- **Estado actual**: la pantalla de recuerdos usa datos semilla (`SeedMemories`) y el guardado responde "Guardado pendiente: se conectará con la API más adelante". Login y registro ya hablan con la API.
- **Plataformas**: Android e iOS con una única interfaz Material (sin adaptación Cupertino), por decisión de producto. El emulador Android es el objetivo principal de desarrollo.
- **Medios**: `image/jpeg`, `image/png`, `image/webp`, `image/gif`, `image/heic`, `image/avif`; máximo 25 MiB por foto.
- **Privacidad**: sin acceso a un álbum la API responde 404, de modo que no revela su existencia. Borrado lógico de usuarios, álbumes y fotos.
- **Terminología de producto**: "recuerdo" (una foto con título), "momento", "nuestro álbum", "álbum compartido".
- **Sin decidir**: notificaciones, funcionamiento sin conexión, exportación del álbum y cualquier mecánica social fuera de la pareja.

## Brand Commitments

- Nombre: **Juntos** (repositorio `mobile_hamy`).
- Idioma y voz: español de España, íntima y cálida, en minúscula y sin jerga técnica; frases como "Nuestra vida, en fotos" o "Pequeños momentos que siempre querremos recordar" son la referencia de tono.
- Logotipo existente: `lib/logo.jpeg`, mostrado por `lib/core/widgets/app_logo.dart`.
- La pareja se representa con dos avatares (iniciales superpuestas), no con una sola cuenta protagonista.

## Evidence on Hand

- `api-hamy` con API funcional, migraciones, datos demo (`ana@example.com`, `luis@example.com`, `marta@example.com`, contraseña `demo-password`) y smoke test end-to-end.
- Cuatro recuerdos semilla en `lib/features/memories/domain/entities/memory.dart`, con fotos de Unsplash y ubicaciones españolas. **No son contenido real de usuarios.**
- El prototipo `mvp/` (React + Vite, Figma Make) es la referencia funcional del flujo de captura y detalle.
- Ausencias que el trabajo futuro no debe inventar: no hay usuarios reales, testimonios, métricas de uso, prensa ni clientes. El logo es el único activo de marca confirmado.

## Product Principles

1. **Dos personas, un álbum.** Cada superficie asume una pareja con los mismos derechos sobre su álbum; las mecánicas de grupo o de red social quedan fuera.
2. **Capturar en segundos.** Añadir un recuerdo cuesta como mucho un título; la fecha, la hora y la ubicación se adjuntan solas.
3. **Recuerdos, no archivos.** Títulos y momentos organizan el archivo; nombres de archivo, carpetas y metadatos técnicos no se muestran.
4. **La cronología es la columna vertebral.** El álbum se lee como una vida ordenada por meses, no como una rejilla de miniaturas intercambiables.
5. **Privacidad por defecto.** Lo que no se comparte no existe para nadie más; nada es público salvo que se invite explícitamente.
