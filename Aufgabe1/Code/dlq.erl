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

deliverMSG(MSGNr, ClientPID, {_, List}, Datei) ->
	case MSGNr < expectedNr_(List) of
		true -> 
			deliverMSG_(MSGNr, ClientPID, List, List, Datei);
		false ->
			{error, "MSGNr is greater than highest NNr!"}
		end.



%%%%%%%% Hilfsmethoden, nicht in der Dokumentation beschrieben

expectedNr_([]) ->
	1;
expectedNr_(List) ->
	[[NNr|_]|_] = lists:reverse(List),
	NNr+1.

makeEntry([NNr, Msg, TSclientout, TShbqin]) ->
	[[NNr, Msg++werkzeug:timeMilliSecond(), TSclientout, TShbqin, erlang:now()]].



deliverMSG_(MSGNr, ClientPID, [[NNr|_]|_], _, Datei) when MSGNr == NNr -> 
	gefunden;
deliverMSG_(MSGNr, ClientPID, [_|Tail], BuList, Datei) ->
	deliverMSG_(MSGNr, ClientPID, Tail, BuList, Datei);
deliverMSG_(MSGNr, ClientPID, [_|[]], BuList, Datei) -> %% Nicht gefunden? Erneut suchen mit größerer nummer
	deliverMSG_(MSGNr+1, ClientPID, BuList, BuList, Datei); 
