# syntax=docker/dockerfile:1
# build stage
# FROM gradle:7.2.0-jdk8 AS TEMP_BUILD_IMAGE

#WORKDIR /app
#COPY build.gradle settings.gradle ./
#COPY src
#RUN gradle --no-daemon build --stacktrace

# ARG DEPENDENCY=build/dependency
# COPY ${DEPENDENCY}/BOOT-INF/lib /app/lib
# COPY ${DEPENDENCY}/META-INF /app/META-INF
# COPY ${DEPENDENCY}/BOOT-INF/classes /app

#run stage
#FROM openjdk:8-alpine

#WORKDIR /app
#COPY --from=TEMP_BUILD_IMAGE build/libs/spring-boot-docker-0.0.1-SNAPSHOT.jar .
#RUN addgroup -S spring && adduser -S spring -G spring
#USER spring:spring
#ENTRYPOINT ["java","-cp","app:app/lib/*","hello.Application"] 

FROM gradle:jdk13 AS builder
WORKDIR /app
COPY build.gradle settings.gradle ./
COPY src/ src/
RUN gradle --no-daemon build --stacktrace

FROM openjdk:jre-alpine
WORKDIR /app
ENV JAR spring-boot-docker-*.jar
COPY --from=builder /app/build/libs/$JAR ./app.jar
ENV PORT 8080
EXPOSE $PORT
HEALTHCHECK --timeout=5s --start-period=5s --retries=1 \
    CMD curl -f http://localhost:$PORT/health_check
ENTRYPOINT ["java", "-jar", "app.jar"]