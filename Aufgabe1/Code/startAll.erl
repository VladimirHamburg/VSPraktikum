-module (startAll).
-export ([start/0,start/1]).

start() ->
	spawn(fun() -> start("start erl -name hbq -setcookie zumm -s hbq start") end),
	spawn(fun() ->start("start erl -name server -setcookie zumm -s server start") end),
	spawn(fun() ->start("start erl -name client -setcookie zumm -s client start") end).

start(CMD) ->
	timer:sleep(20),
	os:cmd(CMD).

