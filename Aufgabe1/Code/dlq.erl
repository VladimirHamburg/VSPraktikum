-module (dlq).
-export ([initDLQ/2,expectedNr/1,push2DLQ/3,deliverMSG/4]).

initDLQ(Size, Datei) ->
	{0, []}.

expectedNr({_,Liste}) ->
	expectedNr_(Liste).

push2DLQ(NewEntry, Queue, Datei) ->
	Queue++NewEntry.

deliverMSG(MSGNr, ClientPID, Queue, Datei) ->
.

%%%%%%%% Hilfsmethoden, nicht in der Dokumentation beschrieben

expectedNr_([]) ->
	1.
expectedNr_([{NNr, Msg, TSclientout, TShbqin}|[]]) ->
	NNr+1.
expectedNr_([H|T]) ->
	expectedNr_(T).