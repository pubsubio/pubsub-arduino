# Pubsub.io Arduino client

Using the Ethernet Shield you can publish data to a pubsub.io hub via pubsub.io's rest publish interface. Full duplex websocket connection support will come.

Check out the source for `client.pde` the function you want to use is publish.

Publish to the value of Analog Port 0 to default hub
	
    publish("arduino",String("{\"A0\":" +  String(analogRead(A0),DEC) + "}")));

Publish the same thing to the arduino sub hub

	  publish("arduino",String("{\"A0\":" +  String(analogRead(A0),DEC) + "}")));