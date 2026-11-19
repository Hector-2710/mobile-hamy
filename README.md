# mobile_hamy

App móvil Flutter de **Juntos**, cliente de [api-hamy](../api-hamy).

## Desarrollo

### 1. Levantar la API

```bash
cd ../api-hamy
docker compose up -d --build
```

Comprobar que responde:

```bash
curl http://localhost:8080/healthz
```

### 2. Ejecutar la app

```bash
flutter pub get
flutter run -d emulator-5554
```

La URL base se elige automáticamente según el destino:

| Destino | URL base |
| --- | --- |
| Emulador Android | `http://10.0.2.2:8080` |
| Dispositivo físico | `http://<IP-de-tu-PC>:8080` (pasarlo con `--dart-define`) |
| Web / desktop | `http://localhost:8080` |

En un dispositivo físico (o si el API corre en otro host/puerto):

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080
```

> El API publica el puerto `8080` en `0.0.0.0`, así que el dispositivo debe estar
> en la misma red que la PC y no debe haber un firewall bloqueando ese puerto.

### 3. Si aparece «No se pudo conectar con el servidor»

1. Verificar el contenedor: `docker ps | grep api-hamy-api` y
   `docker logs api-hamy-api`.
2. Verificar desde la PC: `curl http://localhost:8080/healthz`.
3. Verificar desde el emulador: `adb shell nc -z 10.0.2.2 8080` (debe salir
   `exit=0`). Si falla, revisar la red del AVD.
4. Recordar que dentro del emulador `localhost` **no** es la PC: usar
   `10.0.2.2` o un `--dart-define` explícito.
