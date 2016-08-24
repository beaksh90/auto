----------------------------------------------------------

XmPing TCP/UDP ( Server / Client )

[Configuration]-------------------------------------------

conf/XmServer.conf
	=================================
	 TCP / UDP Socket Module, Server
	=================================
	SOCKET_TYPE=TCP       // socket mode, TCP or UDP
	SERVER_PORT=6300      // default, 6300
	SOCKET_TIMEOUT=60     // socket time out (TCP), sec
	RESPONSE=FALSE        // ping-pong

conf/XmServer.conf
	=================================
	 TCP / UDP Socket Module, Client
	=================================
	SOCKET_TYPE=TCP       // socket mode, TCP or UDP
	SERVER_IP=127.0.0.1   // server dest ip
	SERVER_PORT=6300      // server dest port
	INTERVAL=3	          // ping interval, sec
	
[Runnable]------------------------------------------------

Server : java -jar XmServer.jar
Client : java -jar XmClient.jar

----------------------------------------------------------
