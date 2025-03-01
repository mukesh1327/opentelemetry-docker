package com.zaga.kafka_example;
// import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

@Component
public class KafkaProducer {

    private final KafkaTemplate<String, String> kafkaTemplate;

    // @Value("${produce.topic.name}")
    // private String TOPIC_NAME;

    public KafkaProducer(KafkaTemplate<String, String> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }

    public void sendMessage(String message) {
        kafkaTemplate.send("kafkasrv", message);
        System.out.println("Message " + message +
             " has been sucessfully sent to the topic: " + "kafkasrv");
    }
}