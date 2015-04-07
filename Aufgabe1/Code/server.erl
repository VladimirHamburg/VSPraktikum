-module (server).
-export ([start/0]).

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

sendMessages(ToClient, CMEM, HBQname, HBQnode) ->
	NNr = cmem:getClientNNr(CMEM, ToClient),
	{HBQname,HBQnode} ! {self(), {request, deliverMSG, NNr,ToClient}},
	receive
		{reply, SendNNr} -> 
			cmem:updateClient(CMEM, ToClient, SendNNr, "cmem.log")
	end.

dropmessage(HBQname, HBQnode, NNr, Msg, TSclientout) ->
	{HBQname,HBQnode} ! {self(), {request, pushHBQ, [NNr,Msg,TSclientout]}},
	receive 
		{reply, ok} ->
			ok
	end.

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
			ok
	end.

log(Msg) ->
	werkzeug:logging(werkzeug:to_String(erlang:node())++".log", Msg++"\n").
