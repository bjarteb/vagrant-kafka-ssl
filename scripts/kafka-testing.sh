
# wurstmeister: list topics
#sudo docker run -ti --rm wurstmeister/kafka:0.10.2.1 \
#  sh -c "/opt/kafka_2.12-0.10.2.1/bin/kafka-topics.sh \
#  --list \
#  --zookeeper 10.0.21.11:2181"

sudo docker run --net host -ti --rm bjarteb/kafka:2.12-2.1.1 \
  sh -c "/kafka/bin/kafka-topics.sh \
  --list \
  --zookeeper k1.kafka.example.com:2181"

# wurstmeister: create topic 'test'
#sudo docker run -ti --rm wurstmeister/kafka:0.10.2.1 \
#  sh -c "/opt/kafka_2.12-0.10.2.1/bin/kafka-topics.sh --create \
#  --topic test \
#  --zookeeper 10.0.21.11:2181 \
#  --partitions 1 \
#  --replication-factor 3"

sudo docker run --net host -ti --rm bjarteb/kafka:2.12-2.1.1 \
  sh -c "/kafka/bin/kafka-topics.sh --create \
  --topic test \
  --zookeeper k1.kafka.example.com:2181 \
  --partitions 1 \
  --replication-factor 3"

# wurstmeister: fire up a pod and create a consumer on topic "test"
#sudo docker run -ti --rm wurstmeister/kafka:0.10.2.1 \
#  sh -c "/opt/kafka_2.12-0.10.2.1/bin/kafka-console-consumer.sh \
#  --topic test \
#  --bootstrap-server k1.kafka.example.com:9092 \
#  --from-beginning"

sudo docker run --net host \
  -v /vagrant/client-ssl.properties:/tmp/client-ssl.properties \
  -v /vagrant:/var/private/ssl \
  -ti --rm bjarteb/kafka:2.12-2.1.1 \
  sh -c "/kafka/bin/kafka-console-consumer.sh \
  --topic test \
  --bootstrap-server k1.kafka.example.com:9092 \
  --from-beginning \
  --consumer.config /tmp/client-ssl.properties"

# wurstmeister: fire up a pod and create a producer on topic "test"
#sudo docker run --net host -ti --rm wurstmeister/kafka:0.10.2.1 \
#  sh -c "/opt/kafka_2.12-0.10.2.1/bin/kafka-console-producer.sh \
#  --topic test \
#  --broker-list 10.0.21.11:9092,10.0.21.12:9092,10.0.21.13:9092"

sudo docker run --net host \
  -v /vagrant/client-ssl.properties:/tmp/client-ssl.properties \
  -v /vagrant:/var/private/ssl \
  -ti --rm bjarteb/kafka:2.12-2.1.1 \
  sh -c "/kafka/bin/kafka-console-producer.sh \
  --topic test \
  --broker-list k1.kafka.example.com:9092,k2.kafka.example.com:9092,k3.kafka.example.com:9092 \
  --producer.config /tmp/client-ssl.properties"


# Publish
kafkacat -b 192.168.1.2:32000,192.168.1.2:32001 -P -t test

# Consume
kafkacat -b 192.168.1.2:32000,192.168.1.2:32001 -C -t test
