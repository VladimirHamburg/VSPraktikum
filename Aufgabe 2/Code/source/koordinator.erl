-module (koordinator).
-export ([start/0]).

start() ->
	log("Koordinator starting up..."),
	log("reading config ..."),
	KConfig = readConfig(),
	{_, _, _, _, _, KoordinatorName, _, _},
	register(KoordinatorName, self()),

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
			loopInitialize(KConfig, [] ++ [{ClientName, 0, 0}]);
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
			GGTsNeu = updateGGT(GGTs, ClientName, CMi, CZeit),
			loopReady(KConfig,GGTsNeu);	
		reset ->
			sendKill(GGTs),
			true;
		prompt ->
			getAllMis(GGTs),
			loopReady(KConfig,GGTs);
		nudge ->
			pingGGTs(GGTs)
			loopReady(KConfig,GGTs);
		toggle ->
			loopReady(toggleSet(KConfig), GGTs);
		{calc,WggT} ->
			Mis = werkzeug:bestimme_mis(WggT, length(GGTs)),
			setAllMis(GGTs, Mis),
			dispatch20Percent(WggT, GGTs, Mis),
			loopReady(KConfig,GGTs);
		kill ->
			sendKill(GGTs),
			false;
		{pongGGT, GGTname} ->
			log("Received pong from " ++ GGTname);
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

updateGGT([],_,_,_) ->
	[].
updateGGT([GGT|Tail],GGTName, CMi, CZeit) ->
	case GGT == GGTName of
		true ->
			[{GGTName, CMi, CZeit}] ++ updateGGT(Tail);
		false ->
			[GGT] ++ updateGGT(Tail);
	end.

setAllMis([], _) ->
	ok.
setAllMis([{GGT,_,_}|GGTsTail], [MiNeu|MisTail]) ->
	GGT ! {setpm, MiNeu},
	setAllMis(GGTsTail, MisTail).

dispatch20Percent(WggT, GGTs) ->
	werkzeug:shuffle(GGTs),	
	GGTCount = max(int_ceil(length(GGTs) * 0.2), 2),
	SelectedGGTs = lists:sublist(GGTs, 1, GGTCount),
	SelectedMis = werkzeug:bestimme_mis(WggT, length(SelectedGGTs))
	dispatchGGT(SelectedGGTs, SelectedMis).

dispatchGGT(_,[]) ->
	ok.
dispatchGGT([{GGT,_,_}|GGTsTail], [MiNeu|MisTail]) ->
	GGT ! {sendy, MiNeu},
	dispatchGGT(GGTsTail, MisTail).


setNeighbors(GGTs, 0) ->
	LeftN = nth0(last(GGTs)), GGTs),
	RightN = nth0(1, GGTs),
	{GGT,_,_} = nth0(0, GGTs),
	GGT ! {setneighbors,LeftN,RightN},
	setNeighbors(GGTs, 1).

setNeighbors(GGTs, Pos) ->
	LeftN = nth0(Pos-1, GGTs),
	RightN = nth0(Pos rem length(GGTs), GGTs),
	{GGT,_,_} = nth0(Pos, GGTs),
	GGT ! {setneighbors,LeftN,RightN},
	case length(GGTs)-1 == Pos of
		true ->
			ok;
		false ->
			setNeighbors(GGTs, Pos+1)
	end.

sendKill([]) ->
	ok.
sendKill([{GGT,_,_}|Tail]) ->
	GGT ! kill,
	sendKill(Tail).

pingGGTs([]) ->
	ok.
pingGGTs([{GGT,_,_}|Tail]) ->
	GGT ! {self(), pingGGT},
	pingGGTs(Tail).

getAllMis([]) ->
	ok.
getAllMis([{GGT,_,_}|Tail]) ->
	GGT ! {self(),tellmi},
	getAllMis(Tail).

registerByNS(Nameservice,ID) ->
	Nameservice ! {self(), {rebind, ID, node()}},
	receive
		ok ->
			ok;
		kill ->
			kill(Nameservice,ID)
	end.

int_ceil(X) ->
    T = trunc(X),
    case (X - T) of
        Neg when Neg < 0 -> T;
        Pos when Pos > 0 -> T + 1;
        _ -> T
    end.	

log(Msg) ->
	werkzeug:logging(werkzeug:to_String(node())++".log", Msg++"\n").