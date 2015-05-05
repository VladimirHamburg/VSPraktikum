-module (ggT).
-export ([start/7]).

start(NameserviceName,Coordinator,{PrGr,Team,IDggT,StarterID},WorkTime,Quota,TermTime,ID) ->
	Nameservice = global:whereis_name(NameserviceName),
	%%Registriert sich an der Erlang-Node.
	erlang:register(ID, erlang:self()),
	%%Registriert sich beim Nameservice.
	registerByNS(Nameservice,ID),
	%%Meldet sich beim Koordinator
	CoordinatorContacts = askForCoord(Nameservice,Coordinator,ID),
	registerByCoor(CoordinatorContacts,ID),
	%%Wartet auf die Setzung der Namchbarn
	NBors = waitForNBors(Nameservice,ID),
	{LeftN,RightN} = getNBorsContacts(Nameservice,NBors,ID),
	%%Wartet auf initialen Mi-Wert
	Mi = waitForMi(Nameservice,ID),
	loop(Mi, ID, Nameservice, CoordinatorContacts, {LeftN,RightN}, {PrGr,Team,ID,StarterID}, WorkTime,TermTime,"LogFile",0,Quota,werkzeug:reset_timer(ID, TermTime/2, vote)).

%%Alle Methoden ab hier wurden im Entwurf vorgegebn.

%%%% loop()
loop(Mi, ID, Nameservice, Coordinator, _, AllIDData, _,_,LogFile,VoteFlag,Quota,_) when VoteFlag == 2 ->
	vote(Mi, ID, Nameservice, Coordinator, AllIDData, LogFile, Quota, 0);
loop(Mi, ID, Nameservice, Coordinator, NBors, AllIDData, WorkTime,TermTime,LogFile,VoteFlag,Quota,Timer) ->
	receive
		{setpm,MiNeu} ->
			werkzeug:reset_timer(Timer, TermTime/2, vote),
			loop(MiNeu, ID, Nameservice, Coordinator, NBors, AllIDData,WorkTime, TermTime,LogFile,0,Quota,Timer);
		{sendy,Y} ->
			werkzeug:reset_timer(Timer, TermTime/2, vote),
			MiNeu = calcNewMi(Y,Mi,Coordinator,NBors,ID,WorkTime),
			loop(MiNeu, ID, Nameservice, Coordinator, NBors, AllIDData,WorkTime, TermTime,LogFile,0,Quota,Timer);
		{From,{vote,Initiator}} ->
			case VoteFlag of
				1 ->
					From ! {voteYes,ID},
					loop(Mi, ID, Nameservice, Coordinator, NBors, AllIDData,WorkTime, TermTime,LogFile,VoteFlag,Quota,Timer);
				_ ->
					loop(Mi, ID, Nameservice, Coordinator, NBors, AllIDData,WorkTime, TermTime,LogFile,VoteFlag,Quota,Timer)
			end;
		{From,tellmi} ->
			From ! {mi,Mi},
			loop(Mi, ID, Nameservice, Coordinator, NBors, AllIDData,WorkTime, TermTime,LogFile,VoteFlag,Quota,Timer);
		{From,pingGGT} ->
			From ! {pongGGT, ID},
			loop(Mi, ID, Nameservice, Coordinator, NBors, AllIDData,WorkTime, TermTime,LogFile,VoteFlag,Quota,Timer);
		vote ->
			werkzeug:reset_timer(Timer, TermTime/2, vote),
			loop(Mi, ID, Nameservice, Coordinator, NBors, AllIDData,WorkTime, TermTime,LogFile,VoteFlag+1,Quota,Timer);
		kill ->
			kill(Nameservice,ID)
	end.

%%%% vote()
vote(Mi, ID, Nameservice, Coordinator, AllIDData, LogFile, Quota, YesQuota) when Quota == YesQuota ->
	Coordinator ! {erlang:self(),briefterm,{ID,Mi,werkzeug:timeMilliSecond()}},
	receive
		kill ->
			kill(Nameservice,ID)
	end;
vote(Mi, ID, Nameservice, Coordinator, AllIDData, LogFile, Quota, YesQuota) ->
	Nameservice ! {erlang:self(),{multicast,vote,ID}},
	receive
		{voteYes, CName} ->
			vote(Mi, ID, Nameservice, Coordinator, AllIDData, LogFile, Quota, YesQuota+1);
		kill ->
			kill(Nameservice,ID)
	end.
%%%% kill()
kill(Nameservice,ID) ->
	Nameservice ! {erlang:self(),{unbind,ID}},
	erlang:unregister(ID),
	erlang:exit(erlang:self(),normal).
%%HILFSMETHODEN%%

askForCoord(Nameservice,Coordinator,ID) ->
	Nameservice ! {erlang:self() ,{lookup,Coordinator}},
	receive
		{pin,{Name,Node}} ->
			{Name,Node};
		not_found ->
			kill(Nameservice,ID);
		kill ->
			kill(Nameservice,ID)
	end.

registerByNS(Nameservice,ID) ->
	Nameservice ! {erlang:self(), {rebind, ID, erlang:node()}},
	receive
		ok ->
			ok;
		kill ->
			kill(Nameservice,ID)
	end.

waitForNBors(Nameservice,ID) ->
	receive
		{setneighbors,LeftN,RightN} ->
			{LeftN,RightN};
		kill ->
			kill(Nameservice,ID)
	end.

getNBorsContacts(Nameservice,{LeftN,RightN},ID) ->
{getNBorsContacts(Nameservice,LeftN,ID),getNBorsContacts(Nameservice,RightN,ID)};
getNBorsContacts(Nameservice, NBor,ID) ->
	Nameservice ! {erlang:self() ,{lookup,NBor}},
	receive
		{pin,{Name,Node}} ->
			{Name,Node};
		not_found ->
			kill(Nameservice,ID);
		kill ->
			kill(Nameservice,ID)
	end.

waitForMi(Nameservice,ID) ->
	receive
		{setpm,MiNeu} ->
			MiNeu;
		kill ->
			kill(Nameservice,ID)
	end.

registerByCoor(CoordinatorContacts,ID) ->
	CoordinatorContacts ! {hello, ID}.

calcNewMi(Y,Mi,Coordinator,NBors,ID,WorkTime) ->
	NewMi = calc(Y,Mi),
	time:sleep(WorkTime),
	case NewMi of
		nope ->
				Mi;
		_ ->
			newMiSend(Mi, Coordinator, NBors, ID),
			NewMi
	end.

newMiSend(Mi, Coordinator, {LeftN,RightN},ID) ->
	Coordinator ! {briefmi,{ID,Mi,werkzeug:timeMilliSecond()}},
	LeftN ! {sendy, Mi},
	RightN ! {sendy, Mi}.

calc(OtherMi,SelfMI) when OtherMi >= SelfMI ->
	noop;
calc(OtherMi,SelfMI) ->
	((SelfMI-1) rem OtherMi) + 1.