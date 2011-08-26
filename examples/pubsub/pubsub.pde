#include <Ethernet.h>
#include <SPI.h>
#include <Pubsubio.h>

unsigned long last = millis();
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192,168,0,10 };

// instanciate a client to hub.pubsub.io
Pubsubio client;

void setup() {
  Ethernet.begin(mac, ip);  
  
  // give the board time to setup
  delay(1000); 
  
  // handshake 
  client.connect("arduino"); 

  // subscirbe to hello:world call hello function on match
  client.subscribe("{\"hello\":\"world\"}",hello); 
}

void loop() {
  // monitor manages subsciptions, it needs to be in the loop
  client.monitor();

  // publish reading from analog pin 0 once per second, without blocking the processor
  if(millis() - last > 1000UL) {
    client.publish("{\"A0\":\"" + String(analogRead(A0),DEC) + "\"}");
    last = millis();
  }
}

void hello(String data) {
  Serial.println(data); 
}