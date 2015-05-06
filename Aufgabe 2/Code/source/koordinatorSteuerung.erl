-module (koordinatorSteuerung).
-export ([start/1]).

start(KoordinatorNode) ->
	log("Koordinator steuerung starting up..."),
	log("register as chefc..."),
	register(chefc, self()),
	timer:sleep(1000),
	run({chef, KoordinatorNode}).
	

run(Koordinator) ->
	Input = io:get_line("input:"),
	[InputClean|_] = string:tokens(Input, "\n"),
	Atom = erlang:list_to_atom(InputClean),
	case Atom of
		exit ->
			ok;
		calc ->
			{ok, InputVar} = io:get_line("var:"),
			[InputVarClean|_] = string:tokens(InputVar, "\n"),
			Koordinator ! {calc, erlang:list_to_integer(InputVarClean)};
		_ ->
			Koordinator ! Atom,
			run(Koordinator)
	end. 
	


log(Msg) ->
	werkzeug:logging(werkzeug:to_String(node())++".log", Msg++"\n").