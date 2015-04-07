-module (client).
-export ([start/0]).
-define (GRUPPE, "3").
-define (TEAM, "09").
%%ENTWURF: Definition: Startet einen neuen Client-Prozess der Nachrichten an den (laufenden) Server senden
%%kann und Nachrichten abrufen kann.
%%UMSETZUNG: Die Methode start() mehrere Clients(der client.cfg zu entnehmen). Die Einstellung in client.cfg wäre bei anderer Realisierung unnötig. 
start() ->
	werkzeug:logging("CLIENT.log","GESTARTET \n"),
 {Clients,Lifetime,Servername,Servernode,Sendeintervall} = readConfig(),
 start_clients(Clients,Lifetime,Servername,Servernode,Sendeintervall,"client",1).
 %%ClientPid = spawn(fun() -> loop(Lifetime,Servername,Servernode,Sendeintervall,"logClient",5,[]) end),
 %%timer:kill_after(Lifetime*1000,ClientPid),
 %%{Clients,Lifetime,Servername,Servernode,Sendeintervall,ClientPid}.


%%ENTWURF: Definition: Vor dem Start des Client-Prozesses muss die Konfigurationsdatei (siehe Vorlage) des
%%Clients ausgelesen werden.
%%UMSETZUNG: Entspricht dem Entwurf.
readConfig() ->
	{ok, ConfigListe} = file:consult("client.cfg"),
	{ok,Clients} = werkzeug:get_config_value(clients,ConfigListe),
	{ok,Lifetime} = werkzeug:get_config_value(lifetime,ConfigListe),
	{ok,Servername} = werkzeug:get_config_value(servername,ConfigListe),
	{ok,Servernode} = werkzeug:get_config_value(servernode,ConfigListe),
	{ok,Sendeintervall} = werkzeug:get_config_value(sendeintervall,ConfigListe),
	{Clients,Lifetime,Servername,Servernode,Sendeintervall}.

%%ENTWURF: In der Hauptschleife werden die Nachrichten in bestimmten Zeitabständen an den
%%Server versendet.
%%UMSETZUNG: Entspricht dem Entwurf. Die Methode wurd um drei Variablen (Datei,MsgNum,SendMsg) erweitert.
%%  Datei -> Fürs logging
%%  MsgNum -> Wird von 5 bis 0 runtergezählt und dann wieder von 5 bis 0. Dadurch wird bestimmt wie viele Nachrichten versendet wurden. Auch die Rolle wird dadurch bestimmt.
%%  SendMsg -> Liste der gesendeter eigener Nachrichten. 
loop(Lifetime, Servername, Servernode,Sendeintervall,{Datei,CNr},MsgNum,SendMsg) ->
	case MsgNum of
		0 ->
			Flag = getMSG(Servername, Servernode,{Datei,CNr},SendMsg),
			case Flag of
				false ->
					loop(Lifetime, Servername, Servernode,Sendeintervall,{Datei,CNr},0,SendMsg);
				true ->
					loop(Lifetime, Servername, Servernode,changeSendInterval(Sendeintervall,{Datei,CNr}),{Datei,CNr},5,SendMsg)
			end;
		1 ->
			Number = askForMSGID(Servername,Servernode),
			werkzeug:logging(Datei,constructErrMsg(Number) ++ "\n"),
			loop(Lifetime, Servername, Servernode,Sendeintervall,{Datei,CNr},0,SendMsg);
		_ ->
			Number = askForMSGID(Servername,Servernode),
			timer:sleep(trunc(Sendeintervall*1000)),
			sendMSG(Servername, Servernode,{Datei,CNr},Number),
			loop(Lifetime, Servername, Servernode,Sendeintervall,{Datei,CNr},MsgNum-1,SendMsg++[Number])
	end.

%%ENTWURF: Definition: Hier wird dem Server die Nachricht {dropmessage, [INNr, Msg, TSclientout]} gesendet.
%%Auf eine Antwort des Server wird nicht gewartet.
%%UMSETZUNG: Entspricht dem Entwurf.
sendMSG(Servername, Servernode,{Datei,CNr},Number) ->
	{Servername,Servernode} ! {dropmessage,[Number,Msg = constructMsg(Number),erlang:now()]},
	werkzeug:logging(Datei,werkzeug:to_String(CNr) ++ Msg ++" gesendet."++ "\n").


