#!/bin/bash

# List of ports to check
PORTS=(8082 9000 2121 9092 4317 4318)

# List of container names to remove
CONTAINERS=(
    confluent-kafka_zookeeper
    confluent-kafka_broker
    kafdrop
    otel-collector
)

echo "Runnning PoC 1 - Opentelemetry kafka in docker with an example springboot application"
echo ""

########################################################

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

########################################################


# Function to check if a port is in use
is_port_in_use() {
    local port=$1
    # Check using lsof, ss, or netstat
    if lsof -i :$port > /dev/null 2>&1; then
        return 0  # Port is in use
    fi
    return 1  # Port is not in use
}

# Function to check all ports in the list
check_ports() {
    for port in "${PORTS[@]}"; do
        if is_port_in_use "$port"; then
            echo "Port $port is in use. Exiting the script."
            exit 0
        fi
    done
}

########################################################

run_poc1(){

# Determine which compose tool to use
if command_exists podman-compose; then
    TOOL="podman-compose"
elif command_exists docker-compose; then
    TOOL="docker-compose"
else
    echo "Error: Neither podman-compose nor docker-compose is installed."
    exit 1
fi

# Output the chosen tool
echo "Using $TOOL"

# Run the appropriate command
case $TOOL in
    podman-compose)
        podman-compose up -d
        ;;
    docker-compose)
        docker-compose up -d
        ;;
esac

}


########################################################

sample_app(){

OTEL_EXPORTER=otlp
OTEL_EXPORTER_ENDPOINT=http://localhost:4317
OTEL_SERVICE_NAME=kafka-sample-app

java  -javaagent:sample-application/javaagent.jar  -Dotel.logs.exporter=${OTEL_EXPORTER} -Dotel.metrics.exporter=${OTEL_EXPORTER} -Dotel.traces.exporter=${OTEL_EXPORTER} -Dotel.exporter.otlp.endpoint=${OTEL_EXPORTER_ENDPOINT} -Dotel.service.name=${OTEL_SERVICE_NAME} -jar sample-application/main.jar

}

##########################################################

# Function to generate a random item from a list
random_item() {
    local list=("$@")
    echo "${list[RANDOM % ${#list[@]}]}"
}

# Function to send random data
collect_test_data() {
    # Lists of names and countries
    local names=("Alice" "Bob" "Charlie" "David" "Eve")
    local countries=("USA" "India" "Canada" "Germany" "Australia")

    # Generate random name and country
    local name=$(random_item "${names[@]}")
    local country=$(random_item "${countries[@]}")

    # Prepare JSON data
    local json_data=$(printf '{"name": "%s", "country": "%s"}' "$name" "$country")

    # Send the data using curl
    curl --location 'http://localhost:8082/send' \
         --header 'Content-Type: application/json' \
         --data "$json_data"

    # Output the generated data for debugging
    echo "Sent data: $json_data"
}

##################################################

# Function to stop and remove a container
remove_containers() {
    local container_name=$1
    echo ""
    echo "Stopping container $container_name..."
    podman stop "$container_name" 2>/dev/null

    echo ""
    echo "Removing container $container_name..."
    podman rm --force "$container_name" 2>/dev/null

    # Check if the container is still running or exists
    if podman ps -a --filter "name=$container_name" --format "{{.Names}}" | grep -q "$container_name"; then
        echo "Failed to remove container $container_name. It may still be running or exist in an unexpected state."
    else
        echo "Container $container_name removed successfully."
    fi
}

##################################################

exit_cleanup(){
    echo "Running cleanup tasks..."

    # Stop and remove each specified container
    for container in "${CONTAINERS[@]}"; do
        remove_containers "$container"
    done

    # Kill processes running on specified ports
    for port in "${PORTS[@]}"; do
        PID=$(lsof -t -i :$port)
        if [ -n "$PID" ]; then
            echo "Killing process $PID running on port $port."
            kill "$PID"
        fi
    done

    echo "Cleanup completed."
}



##########################################################

check_ports
echo "No specified ports are in use. Continuing script execution."
echo ""

echo "starting docker-compose"
echo ""
run_poc1


sleep 8

echo "Opening kafdrop in browser"
echo ""
firefox http://localhost:9000 &

sleep 2

echo "starting sample application"
echo ""
sample_app &

sleep 20

echo "starting telemetry data collection"
echo ""
collect_test_data &


# Trap SIGINT (Ctrl+C) to run the cleanup function
trap 'exit_cleanup; exit' INT TERM ERR

wait