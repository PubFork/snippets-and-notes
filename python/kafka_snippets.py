import kafka


# create kafka producer instance
def connect_kafka_producer():
    return kafka.KafkaProducer(bootstrap_servers=['192.168.11.111:9092', '192.168.11.111:9093', '192.168.11.111:9094'], api_version=(0, 10))


# publish a message in kafka
def publish_message(producer_instance, topic, key, value):
    key_bytes = bytes(key, encoding='utf-8')
    value_bytes = bytes(value, encoding='utf-8')
    producer_instance.send(topic, key=key_bytes, value=value_bytes)
    producer_instance.flush()
    print('Message published successfully.')


# instantiate producer and publish messages
producer = connect_kafka_producer()
publish_message(producer, 'the_test', 'foo', 'bar')
if producer is not None:
    producer.close()

# instantiate consumer and consume messages
consumer = kafka.KafkaConsumer('the_test', auto_offset_reset='earliest',
                               bootstrap_servers=['localhost:9092', '192.168.11.111:9093', '192.168.11.111:9094'],
                               api_version=(0, 10),
                               consumer_timeout_ms=1000)
for msg in consumer:
    print(msg.value)
consumer.close()
