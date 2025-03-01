OTEL_EXPORTER=otlp
OTEL_EXPORTER_ENDPOINT=http://localhost:4317
OTEL_SERVICE_NAME=kafka-sample-app

java  -javaagent:javaagent.jar  -Dotel.logs.exporter=${OTEL_EXPORTER} -Dotel.metrics.exporter=${OTEL_EXPORTER} -Dotel.traces.exporter=${OTEL_EXPORTER} -Dotel.exporter.otlp.endpoint=${OTEL_EXPORTER_ENDPOINT} -Dotel.service.name=${OTEL_SERVICE_NAME} -jar main.jar