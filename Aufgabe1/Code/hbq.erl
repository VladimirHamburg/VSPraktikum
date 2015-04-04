-module (hbq).

start()->
 not_imp.

loop()->
 not_imp.

initHBQandDLQ(ServerPID)->
 not_imp.

pushHBQ(ServerPID, OldHBQ, [NNr, Msg,TSclientout]) ->
 not_imp.

deliverMSG(ServerPID, DLQ, NNr, ToClient)->
 not_imp.

dellHBQ(ServerPID)->
 ServerPID ! {reply, ok}.

pushSeries(HBQ, DLQ)->
 not_imp.