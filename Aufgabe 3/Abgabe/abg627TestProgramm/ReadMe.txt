1.Um Namesdienst zu starten wird folgender Befehl benutzt:
	java nameservice/NameService <port>
<port> ist der Port auf dem der Namesdienst lauscht.

2.Damit die Testprogramme ausgeührt werden können, muss ein Namensdienst vorhanden sein. Die Packeges der Middleware sollen auf einer Ordner-Ebene mit Testprogrammen sein. Die Reinfolge soll eingehalten werden. 
Die Test-Programme werden wie folgt gestartertet:
	java sampleserver/SampleServer <NS_host> <NS_port>

	java sampleserver2/SampleServer2 <NS_host> <NS_port>

	java sampleclient/SampleClient <NS_host> <NS_port> 

