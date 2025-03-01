FROM registry.access.redhat.com/ubi9/openjdk-21:1.17-2

WORKDIR /app

COPY /target/*.jar main.jar
COPY javaagent.jar .
COPY ./instrument.sh .

RUN ls -la

ENTRYPOINT ["bash", "instrument.sh"]

# CMD ["java","-jar","main.jar"]



# COPY opentelemetry-javaagent.jar .
# ENV JAVA_TOOL_OPTIONS "-javaagent:./opentelemetry-javaagent.jar"
# CMD ["java","-Dotel.javaagent.debug=true","-jar","main.jar"]clear
