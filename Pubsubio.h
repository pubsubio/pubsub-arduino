/*
Pubsubio.h - Pubsub.io client library.
Created by Ian Jørgensen, August 20, 2011.
MIT License
*/

#ifndef Pubsubio_h
#define Pubsubio_h

#include "WProgram.h"
#include <SPI.h>
#include <Ethernet.h>
#include <HashMap.h>

class Pubsubio
{
	public:
		Pubsubio();
		Pubsubio(byte hub[]);
		Pubsubio(byte hub[], int port);
		typedef void (*EventDelegate)(String data);
		boolean connect();
		boolean connect(String sub);
		boolean connected();
		void stop();
		void publish(String body);
		int subscribe(String query, EventDelegate delegate);
		void unsubscribe(int id);
		void monitor();
	private:
		Client _client;
		void send(String body);
		int parseInt(String text);
		String parseMessageProperty(String property, String data);
};

#endif