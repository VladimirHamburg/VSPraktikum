-module (receive).
-export ([receive/0]).

receive() ->
	register(rec1,self()),
	receive
		{PID,needPID} ->
			PID ! self()
	end,

	receive
		ok ->
			io:fwrite("~p~n",["GUT"])
	end.
