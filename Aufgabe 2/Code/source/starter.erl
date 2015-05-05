-module (starter).
-export ([start/1]).

start(Nr) ->
	{Praktikumsgruppe,Teamnummer,Nameservicenode,Nameservicename,Koordinatorname} = readConfig(),
	net_adm:ping(Nameservicenode),
	Nameservice = global:whereis_name(Nameservicename),
	Coordinator = askForCoord(Nameservice, Koordinatorname),
	Coordinator ! {erlang:self(),getsteeringval},
	receive
		{steeringval,WorkTime,TermTime,Quota,GGTProzessnummer} ->
			startGGTs(Nameservicename,Koordinatorname,{Praktikumsgruppe,Teamnummer,0,Nr},WorkTime,Quota,TermTime,erlang:list_to_atom(lists:concat([Praktikumsgruppe,Teamnummer,0,Nr])), GGTProzessnummer)
	end.


readConfig() ->
	{ok, ConfigListe} = file:consult("ggt.cfg"),
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
	erlang:spawn(ggt, start, [NameserviceName,Coordinator,{PrGr,Team,ID,StarterID},WorkTime,Quota,TermTime,ID]),
	startGGTs(NameserviceName,Coordinator,{PrGr,Team,IDggT+1,StarterID},WorkTime,Quota,TermTime,erlang:list_to_atom(lists:concat([PrGr,Team,IDggT+1,StarterID])), GGTProzessnummer-1).