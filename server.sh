# Command to kill ports
kill -9 $(lsof -i tcp:9092,8080,2181)

# Command to run Zookeeper
./bin/zookeeper-server-start.sh config/zookeeper.properties

# Command to run Server
./bin/kafka-server-start.sh config/server.properties

# Command to run standalone server
./bin/connect-standalone.sh config/connect-standalone.properties

# Create a topic "testtopic"
./bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 3 --topic testtopic --if-not-exists

# Command to check for the list of topics
./bin/kafka-topics.sh --bootstrap-server localhost:9092 --list

# Command to delete topic
./bin/kafka-topics.sh --bootstrap-server localhost:9092 --delete --topic testtopic

# Command to run Kafka producer 
./bin/kafka-console-producer.sh --topic testtopic --bootstrap-server localhost:9092

# Command to run Kafka consumer
./bin/kafka-console-consumer.sh --topic testtopic --bootstrap-server localhost:9092


./bin/kafka-topics.sh --list --bootstrap-server localhost:9092 --command-config config/ssl-user-config.properties 