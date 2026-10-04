# Etapa de construcción (Build)
FROM --platform=$BUILDPLATFORM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app
# Copiar el pom.xml y descargar dependencias (optimización de caché de Docker)
COPY pom.xml .
COPY .mvn .mvn
COPY mvnw .
RUN chmod +x ./mvnw || true
RUN ./mvnw dependency:go-offline -B || mvn dependency:go-offline -B

# Copiar el código fuente y compilar
COPY src src
RUN ./mvnw package -DskipTests || mvn package -DskipTests

# Etapa de ejecución (Run)
FROM eclipse-temurin:17-jre
WORKDIR /app
# Copiar solo el jar compilado desde la etapa de construcción
COPY --from=build /app/target/*.jar app.jar

# Exponer el puerto por defecto de este servicio (será mapeado en docker-compose)
EXPOSE 8080

# Comando para ejecutar la aplicación
ENTRYPOINT ["java", "-jar", "app.jar"]
