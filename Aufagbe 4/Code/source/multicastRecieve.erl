-module (multicastRecieve).

-export ([receiver/3]).

receiver(Addr,Port,IAddr) ->
	Socket = werkzeug:openRec(Addr,IAddr,Port),
	gen_udp:controlling_process(Socket, self()),
	{ok, {_, _, Packet}} = gen_udp:recv(Socket, 0),
	io:format("~p~n",[Packet]).