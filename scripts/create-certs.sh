#!/bin/bash

# /bin/rm ca.key ca.crt server.truststore.jks client.truststore.jks server.keystore.jks cert-file cert-signed

# create the CA cert. The same CA will be used to sign all kafka certificates
# Note! you will be prompted for password to encrypt the ca.key
openssl req \
  -new -x509 -keyout ca.key -out ca.crt -days 365 \
  -subj "/C=NO/ST=Hordaland/L=Bergen/O=E/OU=EXAMPLE/CN=selfsigned.kafka.example.com"

# generate key and certificate for each machine in the cluster
keytool -genkey -keystore server.keystore.jks -keyalg RSA -keysize 2048 \
  -validity 10000 -alias kafka -dname "cn=k1.kafka.example.com, ou=IT, o=EXAMPLE.COM, c=NO" \
  -ext SAN=DNS:k1.kafka.example.com \
  -storepass password -keypass password

# migrate to pkcs12
#keytool -importkeystore -srckeystore server.keystore.jks -destkeystore server.keystore.jks -deststoretype pkcs12 \
#  -storepass password -keypass password



# If you configure the Kafka brokers to require client authentication by setting ssl.client.auth to be "requested" or "required" on the Kafka brokers config then you must provide a truststore for the Kafka brokers as well and it should have all the CA certificates that clients' keys were signed by.

# import CA cert to server truststore
keytool -keystore server.truststore.jks -alias CARoot -import -file ca.crt -storepass password -noprompt
# import CA cert to client truststore
keytool -keystore client.truststore.jks -alias CARoot -import -file ca.crt -storepass password -noprompt

# request certificate and write to file
keytool -keystore server.keystore.jks -alias kafka -certreq -file cert-file -storepass password -noprompt
# sign certificate
openssl x509 -req -CA ca.crt -CAkey ca.key -in cert-file -out cert-signed -days 1000 -CAcreateserial -passin pass:password
# import both certificates (ca + kafka) to server keystore
keytool -keystore server.keystore.jks -alias CARoot -import -file ca.crt -storepass password -noprompt
keytool -keystore server.keystore.jks -alias kafka -import -file cert-signed -storepass password -noprompt

# import both certificates (ca + kafka) to client keystore
keytool -keystore client.keystore.jks -alias CARoot -import -file ca.crt -storepass password -noprompt
keytool -keystore client.keystore.jks -alias kafka -import -file cert-signed -storepass password -noprompt

# list certificates in keystore
keytool -list -v -keystore server.keystore.jks -storepass password
keytool -list -v -keystore client.keystore.jks -storepass password

################################################################################
# script
################################################################################

# import CA cert to server truststore
keytool -keystore server.truststore.jks -alias CARoot -import -file ca.crt -storepass password -noprompt
# import CA cert to client truststore
keytool -keystore client.truststore.jks -alias CARoot -import -file ca.crt -storepass password -noprompt

for i in {1..3}; do

  keytool -genkey -keystore k${i}.keystore.jks -keyalg RSA -keysize 2048 \
    -validity 10000 -alias kafka -dname "cn=k${i}.kafka.example.com, ou=IT, o=EXAMPLE.COM, c=NO" \
    -ext SAN=DNS:k${i}.kafka.example.com \
    -storepass password -keypass password

  # request certificate and write to file 
  keytool -keystore k${i}.keystore.jks -alias kafka -certreq -file cert-file -storepass password -noprompt
  # sign certificate
  openssl x509 -req -CA ca.crt -CAkey ca.key -in cert-file -out cert-signed -days 1000 -CAcreateserial -passin pass:password
  # import both certificates (ca + kafka) to keystore
  keytool -keystore k${i}.keystore.jks -alias CARoot -import -file ca.crt -storepass password -noprompt
  keytool -keystore k${i}.keystore.jks -alias kafka -import -file cert-signed -storepass password -noprompt

done

# copy
