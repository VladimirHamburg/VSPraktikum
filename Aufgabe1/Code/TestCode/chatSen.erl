-module (chatSen).
-export ([startS/1]).
-import (chatRec, [startR/0]).

startS(Other) ->
	register(chatS,self()),
	spawn(chatRec,startR,[]),
	loop(Other).

loop(Other) ->
	Msg = io:get_line("Nachricht> "),
	{chatR,Other} ! {erlang:localtime(),Msg},
	loop(Other).