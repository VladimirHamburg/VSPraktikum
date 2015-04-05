-module (client).
-export ([start/0]).

start() ->
 {Clients,Lifetime,Servername,Servernode,Sendeintervall} = readConfig(),
 start_clients(Clients,Lifetime,Servername,Servernode,Sendeintervall,"logClient.txt").
 %%ClientPid = spawn(fun() -> loop(Lifetime,Servername,Servernode,Sendeintervall,"logClient",5,[]) end),
 %%timer:kill_after(Lifetime*1000,ClientPid),
 %%{Clients,Lifetime,Servername,Servernode,Sendeintervall,ClientPid}.



readConfig() ->
	{ok, ConfigListe} = file:consult("client.cfg"),
	{ok,Clients} = werkzeug:get_config_value(clients,ConfigListe),
	{ok,Lifetime} = werkzeug:get_config_value(lifetime,ConfigListe),
	{ok,Servername} = werkzeug:get_config_value(servername,ConfigListe),
	{ok,Servernode} = werkzeug:get_config_value(servernode,ConfigListe),
	{ok,Sendeintervall} = werkzeug:get_config_value(sendeintervall,ConfigListe),
	{Clients,Lifetime,Servername,Servernode,Sendeintervall}.

loop(Lifetime, Servername, Servernode,Sendeintervall,Datei,MsgNum,SendMsg) ->
	case MsgNum of
		0 ->
			Flag = getMSG(Servername, Servernode,Datei),
			case Flag of
				false ->
					io:fwrite("~p~n",["Client bleibt Leser!"]),
					loop(Lifetime, Servername, Servernode,Sendeintervall,Datei,0,SendMsg);
				true ->
					io:fwrite("~p~n",["Client wird Redakteur!"]),
					loop(Lifetime, Servername, Servernode,changeSendInterval(Sendeintervall),Datei,5,SendMsg)
			end;
		1 ->
			Number = askForMSGID(Servername,Servernode),
			werkzeug:logging(Datei,constructErrMsg(Number) ++ "\n"),
			loop(Lifetime, Servername, Servernode,Sendeintervall,Datei,0,SendMsg);
		_ ->
			Number = askForMSGID(Servername,Servernode),
			io:fwrite("~p~n",[Number]),
			timer:sleep(trunc(Sendeintervall*1000)),
			sendMSG(Servername, Servernode,Datei,Number),
			loop(Lifetime, Servername, Servernode,Sendeintervall,Datei,MsgNum-1,SendMsg++[Number])
	end.

sendMSG(Servername, Servernode,Datei,Number) ->
	{Servername,Servernode} ! {dropmessage,[Number,Msg = constructMsg(Number),erlang:now()]},
	werkzeug:logging(Datei,Msg ++" gesndet."++ "\n").



changeSendInterval(Sendeintervall)->
	Flag = random:uniform(2),
	New2Sendeintervall = case Flag of
		1 ->
			NewSendeintervall = Sendeintervall*0.5,
			checkIntervall(NewSendeintervall);
		2 ->
			Sendeintervall*1.5

	end,
	New2Sendeintervall.



askForMSGID(Servername, Servernode) ->
	{Servername,Servernode} ! {erlang:self(),getmsgid},
	receive 
		{nid,Number} ->
			io:fwrite("~p~n",["NNr erhalten."]),
			Number
	end.

getMSG(Servername, Servernode,Datei)->
	{Servername,Servernode} ! {erlang:self(),getmessages},
	io:fwrite("~p~n",["Erwarte Nachricht!"]),
	receive 
		{reply,[_,Msg,_,_,_,_],Terminated}  ->
			io:fwrite("~p~n",["Nachricht bekommen!"]),
			werkzeug:logging(Datei,Msg ++ "C In: " ++ werkzeug:timeMilliSecond()++ "\n"),
			Terminated
	end.
%%%%%%%%%%%%Hielfsmethoden, nicht in der Dokumentation beschrieben
start_clients(0,_,_,_,_,_) ->
	ok;
start_clients(Clients,Lifetime,Servername,Servernode,Sendeintervall,Datei) ->
	ClientPid = spawn(fun() -> loop(Lifetime,Servername,Servernode,Sendeintervall,Datei,5,[]) end),
	timer:kill_after(Lifetime*1000,ClientPid),
	start_clients(Clients-1,Lifetime,Servername,Servernode,Sendeintervall,Datei).

constructMsg(Number) ->
	werkzeug:to_String(erlang:self()) ++ werkzeug:to_String(erlang:node()) ++ "3" ++ "09:  " ++ werkzeug:to_String(Number) ++ "te_Nachricht. C Out: " ++ werkzeug:timeMilliSecond().

constructErrMsg(Number) ->
	werkzeug:to_String(erlang:self()) ++ werkzeug:to_String(erlang:node()) ++ "3" ++ "09:  " ++ werkzeug:to_String(Number) ++ "te_Nachricht vergessen zu senden".

checkIntervall(Intervall) ->
	Flag = Intervall < 2.0,
		case Flag of
			false ->
				Intervall;
			true ->
				2 - Intervall + Intervall
		end.