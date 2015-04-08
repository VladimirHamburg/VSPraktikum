-module (server).
-export ([start/0]).

%%ENTWURF: Startet einen neuen Server-Prozess, damit dieser im Verlauf 
%%          Nachrichten erhalten kann
%%UMSETZUNG: Wie in Entwurf
start() ->
	log("Server starting up..."),
	log("reading config ..."),
	{Latency, Clientlifetime, ServerName, HBQname, HBQnode, DLQlimit} = readConfig(),
	log("registering server as " ++ werkzeug:to_String(ServerName) ++ "..."),	
	registerServer(ServerName),
	log("initialize CMEM..."),
	CMEM = initCMEM(Clientlifetime, "cmem.log"),
	initHBQ(HBQname, HBQnode),
	log("Server startup complete!"),
	loop(Latency, 
		Clientlifetime, 
		ServerName, 
		HBQname, 
		HBQnode, 
		DLQlimit, 
		CMEM, 
		werkzeug:reset_timer(null, Latency, stop),
		1).
		
%%ENTWURF: Liest die Server config aus
%%UMSETZUNG: Wie in Entwurf
readConfig() ->
	ServerConfigFile = "server.cfg",
	{ok, Config} = file:consult(ServerConfigFile),
	{ok, Latency} = werkzeug:get_config_value(latency, Config),
	{ok, Clientlifetime} = werkzeug:get_config_value(clientlifetime,Config),
	{ok, ServerName} = werkzeug:get_config_value(servername,Config),
	{ok, HBQname} = werkzeug:get_config_value(hbqname,Config),
	{ok, HBQnode} = werkzeug:get_config_value(hbqnode,Config),
	{ok, DLQlimit} = werkzeug:get_config_value(dlqlimit,Config),
	{Latency, Clientlifetime, ServerName, HBQname, HBQnode, DLQlimit}.

%%ENTWURF: Server wartet auf Anfragen seitens des Clients
%%UMSETZUNG: Wie in Entwurf, jedoch fehlt dort die Übergabe von Timer und 
%%           die Übergabe der Laufvariable für MSGID
loop(Latency, Clientlifetime, Servername, HBQname, HBQnode, DLQlimit, CMEM, Timer,INNr) ->
	cmem:delExpiredCl(CMEM, Clientlifetime),
	werkzeug:reset_timer(Timer, Latency, stop),
	receive 
		{ClientPID, getmessages} -> 
			NewCMEM = sendMessages(ClientPID, CMEM, HBQname, HBQnode),
			loop(Latency, Clientlifetime, Servername, HBQname, HBQnode, DLQlimit, NewCMEM, Timer,INNr);
		{dropmessage, [WINNr, Msg, TSclientout]} -> 
			dropmessage(HBQname, HBQnode, WINNr, Msg, TSclientout),
			loop(Latency, Clientlifetime, Servername, HBQname, HBQnode, DLQlimit, CMEM, Timer,INNr);
		{ClientPID, getmsgid} -> 
			NewINNr = sendMSGID(ClientPID, CMEM,INNr),
			loop(Latency, Clientlifetime, Servername, HBQname, HBQnode, DLQlimit, CMEM, Timer,NewINNr);
		stop ->
			log("server timeout. Shutting down..."),
			terminateHBQ(HBQname, HBQnode)
	end. 

%% ENTWURF: Veranlasst den HBQ zum senden einer Nachrichtennummer an einen Client
%% UMSETZUNG: Wie in Entwurf 
sendMessages(ToClient, CMEM, HBQname, HBQnode) ->
	NNr = cmem:getClientNNr(CMEM, ToClient),
	{HBQname,HBQnode} ! {self(), {request, deliverMSG, NNr,ToClient}},
	receive
		{reply, SendNNr} -> 
			cmem:updateClient(CMEM, ToClient, SendNNr, "cmem.log")
	end.

%% ENTWURF: Veranlasst den HBQ eine Nachricht zu speichern
%% UMSETZUNG: Wie in Entwurf
dropmessage(HBQname, HBQnode, NNr, Msg, TSclientout) ->
	{HBQname,HBQnode} ! {self(), {request, pushHBQ, [NNr,Msg,TSclientout]}},
	receive 
		{reply, ok} ->
			ok
	end.

%% ENTWURF: Vergibt eine neu MSGID
%% UMSETZUNG: Entwurf will eine nummer aus CMEM vergeben, dies ist falsch
%%            Es wird die Zählvariable INNr versendet und incrementiert
sendMSGID(ClientPID, _, INNr) ->
	ClientPID ! {nid, INNr},
	INNr+1.

%%%%%%%%%%%%%%%%% Interne, nicht von dem Entwurf erfasste Hilfsmethoden

initCMEM(Clientlifetime, CMEMLogFile) ->
	cmem:initCMEM(Clientlifetime, CMEMLogFile).

registerServer(ServerName) ->
	register(ServerName, self()).

initHBQ(HBQname, HBQnode) ->
	log("send init to " ++ werkzeug:to_String(HBQname) ++ "@" ++ werkzeug:to_String(HBQnode)),
	{HBQname,HBQnode} ! {self(), {request, initHBQ}},
	log("wait for HBQ to respond..."),
	receive 
		{reply, ok} -> 
			ok
	end.

terminateHBQ(HBQname, HBQnode) ->
	log("send terminate to " ++ werkzeug:to_String(HBQname) ++ "@" ++ werkzeug:to_String(HBQnode)),
	{HBQname,HBQnode} ! {self(), {request, dellHBQ}},
	log("wait for HBQ to respond..."),
	receive 
		{reply, ok} -> 
			log("HBQ shutdown received. GOODBYE!")
	end.

log(Msg) ->
	werkzeug:logging(werkzeug:to_String(erlang:node())++".log", Msg++"\n").
