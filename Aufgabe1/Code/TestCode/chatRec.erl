-module (chatRec).
-export ([startR/0]).

startR() ->
	register(chatR,self()),
	loop().

loop() ->
	receive 
		{Time, Msg} ->
			io:fwrite("~p", [Time]),
			io:fwrite("~p~n", [Msg]),
			loop()
	end.
