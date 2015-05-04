-module (koordinator).
-export ([start/0]).

start() ->
	log("Koordinator starting up..."),
	log("reading config ..."),
	KConfig = readConfig(),
	loopInitialize(KConfig,[]).

readConfig() ->
	ServerConfigFile = "koordinator.cfg",
	{ok, Config} = file:consult(ServerConfigFile),
	{ok, ArbeitsZeit} = werkzeug:get_config_value(arbeitszeit, Config),
	{ok, TermZeit} = werkzeug:get_config_value(termzeit,Config),
	{ok, GGTProzessNummer} = werkzeug:get_config_value(ggtprozessnummer,Config),
	{ok, NameServiceNode} = werkzeug:get_config_value(nameservicenode,Config),
	{ok, NameServiceName} = werkzeug:get_config_value(nameservicename,Config),
	{ok, KoordinatorName} = werkzeug:get_config_value(koordinatorname,Config),
	{ok, Quote} = werkzeug:get_config_value(quote,Config),
	{ok, Korrigieren} = werkzeug:get_config_value(korrigieren,Config),
	{ArbeitsZeit, TermZeit, GGTProzessNummer, NameServiceNode, NameServiceName, KoordinatorName, Quote, Korrigieren}.

loopInitialize(KConfig,GGTs) ->
	{ArbeitsZeit, TermZeit, GGTProzessNummer, NameServiceNode, NameServiceName, KoordinatorName, Quote, Korrigieren} = KConfig,
	receive 
		{Starter, getsteeringval} -> 				
				Starter ! { steeringval, ArbeitsZeit, TermZeit, Quote, GGTProzessNummer },
				loopInitialize(KConfig, GGTs);
		{hello, ClientName} ->
			loopInitialize(KConfig, [] ++ [{ClientName, 0}]);
		toggle ->
			loopInitialize(toggleSet(KConfig), GGTs);
		step ->
			log("step received. Initialisation ended. Building ring..."),
			buildRing(KConfig, GGTs),
			log("Ring set up. Ready!"),
			DoRepeat = loopReady(KConfig, GGTs),
			case DoRepeat of 
				true ->
					loopInitialize(KConfig, []);
				false ->
					log("shutdown...")
			end;
		_ ->
			log("unknown message. ignored."),
			loopInitialize(KConfig, GGTs)
	end.


loopReady(KConfig,GGTs) ->
	receive
		{briefmi,{ClientName,CMi,CZeit}} ->
			updateGGTMiHere,
			loopReady(KConfig,GGTs);	
		reset ->
			sendKillToAllGGTsHere,
			true;
		prompt ->
			getAllMisAndShowHere,
			loopReady(KConfig,GGTs);
		nudge ->
			pingAllGGTsAndShowHere
			loopReady(KConfig,GGTs);
		toggle ->
			loopReady(toggleSet(KConfig), GGTs);
		{calc,WggT} ->
			startNewCalcHere,
			loopReady(KConfig,GGTs);
		kill ->
			sendKillToAllGGTsHere,
			false;
		_ ->
			log("unknown message. ignored."),
			loopReady(KConfig, GGTs)
	end.

%% Hilfsfunktionen die vom Entwurf nicht abgedeckt wurden

toggleSet(KConfig) ->
	{ArbeitsZeit, TermZeit, GGTProzessNummer, NameServiceNode, NameServiceName, KoordinatorName, Quote, Korrigieren} = KConfig,
	case Korrigieren of
		0 ->
			{ArbeitsZeit, 
						TermZeit, 
						GGTProzessNummer, 
						NameServiceNode, 
						NameServiceName, 
						KoordinatorName, 
						Quote, 
						1});
		1 ->
			{ArbeitsZeit, 
						TermZeit, 
						GGTProzessNummer, 
						NameServiceNode, 
						NameServiceName, 
						KoordinatorName, 
						Quote, 
						0})
	end.

buildRing(GGTs) ->
	werkzeug:shuffle(GGTs),
	setNeighbors(GGTs, 0).

setNeighbors(GGTs, 0) ->
	LeftN = nth0(last(GGTs)), GGTs),
	RightN = nth0(1, GGTs),
	{GGT,_} = nth0(0, GGTs),
	GGT ! {setneighbors,LeftN,RightN},
	setNeighbors(GGTs, 1).

setNeighbors(GGTs, Pos) ->
	LeftN = nth0(Pos-1, GGTs),
	RightN = nth0(Pos rem length(GGTs), GGTs),
	{GGT,_} = nth0(Pos, GGTs),
	GGT ! {setneighbors,LeftN,RightN},
	case length(GGTs)-1 == Pos of
		true ->
			ok;
		false ->
			setNeighbors(GGTs, Pos+1)
	end.

log(Msg) ->
	werkzeug:logging(werkzeug:to_String(erlang:node())++".log", Msg++"\n").