-module (chatSen).
-export ([startS/1]).

startS(Other) ->
	register(chatS,self()),
	loop(Other).

loop(Other) ->
	Msg = io:get_line("Nachricht> "),
	{chatR,Other} ! {erlang:localtime(),Msg},
	loop(Other).