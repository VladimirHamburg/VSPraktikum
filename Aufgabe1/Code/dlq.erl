-module (dlq).
-export ([initDLQ/2,expectedNr/1,push2DLQ/3,deliverMSG/4]).

initDLQ(Size, Datei) ->
	log("DLQ initialized", Datei),
	{Size, []}.

expectedNr({_,List}) ->
	expectedNr_(List).

push2DLQ(NewEntry, {Size,List}, Datei) when length(List) < Size ->
	[MSGNr|_] = NewEntry,
	log("DLQ adds "++werkzeug:to_String(MSGNr), Datei),
	{Size, List ++ makeEntry(NewEntry)};
push2DLQ(NewEntry, {Size,[_|ListTail]}, Datei) ->
	[MSGNr|_] = NewEntry,
	log("DLQ shifts "++werkzeug:to_String(MSGNr), Datei),
	{Size, ListTail ++ makeEntry(NewEntry)}.

deliverMSG(MSGNr, ClientPID, {_, List}, Datei) ->
	log("DLQ should send "++werkzeug:to_String(MSGNr), Datei),
	case MSGNr > 0 of
		true ->
			case MSGNr < expectedNr_(List) of
				true -> 
					deliverMSG_(MSGNr, ClientPID, List, List, Datei);
				false ->
					log("DLQ sends "++werkzeug:to_String(MSGNr-1) ++ "(dummy)", Datei),
					ClientPID ! {reply,[MSGNr-1, "Nicht leere Dummy Nachricht", erlang:now(), erlang:now(), erlang:now(), erlang:now()], true},
					MSGNr-1
			end;
		false ->
			{error, "MSGNr can't be lower than 1!"}
	end.



%%%%%%%% Hilfsmethoden, nicht in der Dokumentation beschrieben

expectedNr_([]) ->
	1;
expectedNr_(List) ->
	[[NNr|_]|_] = lists:reverse(List),
	NNr+1.

makeEntry([NNr, Msg, TSclientout, TShbqin]) ->
	[[NNr, Msg++werkzeug:timeMilliSecond(), TSclientout, TShbqin, erlang:now()]].



deliverMSG_(MSGNr, ClientPID, [], BuList, Datei) -> %% Nicht gefunden? Erneut suchen mit größerer nummer
	deliverMSG_(MSGNr+1, ClientPID, BuList, BuList, Datei);
deliverMSG_(MSGNr, ClientPID, [[NNr, Msg, TSclientout, TShbqin, TSdlqin]|_], BuList, Datei) when MSGNr == NNr ->
	log("DLQ sends "++werkzeug:to_String(MSGNr), Datei),
	ClientPID ! {reply,[NNr, Msg, TSclientout, TShbqin, TSdlqin, erlang:now()], MSGNr > expectedNr_(BuList)-1},
	MSGNr;
deliverMSG_(MSGNr, ClientPID, [_|Tail], BuList, Datei) ->
	deliverMSG_(MSGNr, ClientPID, Tail, BuList, Datei).

log(Msg, Datei) ->
	werkzeug:logging(Datei, Msg++"\n").