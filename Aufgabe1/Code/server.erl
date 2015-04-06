-module (server).
-export ([start/0]).

start() ->
	io:fwrite("Server starting up...\n"),
	{Latency, Clientlifetime, ServerName, HBQname, HBQnode, DLQlimit} = readConfig(),
	io:fwrite("... config read ...\n"),
	registerServer(ServerName),
	io:fwrite("... server " ++ werkzeug:to_String(ServerName) ++ " registered ...\n"),
	CMEM = initCMEM(Clientlifetime, "cmem.log"), %% TODO: Init-Reihenfolge ok?
	io:fwrite("... cmem initialized ...\n"),
	case initHBQ(HBQname, HBQnode) of
		ok ->
			io:fwrite("Server startup complete!\n"),
			loop(Latency, 
				Clientlifetime, 
				ServerName, 
				HBQname, 
				HBQnode, 
				DLQlimit, 
				CMEM, 
				werkzeug:reset_timer(null, Latency, stop),
				1);
		false -> {error, "Received bad response from initHBQ"}
	end.

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
			sendMessages(ClientPID, CMEM, HBQname, HBQnode),
			loop(Latency, Clientlifetime, Servername, HBQname, HBQnode, DLQlimit, CMEM, Timer,INNr);
		{dropmessage, [WINNr, Msg, TSclientout]} -> 
			dropmessage(HBQname, HBQnode, WINNr, Msg, TSclientout),
			loop(Latency, Clientlifetime, Servername, HBQname, HBQnode, DLQlimit, CMEM, Timer,INNr);
		{ClientPID, getmsgid} -> 
			NewINNr = sendMSGID(ClientPID, CMEM,INNr),
			loop(Latency, Clientlifetime, Servername, HBQname, HBQnode, DLQlimit, CMEM, Timer,NewINNr);
		stop -> 
			terminateHBQ(HBQname, HBQnode)
	end. 
			

sendMessages(ToClient, CMEM, HBQname, HBQnode) ->
	NNr = cmem:getClientNNr(CMEM, ToClient),
	{HBQname,HBQnode} ! {self(), {request, deliverMSG, NNr,ToClient}},
	receive 
		{reply, SendNNr} -> 
			cmem:updateClient(CMEM, ToClient, SendNNr, "cmem.log"),
			ok;
		_ -> 
			{error, "Received bad response from HBQ deliverMSG"}
	end.
	

dropmessage(HBQname, HBQnode, NNr, Msg, TSclientout) ->
	{HBQname,HBQnode} ! {self(), {request, pushHBQ, [NNr,Msg,TSclientout]}},
	receive 
		{reply, ok} ->
			ok;
		_ -> 
			{error, "Received bad response from HBQ pushHBQ"}
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
	io:fwrite("... send init to " ++ werkzeug:to_String(HBQname) ++ "@" ++ werkzeug:to_String(HBQnode) ++  "\n"),
	{HBQname,HBQnode} ! {self(), {request, initHBQ}},
	io:fwrite("wait for HBQ to respond... \n"),
	receive 
		{reply, ok} -> 
			ok;
		_ -> 
			fail
	end.

terminateHBQ(HBQname, HBQnode) ->
	{HBQname,HBQnode} ! {self(), {request, dellHBQ}},
	receive 
		{reply, ok} -> 
			ok;
		_ -> 
			fail
	end.
