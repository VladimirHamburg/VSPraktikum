-module (cMake).
-export ([c/0]).


c() ->
	c:cd("../source"),
	make:all([{outdir,"../bin"}]).
