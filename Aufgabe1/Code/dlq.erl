-module (dlq).
-export ([initDLQ/2,expectedNr/1,push2DLQ/3,deliverMSG/4]).

initDLQ(Size, Datei) ->
	{Size, []}.

expectedNr({_,List}) ->
	expectedNr_(List).

push2DLQ(NewEntry, {Size,List}, Datei) when length(List) < Size ->
	{Size, List ++ makeEntry(NewEntry)};
push2DLQ(NewEntry, {Size,[_|ListTail]}, Datei) ->
	{Size, ListTail ++ makeEntry(NewEntry)}.

deliverMSG(MSGNr, ClientPID, Queue, Datei) ->
	null.

%%%%%%%% Hilfsmethoden, nicht in der Dokumentation beschrieben

expectedNr_([]) ->
	1;
expectedNr_(List) ->
	[[NNr|_]|_] = lists:reverse(List),
	NNr+1.

makeEntry([NNr, Msg, TSclientout, TShbqin])->
	[[NNr, Msg++werkzeug:timeMilliSecond(), TSclientout, TShbqin, erlang:now()]].