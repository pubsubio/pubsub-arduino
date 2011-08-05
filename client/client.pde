/* pubsub.io */

#include <SPI.h>
#include <Ethernet.h>

byte mac[] = {  0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192,168,0,9 };
byte hub[] = {192,168,0,160}; // hub ip address

Client pclient(hub, 9999); // hub port

unsigned long last = millis();

void setup() {
  Ethernet.begin(mac, ip);
  Serial.begin(9600);
    
  delay(1000);
};
void loop() {
  String s = serve();
  
  if (s != "/") {
    Serial.println(s);
  }
  
  if(millis() - last > 1000UL) {
      String doc = String("{\"temp\":" +  String(analogRead(A0),DEC) + "}");
      
      if (publish("arduino",doc)) {
        Serial.println("published");
      } else {
        Serial.println("connection failed");
      }
      last = millis();
  }
};

boolean publish(int temp) {
  publish(String(), temp);
};
boolean publish(String hub,String body) {
  if (pclient.connect()) {
    if (hub != "") {
      hub = hub + '/';    
    }
    
    pclient.println(String("POST /" + hub + "publish HTTP/1.0"));
    pclient.println(String("Content-Length: " + String(body.length() + 8,DEC)));
    pclient.println();
    pclient.println(String("{\"doc\":" + body + "}"));
    pclient.stop();
    
    return true;
  } else {
    return false;
  }
};
