# ===== Build Stage =====
FROM maven:3.9.9-eclipse-temurin-17 AS build

WORKDIR /app

# Copy pom.xml first to leverage caching
COPY pom.xml .

# Pre-download dependencies
RUN mvn -B -q -DskipTests dependency:go-offline

# Copy project source
COPY src ./src

# Build the JAR (skip tests)
RUN mvn -B clean package -DskipTests



# ===== Runtime Stage =====
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Update Alpine OS packages (reduce vulnerabilities)
RUN apk update && apk upgrade

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy built jar
COPY --from=build /app/target/*.jar app.jar

# Change ownership
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8080

# Use JVM flags for memory optimization (optional)
ENTRYPOINT ["java", "-jar", "app.jar"]
