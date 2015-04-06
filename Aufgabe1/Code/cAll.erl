-module (compileAll).
-export ([cAll/0]).

c() ->
	{_, ListOfFiles} = file:list_dir("./"),
	Work = [X|| X <- ListOfFiles, compileAll_(X)],
	compileAll__(Work,true).

compileAll_(String) ->
	(".erl" == string:right(String,4)) and (String /= "cAll.erl").

compileAll__([], Bool) ->
	Bool;
compileAll__([H|T], Bool) ->
	case c:c(H) of
		{ok,_} ->
			compileAll__(T, Bool and true);
		_ ->
			compileAll__(T, Bool and false)
	end.