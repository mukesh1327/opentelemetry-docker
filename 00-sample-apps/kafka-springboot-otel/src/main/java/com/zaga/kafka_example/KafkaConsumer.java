package com.zaga.kafka_example;

import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Component
public class KafkaConsumer {

    @KafkaListener(topics = "kafkasrv", groupId = "kafka-group")
    public void consumeMessage(String message) {
        System.out.println("Received message: " + message);
    }
}
