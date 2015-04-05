-module (server).
-export ([start/0]).

start() ->
	{Latency, Clientlifetime, ServerName, HBQname, HBQnode, DLQlimit} = readConfig(),
	registerServer(ServerName),
	CMEM = initCMEM(RemTime, "cmem.log"), %% TODO: Init-Reihenfolge ok?
	case initHBQ(HBQname, HBQnode) of
		ok -> loop(Latency, Clientlifetime, ServerName, HBQname, HBQnode, DLQlimit, CMEM);
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

loop(Latency, Clientlifetime, Servername, HBQname, HBQnode, DLQlimit, CMEM) ->
	cmem:delExpiredCl(CMEM, Clientlifetime),
	receive 
		{ClientPID, getmessages} -> sendMessages(ClientPID, CMEM);
		{dropmessage, [INNr, Msg, TSclientout]} -> dropmessage(HBQname, HBQnode);
		{ClientPID, getmsgid} -> sendMSGID(ClientPID)
	end,
	loop().

sendMessages(ToClient, CMEM) ->
	cmem:getClientNNr(CMEM, ToClient).

dropmessage(HBQname, HBQnode) ->
	notImplemented.

sendMSGID(ClientPID, CMEM) ->
	notImplemented.

%%%%%%%%%%%%%%%%% Interne Hilfsmethoden

initCMEM(Clientlifetime, CMEMLogFile)
	cmem:initCMEM(Clientlifetime, CMEMLogFile).

registerServer(ServerName)
	register(ServerName, self()).

initHBQ(HBQname, HBQnode) ->
	{HBQname,HBQnode} ! {self(), request, initHBQ},
	receive 
		{reply, ok} -> ok
		{reply} -> fail
	end.
	


