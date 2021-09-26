FROM gradle:jdk13 AS builder
WORKDIR /app
COPY build.gradle settings.gradle ./
COPY src/ src/
RUN ["gradle", "--no-daemon", "build", "--stacktrace"]

FROM openjdk:jre-alpine
WORKDIR /app
ENV JAR spring-boot-docker-*.jar
COPY --from=builder /app/build/libs/$JAR ./app.jar
ENV PORT 8080
EXPOSE $PORT
HEALTHCHECK --timeout=5s --start-period=5s --retries=1 \
    CMD ["curl", "-f", "http://localhost:$PORT/health_check"]
ENTRYPOINT ["java", "-jar", "app.jar"]