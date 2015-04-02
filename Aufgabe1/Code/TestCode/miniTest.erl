-module (miniTest).
-export ([print/1,read/0]).
print(Msg) ->
	io:fwrite("~p~n", [Msg]).

read() ->
	Msg = io:get_line("Prompt> "),
	print(Msg),
	read().
