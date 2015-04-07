-module (hbq).
-export ([start/0]).

-define (LOG, werkzeug:to_String(erlang:node()) ++ ".log").

start()->
	{ok, ConfigListe} = file:consult("server.cfg"),
	{ok,HBQname} = werkzeug:get_config_value(hbqname,ConfigListe),
	{ok,DLQlimit} = werkzeug:get_config_value(dlqlimit,ConfigListe),
	register(HBQname,self()),
	io:fwrite("HBQ bereit. \n"),
 receive
 	{ServerPID, {request,initHBQ}} ->
 		werkzeug:logging(?LOG, "HBQ und DLQ gestartet. \n"),
 		loop(initHBQandDLQ(ServerPID,DLQlimit))
 end.

loop(Queue)->
 receive
 	{ServerPID, {request,pushHBQ,[NNr,Msg,TSclientout]}} ->
 		loop(pushHBQ(ServerPID,Queue,[NNr,Msg,TSclientout]));
 	{ServerPID, {request,deliverMSG,NNr,ToClient}} ->
 		{_,DLQ} = Queue,
 		deliverMSG(ServerPID, DLQ, NNr, ToClient),
 		loop(Queue);
 	{ServerPID, {request,dellHBQ}} ->
 		io:fwrite("HBQ STOP! \n"),
 		dellHBQ(ServerPID)	
 end.

initHBQandDLQ(ServerPID,Size)->
 HBQandDLQ = {[],dlq:initDLQ(Size,?LOG)},
 ServerPID ! {reply, ok},
 HBQandDLQ.

pushHBQ(ServerPID, {HBQ,DLQ}, [NNr, Msg,TSclientout]) ->
 Flag = dlq:expectedNr(DLQ) == NNr,
 werkzeug:logging(?LOG, werkzeug:to_String(NNr) ++ "te Nachricht angekommen. Erwartet wird: "++ werkzeug:to_String(dlq:expectedNr(DLQ)) ++" \n"),
 {NewNBQ,NewDLQ} = case Flag of
 	true ->
 		werkzeug:logging(?LOG, werkzeug:to_String(NNr) ++ " direkt in DLQ gespeichert. \n"), 
 		{HBQ,dlq:push2DLQ([NNr, Msg,TSclientout,erlang:now()],DLQ,?LOG)};
 	false ->
 		Flag2 = dlq:expectedNr(DLQ) > NNr,
 		case Flag2 of
 			false ->
 				NewHBQ = pushToHBQ(HBQ,[NNr, Msg,TSclientout]),
				werkzeug:logging(?LOG, "Nachricht " ++ werkzeug:to_String(NNr) ++ " in HBQ gespeichert.\n"),
 				[[LNNr,_,_,_]|_] = NewHBQ,
 				pushSeries(NewHBQ,DLQ,dlq:expectedNr(DLQ),LNNr);
 			true ->
 				werkzeug:logging(?LOG, "Nachrichten "++ werkzeug:to_String(NNr) ++ " verworfen. \n"),
 				{HBQ,DLQ}		
 		end
 	end,
 ServerPID ! {reply, ok},
 {NewNBQ,NewDLQ}.


deliverMSG(ServerPID, DLQ, NNr, ToClient)->
 SendNNr = dlq:deliverMSG(NNr,ToClient,DLQ,?LOG),
 ServerPID ! {reply,SendNNr}.

dellHBQ(ServerPID)->
 ServerPID ! {reply, ok}.

pushSeries(HBQ, {Size,DLQList},ExNNr,NNr) when ExNNr == NNr ->
	werkzeug:logging(?LOG, "Nachrichten aus HBQ können ohne Lücke in DLQ gespeichert werden \n"),
	InList = pushSeries_findall(HBQ,NNr,[]),
	{_,NewHBQ} = lists:split(length(InList),HBQ),
	NewDLQ = pushSeries_DLQ(InList,{Size,DLQList}),
	{NewHBQ,NewDLQ};
pushSeries(HBQ, {Size,DLQList},ExNNr,NNr) when length(HBQ) > Size*(2/3) ->
	InList = pushSeries_findall(HBQ,NNr,[]),
	{_,NewHBQ} = lists:split(length(InList),HBQ),
	[[LNNr,_,_,_]|_] = InList,
	NewErrMsg = "Fehlernachricht für Nachrichtennummern " ++ werkzeug:to_String(ExNNr) ++ " bis " ++ werkzeug:to_String(LNNr-1),
	ErrMsg = [ExNNr,NewErrMsg,erlang:now(),erlang:now()],
	NewDLQ = pushSeries_DLQ([ErrMsg] ++ InList,{Size,DLQList}),
	werkzeug:logging(?LOG, NewErrMsg ++"\n"),
	{NewHBQ,NewDLQ};
pushSeries(HBQ, DLQ,_,_) ->
	{HBQ,DLQ}.

%%%%%%%%%%%%Hielfsmethoden, nicht in der Dokumentation beschrieben.

pushToHBQ(HBQ,[NNr,Msg,TSclientout]) ->
	[[WLNNr,WLMsg,WLTSclientout,WLTShbqin]|| [WLNNr,WLMsg,WLTSclientout,WLTShbqin] <- HBQ,WLNNr =< NNr] ++ [[NNr,Msg,TSclientout,erlang:now()]] ++ [[WRNNr,WRMsg,WRTSclientout,WRTShbqin]|| [WRNNr,WRMsg,WRTSclientout,WRTShbqin] <- HBQ,WRNNr > NNr].

pushSeries_findall([],_,Accu) ->
	Accu;
pushSeries_findall([[NNr,Msg,TSclientout,TShbqin]|T],NextNNr,Accu) when NNr == NextNNr ->
	pushSeries_findall(T,NextNNr+1,Accu ++ [[NNr,Msg,TSclientout,TShbqin]]);
pushSeries_findall(_,_,Accu) ->
	Accu.

pushSeries_DLQ([],DLQ) ->
	DLQ;
pushSeries_DLQ([H|T],DLQ) ->
	[NNr,Msg,TSclientout,TShbqin] = H,
	NewDLQ = dlq:push2DLQ([NNr, Msg,TSclientout,TShbqin],DLQ,?LOG),
	pushSeries_DLQ(T,NewDLQ).