%%ENTWURF:Definition: Auf Grundlage des alten Sendeintervalls (Parameter Sendintervall) wird dieses um ca.
%%50% zufällig vergrößert oder verkleinert. 
%%UMSETZUNG: Entspricht dem Entwurf. Variable Datei wurde für logging hinzugefügt.
changeSendInterval(Sendeintervall,{Datei,CNr})->
	Flag = random:uniform(2),
	New2Sendeintervall = case Flag of
		1 ->
			NewSendeintervall = Sendeintervall*0.5,
			checkIntervall(NewSendeintervall);
		2 ->
			Sendeintervall*1.5

	end,
	werkzeug:logging(Datei,"Sendeintervall für client-"++ werkzeug:to_String(CNr)++" geändert: " ++ werkzeug:to_String(trunc(New2Sendeintervall)) ++ "\n"),
	New2Sendeintervall.


%%ENTWURF: Definition: Dem Server wird folgende Nachricht übermittelt: {self(), getmsgid}. Im Anschluss wartet
%%er auf folgende Antwort des Server: {nid, Number}.
%%UMSETZUNG: Entspricht dem Entwurf.
askForMSGID(Servername, Servernode) ->
	{Servername,Servernode} ! {erlang:self(),getmsgid},
	receive 
		{nid,Number} ->
			Number
	end.
%%ENTWURF: Dem Server wird folgende Nachricht übermittelt: {self(), getmessages}. Er wartet auf die
%%Antwort des Servers (DLQ) mit folgendem Format: {reply,[NNr, Msg, TSclientout, TShbqin, TSdlqin,
%%TSdlqout], Terminated}.
%%UMSETZUNG: Entspricht dem Entwurf. Die Methode wurde um Variablen Datei und SendMsg erweitert.
%%  Datei -> Fürs logging
%%  SendMsg -> Liste der gesendeten Nachrichten. Damit diese markiert werden könnten. 
getMSG(Servername, Servernode,{Datei,CNr},SendMsg)->
	{Servername,Servernode} ! {erlang:self(),getmessages},
	receive 
		{reply,[NNr,Msg,_,_,_,_],Terminated}  ->
			Flag = lists:any(fun(X) -> NNr == X end, SendMsg),
			case Flag of
				false ->
					werkzeug:logging(Datei,werkzeug:to_String(CNr) ++ Msg ++ "C In: " ++ werkzeug:timeMilliSecond()++ "\n");
				true ->
					werkzeug:logging(Datei,werkzeug:to_String(CNr) ++ Msg ++ "******C In: " ++ werkzeug:timeMilliSecond()++ "\n")
			end,
			Terminated
	end.
%%%%%%%%%%%%Hielfsmethoden, nicht in der Dokumentation beschrieben
start_clients(0,_,_,_,_,_,_) ->
	ok;
start_clients(Clients,Lifetime,Servername,Servernode,Sendeintervall,Datei,Nr) ->
	ClientPid = spawn(fun() -> loop(Lifetime,Servername,Servernode,Sendeintervall,{Datei++werkzeug:to_String(?GRUPPE ++ ?TEAM)++werkzeug:to_String(erlang:node())++".log",Nr},5,[]) end),
	timer:kill_after(Lifetime*1000,ClientPid),
	start_clients(Clients-1,Lifetime,Servername,Servernode,Sendeintervall,Datei,Nr+1).

constructMsg(Number) ->
	werkzeug:to_String(erlang:node()) ++ ?GRUPPE ++ ?TEAM ++":  " ++ werkzeug:to_String(Number) ++ "te_Nachricht. C Out: " ++ werkzeug:timeMilliSecond().

constructErrMsg(Number) ->
	werkzeug:to_String(erlang:node()) ++ ?GRUPPE ++ ?TEAM ++ ":  " ++ werkzeug:to_String(Number) ++ "te_Nachricht vergessen zu senden".

checkIntervall(Intervall) ->
	Flag = Intervall < 2.0,
		case Flag of
			false ->
				Intervall;
			true ->
				2 - Intervall + Intervall
		end.