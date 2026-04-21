# Construcción y caché de dependencias
FROM eclipse-temurin:17-jdk-alpine AS builder
WORKDIR /app

# Fix: Copiamos únicamente el pom.xml y dependencias para optimizar el caché de capas
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
RUN ./mvnw dependency:go-offline -B

COPY src src
RUN ./mvnw clean package -DskipTests

# TODO: Implementar un usuario no-root en la imagen final por políticas de seguridad de AWS
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

COPY --from=builder /app/target/lp-pedidos-*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]