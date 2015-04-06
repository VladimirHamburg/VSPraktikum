-module (send).
-export ([send/1]).
send(Node) ->
	{rec1, Node} ! {self(),needPID},
	receive 
		PID ->
			PID ! ok
	end.