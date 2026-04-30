FROM ballerina/ballerina:2201.12.0 AS build

WORKDIR /app
COPY . .
RUN bal build

FROM ballerina/jre21:v2

WORKDIR /app
COPY --from=build /app/target/bin/sse-0.1.0.jar app.jar

EXPOSE 8000

USER 10014

CMD ["java", "-jar", "app.jar"]
