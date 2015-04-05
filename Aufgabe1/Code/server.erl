-module (server).
-export ([start/0]).

start() ->
	{Latency, Clientlifetime, ServerName, HBQname, HBQnode, DLQlimit} = readConfig(),
	registerServer(ServerName),
	CMEM = initCMEM(RemTime, "cmem.log"), %% TODO: Init-Reihenfolge ok?
	case initHBQ(HBQname, HBQnode) of
		ok -> loop(Latency, Clientlifetime, ServerName, HBQname, HBQnode, DLQlimit, CMEM, werkzeug:reset_timer(null, Latency, stop));
		false -> {error, "Received bad response from initHBQ"}
	end.

readConfig() ->
	ServerConfigFile = "server.cfg",
	Config = file:consult(ServerConfigFile),
	{ok, Latency} = get_config_value(latency, Config),
	{ok, Clientlifetime} = get_config_value(clientlifetime,Config),
	{ok, ServerName} = get_config_value(servername,Config),
	{ok, HBQname} = get_config_value(hbqname,Config),
	{ok, HBQnode} = get_config_value(hbqnode,Config),
	{ok, DLQlimit} = get_config_value(dlqlimit,Config),
	{Latency, Clientlifetime, ServerName, HBQname, HBQnode, DLQlimit}.

loop(Latency, Clientlifetime, Servername, HBQname, HBQnode, DLQlimit, CMEM, Timer) ->
	cmem:delExpiredCl(CMEM, Clientlifetime),
	receive 
		{ClientPID, getmessages} -> sendMessages(ClientPID, CMEM);
		{dropmessage, [INNr, Msg, TSclientout]} -> dropmessage(HBQname, HBQnode, INNr, Msg, TSclientout);
		{ClientPID, getmsgid} -> sendMSGID(ClientPID);
		stop -> terminateHBQ(HBQname, HBQnode),
	end,
	werkzeug:reset_timer(Timer, Latency, stop)
	loop(Latency, Clientlifetime, Servername, HBQname, HBQnode, DLQlimit, CMEM, Timer).

sendMessages(ToClient, CMEM) ->
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
	{HBQname,HBQnode} ! {self(), {request, pushHBQ, [NNr,Msg,TSclientout]}.
	receive 
		{reply, ok} -> ,
			ok;
		_ -> 
			{error, "Received bad response from HBQ pushHBQ"}
	end.

sendMSGID(ClientPID, CMEM) ->
	NNr = cmem:getClientNNr(CMEM, ClientPID),
	ClientPID ! {nid, NNr}.

%%%%%%%%%%%%%%%%% Interne, nicht von dem Entwurf erfasste Hilfsmethoden

initCMEM(Clientlifetime, CMEMLogFile)
	cmem:initCMEM(Clientlifetime, CMEMLogFile).

registerServer(ServerName)
	register(ServerName, self()).

initHBQ(HBQname, HBQnode) ->
	{HBQname,HBQnode} ! {self(), request, initHBQ},
	receive 
		{reply, ok} -> 
			ok;
		_ -> 
			fail
	end.

terminateHBQ(HBQname, HBQnode) ->
	{HBQname,HBQnode} ! {self(), request, dellHBQ},
	receive 
		{reply, ok} -> 
			ok;
		_ -> 
			fail
	end.
