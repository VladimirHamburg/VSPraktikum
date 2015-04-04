-module (dlq).
-export ([initDLQ/2,expectedNr/1,push2DLQ/3,deliverMSG/4]).

initDLQ(Size, Datei) ->
	{Size, []}.

expectedNr({_,List}) ->
	expectedNr_(List).

push2DLQ(NewEntry, {Size,List}, Datei) when length(List) < Size ->
	{Size, List++[NewEntry]};
push2DLQ(NewEntry, {Size,[_|ListTail]}, Datei) ->
	{Size, ListTail ++ [NewEntry]}.

deliverMSG(MSGNr, ClientPID, Queue, Datei) ->
	lol.

%%%%%%%% Hilfsmethoden, nicht in der Dokumentation beschrieben

expectedNr_([]) ->
	1;
expectedNr_([[NNr, _, _, _]|[]]) ->
	NNr+1;
expectedNr_([_|T]) ->
	expectedNr_(T).