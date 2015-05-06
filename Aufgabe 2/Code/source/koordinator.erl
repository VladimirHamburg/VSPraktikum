-module (koordinator).
-export ([start/0]).

start() ->
	log("Koordinator starting up..."),
	log("reading config ..."),
	KConfig = readConfig(),
	{_, _, _, NameServiceNode, _, KoordinatorName, _, _} = KConfig,
	log("register ..."),
	register(KoordinatorName, self()),
	log("ping DNS..."),
	pingDNS(NameServiceNode),
	log("ping ask for DNS..."),
	NameService = global:whereis_name(nameservice),
	log("ping ask register at DNS..."),
	Flag = registerByNS(NameService, KoordinatorName),
	case Flag of
		ok ->
			log("entering initialisation state..."),
			loopInitialize(KConfig, NameService, [], 1);
		false ->
			fail
	end.
	

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

loopInitialize(KConfig, NameService, GGTs, NumStarters) ->
	{ArbeitsZeit, TermZeit, GGTProzessNummer, _, _, _, Quote, _} = KConfig,
	receive 
		{Starter, getsteeringval} ->
				AbsQuota = trunc(Quote/100*GGTProzessNummer*NumStarters),
				log("Send config to starter with quota: " ++ werkzeug:to_String(AbsQuota)), 				
				Starter ! { steeringval, ArbeitsZeit, TermZeit, AbsQuota, GGTProzessNummer },
				loopInitialize(KConfig, NameService, GGTs, NumStarters+1);
		{hello, ClientName} ->
			log("Added new worker..."),
			loopInitialize(KConfig, NameService, GGTs ++ [{ClientName, 0, 0}], NumStarters);
		toggle ->
			log("toggle received..."),
			loopInitialize(toggleSet(KConfig), NameService, GGTs, NumStarters);
		step ->
			case length(GGTs) < 2 of
				true -> 
					log("step received. not enough workers. Command ignored."),
					loopInitialize(KConfig, NameService, GGTs, NumStarters);
				false ->
					log("step received. Initialisation ended. Building ring..."),
					buildRing(NameService, GGTs),
					log("Ring set up. Ready!"),
					DoRepeat = loopReady(KConfig, NameService, GGTs),
					case DoRepeat of 
						true ->
							loopInitialize(KConfig, NameService, [], NumStarters);
						false ->
							log("shutdown...")
					end
			end;
		kill ->
			sendKill(NameService, GGTs),
			log("kill received. bye!");
		_ ->
			log("unknown message. ignored."),
			loopInitialize(KConfig, NameService, GGTs, NumStarters)
	end.


loopReady(KConfig, NameService, GGTs) ->
	receive
		{briefmi,{ClientName,CMi,CZeit}} ->
			log("Received new MI from " ++ werkzeug:to_String(ClientName) ++ "new Mi: " ++ werkzeug:to_String(CMi)),
			GGTsNeu = updateGGT(GGTs, ClientName, CMi, CZeit),
			loopReady(KConfig, NameService, GGTsNeu);
		{From,briefterm,{ClientName,CMi,CZeit}} ->
			log("Worker " ++ werkzeug:to_String(ClientName) ++ " has finished with Mi: " ++ werkzeug:to_String(CMi)),
			GGTsNeu = updateGGT(GGTs, ClientName, CMi, CZeit),
			case getKorrigieren(KConfig) of
				0 ->
					log("Received final result: " ++ werkzeug:to_String(CMi));
				1 ->
					{_,FirstMi,_} = nth0(0, GGTs),
					SmalllestGGT = getSmallestGGT(GGTs, FirstMi),
					case CMi > SmalllestGGT of
						true -> 
							log("SENDY! Workers Mi was " ++ werkzeug:to_String(CMi) ++ " but smallest is" ++ werkzeug:to_String(SmalllestGGT)),
							From ! {sendy, SmalllestGGT};
						false ->
							log("Received final result: " ++ werkzeug:to_String(CMi))
					end
			end,
			loopReady(KConfig, NameService, GGTsNeu);
		reset ->
			log("Received kill command"),
			sendKill(NameService, GGTs),
			true;
		prompt ->
			log("Received prompt command"),
			getAllMis(NameService, GGTs),
			loopReady(KConfig, NameService, GGTs);
		nudge ->
			log("Received ping command"),
			pingGGTs(NameService, GGTs),
			loopReady(KConfig, NameService, GGTs);
		toggle ->
			log("Received toggle command"),
			loopReady(toggleSet(KConfig), NameService, GGTs);
		{calc,WggT} ->
			log("Start new calc with Wggt: " ++  werkzeug:to_String(WggT)),
			Mis = werkzeug:bestimme_mis(WggT, length(GGTs)),
			GGTsNeu = setAllMis(NameService, GGTs, Mis, []),
			dispatch20Percent(NameService, WggT, GGTsNeu),
			loopReady(KConfig, NameService, GGTsNeu);
		kill ->
			sendKill(NameService, GGTs),
			false;
		{pongGGT, GGTname} ->
			log("Received pong from " ++ werkzeug:to_String(GGTname)),
			loopReady(KConfig, NameService, GGTs);
		{mi,Mi} ->
			log("TellMi: Received Mi " ++ werkzeug:to_String(Mi)),
			loopReady(KConfig, NameService, GGTs);			
		_ ->
			log("unknown message. ignored."),
			loopReady(KConfig, NameService, GGTs)
	end.

