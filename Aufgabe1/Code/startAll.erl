-module (startAll).
-export ([start/0,start/1]).

start() ->
	spawn(fun() -> start("start werl -name hbq -setcookie zumm -s hbq start") end),
	spawn(fun() ->start("start werl -name server -setcookie zumm -s server start") end),
	spawn(fun() ->start("start werl -name client -setcookie zumm -s client start") end).

start(CMD) ->
	timer:sleep(20),
	os:cmd(CMD).

