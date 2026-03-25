# Imatge base Java
FROM eclipse-temurin:21-jdk
  
  # Directori de treball
WORKDIR /app
  
  # Copiar el jar
COPY target/*.jar app.jar
  
  # Exposar port
EXPOSE 8080
  
  # Executar app
ENTRYPOINT ["java", "-jar", "app.jar"]