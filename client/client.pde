/* pubsub.io */

#include <SPI.h>
#include <Ethernet.h>

byte mac[] = {  0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192,168,0,9 };
byte hub[] = {192,168,0,160};

Client pclient(hub, 9999);
Server server(80);

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

String serve() {
  // listen for incoming clients
  Client client = server.available();
  String ret = String("/");
  
  if (client) {
    // an http request ends with a blank line
    boolean currentLineIsBlank = true;
    int i = 0;
    boolean capture = true;
    
    while (client.connected()) {
      if (client.available()) {
        char c = client.read();
        Serial.print(c);
        if(capture == true && i++ >= 5 && c != ' ') {
          ret = ret + c;
        }    
        if (i >= 5 && c == ' ') {
          capture = false;
        }
        
        // if you've gotten to the end of the line (received a newline
        // character) and the line is blank, the http request has ended,
        // so you can send a reply
        if (c == '\n' && currentLineIsBlank) {
          // send a standard http response header
          client.println("HTTP/1.1 200 OK");
          client.println("Content-Type: text/plain");
          client.println();
          client.println("ok");
          break;
        }
        if (c == '\n') {
          currentLineIsBlank = true;
        }  else if (c != '\r') {
          currentLineIsBlank = false;
        }
      }
    }
    // give the web browser time to receive the data
    delay(1);
    // close the connection:
    client.stop();
  }
  return ret;
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
