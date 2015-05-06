-module (starter).
-export ([start/1]).

-define (LOG, '../log/').

start(Nr) ->
	log(t_s(erlang:node()) ++ " Startzeit: " ++t_s(werkzeug:timeMilliSecond()) ++ " mit PID " ++ t_s(erlang:self())),
	{Praktikumsgruppe,Teamnummer,Nameservicenode,Nameservicename,Koordinatorname} = readConfig(),
	log("ggt.cfg gelesen..."),
	net_adm:ping(Nameservicenode),
	timer:sleep(1000),
	Nameservice = global:whereis_name(Nameservicename),
	log("Namensdiesnst " ++t_s(Nameservice)++ " gebunden..."),
	Coordinator = askForCoord(Nameservice, Koordinatorname),
	log("Koordinator " ++ t_s(Koordinatorname) ++ " gebunden..."),
	Coordinator ! {erlang:self(),getsteeringval},
	receive
		{steeringval,WorkTime,TermTime,Quota,GGTProzessnummer} ->
			log("Arbeitszeit: " ++ t_s(WorkTime) ++ " Terminierungszeit: " ++ t_s(TermTime) ++ " Quota: " ++ t_s(Quota) ++ " Anzahl: " ++ t_s(GGTProzessnummer)),
			startGGTs(Nameservicename,Koordinatorname,{Praktikumsgruppe,Teamnummer,0,Nr},WorkTime,Quota,TermTime,erlang:list_to_atom(lists:concat([Praktikumsgruppe,Teamnummer,0,Nr])), GGTProzessnummer)
	end.


readConfig() ->
	{ok, ConfigListe} = file:consult("ggt.cfg"),
	log("ggt.cfg geöffnet..."),
	{ok,Praktikumsgruppe} = werkzeug:get_config_value(praktikumsgruppe,ConfigListe),
	{ok,Teamnummer} = werkzeug:get_config_value(teamnummer,ConfigListe),
	{ok,Nameservicenode} = werkzeug:get_config_value(nameservicenode,ConfigListe),
	{ok,Nameservicename} = werkzeug:get_config_value(nameservicename,ConfigListe),
	{ok,Koordinatorname} = werkzeug:get_config_value(koordinatorname,ConfigListe),
	{Praktikumsgruppe,Teamnummer,Nameservicenode,Nameservicename,Koordinatorname}.

askForCoord(Nameservice,Coordinator) ->
	Nameservice ! {erlang:self() ,{lookup,Coordinator}},
	receive
		{pin,{Name,Node}} ->
			{Name,Node}
	end.

startGGTs(_,_,_,_,_,_,_,0) ->
	ok;
startGGTs(NameserviceName,Coordinator,{PrGr,Team,IDggT,StarterID},WorkTime,Quota,TermTime,ID, GGTProzessnummer) ->
	erlang:spawn(ggT, start, [NameserviceName,Coordinator,{PrGr,Team,ID,StarterID},WorkTime,Quota,TermTime,ID]),
	startGGTs(NameserviceName,Coordinator,{PrGr,Team,IDggT+1,StarterID},WorkTime,Quota,TermTime,erlang:list_to_atom(lists:concat([PrGr,Team,IDggT+1,StarterID])), GGTProzessnummer-1).

log(Message) ->
	werkzeug:logging(erlang:list_to_atom(lists:concat([?LOG, erlang:node(), '.log'])), Message++"\n").

t_s(ToS) ->
	werkzeug:to_String(ToS).