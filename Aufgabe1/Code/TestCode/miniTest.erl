-module (miniTest).
-export ([print/1,read/0,sortin/2,getout/1]).
print(Msg) ->
	io:fwrite("~p~n", [Msg]).

read() ->
	Msg = io:get_line("Prompt> "),
	print(Msg),
	read().

sortin(NList, []) ->
	[NList];
sortin([NNr,NMsg],[[Nr,Msg]|T]) when NNr < Nr ->
	[[NNr,NMsg]] ++ [[Nr,Msg]] ++ T;
sortin(NList,[H|T]) ->
	[H] ++ sortin(NList,T).

getout(List) ->
	lists:takewhile(fun([Nr,_]) -> myAny(Nr,List) end, List).

myAny(_,[]) ->
	false;
myAny(Nr,[[NNr,_|_]]) when Nr == NNr+1 ->
	true;
myAny(Nr,[_|T]) ->
	myAny(Nr,T).


	




