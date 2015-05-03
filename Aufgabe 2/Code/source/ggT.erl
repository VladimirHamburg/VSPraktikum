-module (ggT).
-export ([start/7]).

start(Nameservice,Coordinator,NummerPgTm,DelayTime,TermTime,ID,StarterID) ->
	%%Registriert sich an der Erlang-Node.
	erlang:register(ID, erlang:self()),
	%%Registriert sich beim Nameservice.
	registerByNS(Nameservice,ID),
	%%Meldet sich beim Koordinator
	CoordinatorContacts = askForCoord(Nameservice,Coordinator),
	registerByCoor(CoordinatorContacts,ID),
	%%Wartet auf die Setzung der Namchbarn
	NBors = waitForNBors(),
	{LeftN,RightN} = getNBorsContacts(Nameservice,NBors),
	%%Wartet auf initialen Mi-Wert
	Mi = waitForMi().

%%Alle Methoden ab hier wurden im Entwurf vorgegebn.

%%%% loop()
%%%% vote()
%%%% kill()
kill() ->
	ok.
%%HILFSMETHODEN%%

askForCoord(Nameservice,Coordinator) ->
	Nameservice ! {erlang:self() ,{lookup,Coordinator}},
	receive
		{pin,{Name,Node}} ->
			{Name,Node};
		not_found ->
			kill();
		kill ->
			kill()
	end.

registerByNS(Nameservice,ID) ->
	Nameservice ! {erlang:self(), {rebind, ID, erlang:node()}},
	receive
		ok ->
			ok;
		kill ->
			kill()
	end.

waitForNBors() ->
	receive
		{setneighbors,LeftN,RightN} ->
			{LeftN,RightN};
		kill ->
			kill()
	end.

getNBorsContacts(Nameservice,{LeftN,RightN}) ->
{getNBorsContacts(Nameservice,LeftN),getNBorsContacts(Nameservice,RightN)};
getNBorsContacts(Nameservice, NBor) ->
	Nameservice ! {erlang:self() ,{lookup,NBor}},
	receive
		{pin,{Name,Node}} ->
			{Name,Node};
		not_found ->
			kill();
		kill ->
			kill()
	end.

waitForMi() ->
	receive
		{setpm,MiNeu} ->
			MiNeu;
		kill ->
			kill()
	end.

registerByCoor(CoordinatorContacts,ID) ->
	CoordinatorContacts ! {hello, ID}.

calc(OtherMi,SelfMI) when OtherMi >= SelfMI ->
	noop;
calc(OtherMi,SelfMI) ->
	((SelfMI-1) rem OtherMi) + 1.