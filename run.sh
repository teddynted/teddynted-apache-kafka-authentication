#!/bin/bash

HOST_NAME='localhost'
PASSWORD='!P@ssw0rd123'
USERNAME='@dm1n'
DIR="config/kafka-ssl"
KAFKA_SERVER_JAAS="config/kafka_server_jaas.conf"
SSL_USER_CONFIG="config/ssl-user-config.properties"
SERVER_PROPERTIES="config/server.properties"
git checkout $SERVER_PROPERTIES
rm -rf $DIR $KAFKA_SERVER_JAAS $SSL_USER_CONFIG keystore truststore

if [ -d "$DIR" ]; then
  echo 'Directory '$DIR' exists.'
else
  mkdir $DIR
  git clone https://github.com/confluentinc/confluent-platform-security-tools.git  config/kafka-ssl
  export COUNTRY=ZA
  export STATE=JHB
  export ORGANIZATION_UNIT=SE
  export CITY=Johannesburg
  export PASSWORD=$PASSWORD
  chmod +x config/kafka-ssl/kafka-generate-ssl-automatic.sh
  ./config/kafka-ssl/kafka-generate-ssl-automatic.sh
  #keytool -list -keystore keystore/kafka.keystore.jks
fi

if [ -e "$KAFKA_SERVER_JAAS" ]; then
    echo 'File '$KAFKA_SERVER_JAAS' exists.'
else
    sudo touch $KAFKA_SERVER_JAAS
    sudo cat <<EOF > $KAFKA_SERVER_JAAS
KafkaServer {
   org.apache.kafka.common.security.scram.ScramLoginModule required 
   username="admin"
   password="$PASSWORD";
};
EOF
fi

if [ -e "$SSL_USER_CONFIG" ]; then
    echo 'File '$SSL_USER_CONFIG' exists.'
else
    sudo touch $SSL_USER_CONFIG
    sudo cat <<EOF > $SSL_USER_CONFIG
# Security protocol setting for clients connecting to Kafka brokers
security.protocol=SASL_SSL
# SASL mechanism configuration
sasl.mechanism=SCRAM-SHA-512
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required \
  username="$USERNAME" \
  password="$PASSWORD";
# Truststore configuration for clients
ssl.truststore.location=truststore/apache.truststore.jks
ssl.truststore.password=$PASSWORD
# Keystore configuration for client authentication
ssl.keystore.location=keystore/apache.keystore.jks
ssl.keystore.password=$PASSWORD
ssl.key.password=$PASSWORD
EOF
fi

echo $SERVER_PROPERTIES
sudo sh -c 'cat << EOF >> '$SERVER_PROPERTIES'
# Accept SASL_SSL-encrypted connections from clients and other brokers
listeners=PLAINTEXT://'$HOST_NAME':9092,SASL_PLAINTEXT://'$HOST_NAME':9093, SASL_SSL://'$HOST_NAME':9094
advertised.listeners=PLAINTEXT://'$HOST_NAME':9092,SASL_PLAINTEXT://'$HOST_NAME':9093, SASL_SSL://'$HOST_NAME':9094
# Specify the SASL mechanism
sasl.mechanism.inter.broker.protocol=SCRAM-SHA-512
sasl.enabled.mechanisms=SCRAM-SHA-512
# Configure Keystore and Truststore for brokers
ssl.keystore.location=keystore/apache.keystore.jks
ssl.keystore.password=$PASSWORD
ssl.key.password=$PASSWORD
ssl.truststore.location=truststore/apache.truststore.jks
ssl.truststore.password=$PASSWORD
# Client authentication is required for SASL_SSL
ssl.client.auth=required
EOF'