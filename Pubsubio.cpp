/*
Pubsubio.cpp - Pubsub.io client library.
Created by Ian Jørgensen, August 10, 2011.
MIT License
*/

#include "WProgram.h"
#include "Pubsubio.h"

int _id = 0;
typedef void (*EventDelegate)(String data);
EventDelegate _subs[10];
byte _hubAddress[] = { 79, 125, 4, 43 }; // hub.pubsub.io
String _message = "";

Pubsubio::Pubsubio(): _client(_hubAddress, 10547) {
}

Pubsubio::Pubsubio(byte hub[]): _client(hub, 10547) {
}

Pubsubio::Pubsubio(byte hub[], int port) : _client(hub, port) {
}

boolean Pubsubio::connect() {
	return connect("/");
}

boolean Pubsubio::connect(String sub) {
	if (_client.connect()) {
		send("{\"sub\":\"" + sub + "\"}");
		return true;
	} else {
		return false;
	}
}

boolean Pubsubio::connected() {
    return _client.connected();
}

void Pubsubio::stop() {
    _client.stop();
}

void Pubsubio::publish(String body) {
	return send("{\"name\":\"publish\", \"doc\":" + body + "}");
}

int Pubsubio::subscribe(String query, EventDelegate delegate) {
	_id++;
	_subs[_id] = delegate;

	send("{\"name\":\"subscribe\", \"query\":" + query + ", \"id\":" + String(_id, DEC) + "}");
	return _id;
}

void Pubsubio::unsubscribe(int id) {
	// todo remove from hashmap
	
	send("{\"name\":\"unsubscribe\", \"id\":" + String(id, DEC) + "}"); 
}

void Pubsubio::monitor() {
	if(_client.available()) {
		char c = _client.read();
		int i = c - '0';
		
		if(c == 0x000000) {
			_message = "";
			return;
		}
		if(i == -49) {
		    int id = parseInt(parseProperty("id", _message));
			String doc = parseProperty("doc", _message);
			doc = doc.substring(0,doc.length() - 1);

		    EventDelegate delegate = _subs[id];
		    if (delegate != NULL) {
		        delegate(doc);
		    }
			
			_message = "";
			return;
		}
		
		_message = _message + c;
	}
	return;
}

int Pubsubio::parseInt(String text) {
  char temp[20];
  text.toCharArray(temp, 19);
  int x = atoi(temp);
  if (x == 0 && text != "0")
  {
    x = -1;
  }
  return x;
}  

String Pubsubio::parseProperty(String property, String data) {
    property = "\"" + property + "\"";
    int propertyDataStart = data.indexOf(property) + property.length();
    
    char currentCharacter;
    do {
        propertyDataStart++;
        currentCharacter = data.charAt(propertyDataStart);
    } while (currentCharacter == ' ' || currentCharacter == ':' || currentCharacter == '\"');
    
    int propertyDataEnd = propertyDataStart;
    bool isString = data.charAt(propertyDataStart-1) == '\"';
    if (!isString) {
        do {
            propertyDataEnd++;
            currentCharacter = data.charAt(propertyDataEnd);
        } while (currentCharacter != ' ' && currentCharacter != ',');
    }
    else {
        char previousCharacter;
        currentCharacter = ' ';
        do {
            propertyDataEnd++;
            previousCharacter = currentCharacter;
            currentCharacter = data.charAt(propertyDataEnd);
        } while (currentCharacter != '"' || previousCharacter == '\\');
    }
    
    return data.substring(propertyDataStart, propertyDataEnd).replace("\\\"", "\"");
}

void Pubsubio::send(String body) {
		_client.print(0x000000, BYTE);
	    _client.print(body);
	    _client.print(0xFFFFFD, BYTE);
}