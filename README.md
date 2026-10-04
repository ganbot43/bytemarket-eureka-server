# bytemarket-eureka-server

Registro de servicios (Netflix Eureka). Es el primero que hay que levantar: los demás se registran aquí y el gateway los descubre por nombre.

Parte del sistema **ByteMarket**, una tienda de repuestos y accesorios para
celulares construida con microservicios Spring Boot y un frontend Nuxt.

## Qué hace

Mantiene la lista de instancias vivas. El gateway resuelve `lb://bytemarket-catalog-service` consultando este registro, así que ningún servicio necesita saber en qué puerto o IP está otro.

Panel web en http://localhost:8761

No usa base de datos, ni S3, ni JWT, ni mensajería.

> **Si cambias de red o de wifi, reinicia los servicios.** Se registran con
> `prefer-ip-address`, así que guardan la IP que tenían al arrancar; si la
> máquina cambia de IP, el gateway intenta la vieja y se queda colgado.

## Cómo levantarlo

Requisitos: **Java 17+**. No usa base de datos ni depende de ningún otro
servicio: es el primero que hay que levantar.

```bash
cp .env.example .env     # y rellena los valores
./mvnw spring-boot:run
```

Queda escuchando en el puerto **8761**. Panel web en http://localhost:8761


## Configuración

Las credenciales se leen del `.env`, que **no se versiona**. Los
`application*.yml` solo traen marcadores: si falta el `.env`, los valores
sensibles quedan vacíos. Mira `.env.example` para saber qué rellenar.

> El `JWT_SECRET` debe ser **idéntico** en user, catalog, order y support:
> user-service firma el token y los demás verifican la firma. Si difieren,
> todas las peticiones autenticadas fallan con 401 sin dejar rastro en el log.

## El sistema completo

| Repositorio | Puerto | Función |
|---|---|---|
| `bytemarket-eureka-server` | 8761 | Registro de servicios |
| `bytemarket-api-gateway` | 8085 | Punto de entrada único; enruta a los demás |
| `bytemarket-user-service` | 8081 | Cuentas, autenticación JWT, perfiles |
| `bytemarket-catalog-service` | 8082 | Productos, categorías, banners, inventario |
| `bytemarket-order-service` | 8083 | Pedidos, métodos de pago, cupones, reportes |
| `bytemarket-support-service` | 8084 | Libro de reclamaciones |
| `frontend-bytemarket` | 3000 | Tienda y panel de administración (Nuxt 3) |

Orden de arranque: **Eureka primero**, luego los servicios de negocio, el
gateway al final y el frontend cuando el gateway responda.
