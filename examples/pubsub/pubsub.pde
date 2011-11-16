#include <Ethernet.h>
#include <SPI.h>
#include <Pubsubio.h>

unsigned long last = millis();
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 10,0,0,1 };
byte hubip[] = { 10,0,0,10 };

Pubsubio client(hubip, 10547); // instanciate a client to hub.pubsub.io

void setup() {
  Serial.begin(9600);
  Ethernet.begin(mac, ip);  
  delay(1000); // give time for the board to setup
  
  
  client.connect("arduino"); // handshake 
  client.subscribe("{\"hello\":\"world\"}", hello); // subscription calls hello function on match
}

void loop() {
  client.monitor(); // monitor manages subsciptions, it needs to be in the loop

  // publish reading from analog pin 0 once per second, without blocking the processor
  if(millis() - last > 1000UL) {
    client.publish("{\"A0\":\"" + String(analogRead(A0),DEC) + "\"}");
    last = millis();
  }
}

void hello(String data) {
  Serial.println(data); 
}