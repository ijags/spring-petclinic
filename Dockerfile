# Use a Linux-based Java image
FROM eclipse-temurin:17-jdk-jammy

# Create a directory
WORKDIR /app

COPY target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