%% Hilfsfunktionen die vom Entwurf nicht abgedeckt wurden

getKorrigieren({_, _, _, _, _, _, _, Korrigieren}) ->
	Korrigieren.



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
				1};
		1 ->
			{ArbeitsZeit, 
				TermZeit, 
				GGTProzessNummer, 
				NameServiceNode, 
				NameServiceName, 
				KoordinatorName, 
				Quote, 
				0}
	end.

buildRing(NameService, GGTs) ->
	log("shuffling GGTs..."),
	werkzeug:shuffle(GGTs),
	log("setting neighbors"),
	setNeighbors(NameService, GGTs, 0).

setNeighbors(NameService, GGTs, 0) ->
	{LeftN, _, _} = lists:last(GGTs), GGTs,
	{RightN, _, _} = nth0(1, GGTs),
	{GGT,_,_} = nth0(0, GGTs),
	sendToGGT(NameService, GGT, {setneighbors,LeftN,RightN}),
	setNeighbors(NameService, GGTs, 1);
setNeighbors(NameService, GGTs, Pos) ->
	{LeftN, _, _} = nth0(Pos-1, GGTs),
	{RightN, _, _} = nth0(Pos rem length(GGTs), GGTs),
	{GGT,_,_} = nth0(Pos, GGTs),
	sendToGGT(NameService, GGT, {setneighbors,LeftN,RightN}),
	case length(GGTs)-1 == Pos of
		true ->
			ok;
		false ->
			setNeighbors(NameService, GGTs, Pos+1)
	end.

updateGGT([],_,_,_) ->
	[];
updateGGT([GGT|Tail],GGTName, CMi, CZeit) ->
	case GGT == GGTName of
		true ->
			[{GGTName, CMi, CZeit}] ++ updateGGT(Tail, GGTName, CMi, CZeit);
		false ->
			[GGT] ++ updateGGT(Tail, GGTName, CMi, CZeit)
	end.

setAllMis(_, [], _, GGTsNeu) ->
	GGTsNeu;
setAllMis(NameService, [{GGT,_,_} |GGTsTail], [MiNeu|MisTail], GGTsNeu) ->
	GGTsNeuNeu = GGTsNeu ++ [{GGT, MiNeu, 0}],
	sendToGGT(NameService, GGT, {setpm, MiNeu}),
	setAllMis(NameService, GGTsTail, MisTail, GGTsNeuNeu).

dispatch20Percent(NameService, WggT, GGTs) ->
	werkzeug:shuffle(GGTs),	
	GGTCount = max(int_ceil(length(GGTs) * 0.2), 2),
	SelectedGGTs = lists:sublist(GGTs, 1, GGTCount),
	SelectedMis = werkzeug:bestimme_mis(WggT, length(SelectedGGTs)),
	dispatchGGT(NameService, SelectedGGTs, SelectedMis).

dispatchGGT(_, _,[]) ->
	ok;
dispatchGGT(NameService, [{GGT,_,_}|GGTsTail], [MiNeu|MisTail]) ->
	sendToGGT(NameService, GGT, {sendy, MiNeu}),
	dispatchGGT(NameService, GGTsTail, MisTail).

sendKill(_, []) ->
	ok;
sendKill(NameService, [{GGT,_,_}|Tail]) ->
	sendToGGT(NameService, GGT, kill),
	sendKill(NameService, Tail).

pingGGTs(_, []) ->
	ok;
pingGGTs(NameService, [{GGT,_,_}|Tail]) ->
	sendToGGT(NameService, GGT, {self(), pingGGT}),
	pingGGTs(NameService, Tail).

getAllMis(_, []) ->
	ok;
getAllMis(NameService, [{GGT,_,_}|Tail]) ->
	sendToGGT(NameService, GGT, {self(),tellmi}),
	getAllMis(NameService, Tail).

pingDNS(NameserviceNode) ->
	net_adm:ping(NameserviceNode),
	timer:sleep(1000).

registerByNS(NameService,ID) ->
	log(werkzeug:to_String(NameService)),
	NameService ! {self(), {rebind, ID, node()}},
	receive
		ok ->
			ok;
		_ ->
			false
	end.

getSmallestGGT([], Accu) ->
	Accu;
getSmallestGGT([{_,Value,_}|Tail],Accu) ->
	case Value < Accu of
		true ->
			getSmallestGGT(Tail, Value);
		false ->
			getSmallestGGT(Tail, Accu)
	end.

sendToGGT(NameService, GGT, Content) ->
	NameService ! {self(), {lookup, GGT}},
	receive 
        not_found -> log("Could not found GGT worker:" ++ werkzeug:to_String(GGT)); 
        {pin,{Name,Node}} ->
        	{Name,Node} ! Content,
        	log("Send to GGT " ++ werkzeug:to_String(GGT) ++ " content: " ++ werkzeug:to_String(Content))
	end.

int_ceil(X) ->
    T = trunc(X),
    case (X - T) of
        Neg when Neg < 0 -> T;
        Pos when Pos > 0 -> T + 1;
        _ -> T
    end.

nth0(Index, List) ->
	lists:nth(Index+1, List). 

log(Msg) ->
	werkzeug:logging(werkzeug:to_String(node())++".log", Msg++"\n").