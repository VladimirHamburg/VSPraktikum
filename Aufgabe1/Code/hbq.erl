-module (hbq).

start()->
 not_imp.

loop()->
 not_imp.

initHBQandDLQ(ServerPID,Size)->
 HBQandDLQ = {[],dlq:initDLQ(Size,"DLQLog")},
 ServerPID ! {reply, ok}.

pushHBQ(ServerPID, {HBQ,DLQ}, [NNr, Msg,TSclientout]) ->
 Flag = dlq:expectedNr(DLQ) == NNr,
 {NewNBQ,NewDLQ} = case Flag of
 	true -> 
 		{HBQ,dlq:push2DLQ([NNr, Msg,TSclientout,erlang:now()])};
 	false ->
 		{pushToHBQ(HBQ,[NNr, Msg,TSclientout]),DLQ}
 	end,
 ServerPID ! {reply, ok},
 {NewNBQ,NewDLQ}.


deliverMSG(ServerPID, DLQ, NNr, ToClient)->
 not_imp.

dellHBQ(ServerPID)->
 ServerPID ! {reply, ok}.

pushSeries(HBQ, DLQ)->
 not_imp.

%%%%%%%%%%%%Hielfsmethoden, nicht in der Dokumentation beschrieben.

pushToHBQ(HBQ,[NNr,Msg,TSclientout]) ->
	[[WLNNr,WLMsg,WLTSclientout,WLTShbqin]|| [WLNNr,WLMsg,WLTSclientout,WLTShbqin] <- HBQ,WLNNr =< NNr] ++ [[NNr,Msg,TSclientout,erlang:now()]] ++ [[WRNNr,WRMsg,WRTSclientout,WRTShbqin]|| [WRNNr,WRMsg,WRTSclientout,WRTShbqin] <- HBQ,WRNNr > NNr].