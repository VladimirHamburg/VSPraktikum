-module (packetBuffer).

-export ([start/0, pop/0]).

start() ->
	ets:new(my_table, [named_table, protected, set, {keypos, 1}]),
	ets:insert(my_table, {host, Host}),
	loop();



log(Msg) ->
	werkzeug:logging(werkzeug:to_String(node())++".log", Msg++"\n").