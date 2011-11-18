#include <Ethernet.h>
#include <SPI.h>
#include <Pubsubio.h>

unsigned long last = millis();
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };

// ip address within subnet mask provided by my and most routers
// if it doesnt work check the ips assigned by your router
byte ip[] = { 192, 168, 0, 100 }; 
byte hub[] = { 79, 125, 4, 43 }; // hub.pubsub.io

Pubsubio pubsub(hub);

void setup() {
  Serial.begin(9600);
  Ethernet.begin(mac, ip);  
  delay(1000); 
  

  //head over to http://pubsub.io/console#arduino to see the data
  pubsub.connect("arduino"); 
  pubsub.subscribe("{\"hello\":\"world\"}", hello); 
}

void loop() {
  pubsub.monitor();

  if(millis() - last > 1000UL) {
    pubsub.publish("{\"A0\":" + String(analogRead(A0),DEC) + "}");
    last = millis();
  }
}

void hello(String data) {
  Serial.println(data); 
}