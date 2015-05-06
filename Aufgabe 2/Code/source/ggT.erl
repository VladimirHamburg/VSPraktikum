-module (ggT).
-export ([start/7]).

-define (LOG, '../log/').

start(NameserviceName,Coordinator,{PrGr,Team,IDggT,StarterID},WorkTime,Quota,TermTime,ID) ->
	Nameservice = global:whereis_name(NameserviceName),
	log(ID, t_s(ID) ++ "Startzeit: " ++ t_s(werkzeug:timeMilliSecond()) ++ " mit PID " ++ t_s(erlang:self())),
	%%Registriert sich an der Erlang-Node.
	erlang:register(ID, erlang:self()),
	%%Registriert sich beim Nameservice.
	%%Sequenzdiagramm: 3
	registerByNS(Nameservice,ID),
	log(ID, t_s(ID) ++ "beim Namensdienst und auf Node lokal registriert."),
	%%Meldet sich beim Koordinator
	CoordinatorContacts = askForCoord(Nameservice,Coordinator,ID),
	%%Sequenzdiagramm: 4
	registerByCoor(CoordinatorContacts,ID),
	log(ID, t_s(ID) ++ "beim Koordinator gemeldet."),
	%%Wartet auf die Setzung der Namchbarn
	{NBorsL,NBorsR} = waitForNBors(Nameservice,ID),
	{LeftN,RightN} = getNBorsContacts(Nameservice,{NBorsL,NBorsR},ID),
	log(ID, t_s(ID) ++ "Linker Nachbar " ++ t_s(NBorsL) ++ " gebunden."),
	log(ID, t_s(ID) ++ "Rechter Nachbar " ++ t_s(NBorsR) ++ " gebunden."),
	%%Wartet auf initialen Mi-Wert
	Mi = waitForMi(Nameservice,ID),
	log(ID, t_s(ID) ++ "Mi " ++ t_s(Mi) ++ " bekommen."),
	loop(Mi, ID, Nameservice, CoordinatorContacts, {LeftN,RightN}, {PrGr,Team,ID,StarterID}, WorkTime,TermTime,"LogFile",0,Quota,werkzeug:reset_timer(ID, trunc(TermTime/2), vote)).

%%Alle Methoden ab hier wurden im Entwurf vorgegebn.

%%%% loop()
%%Kommt es zum Timeout wird die Methode vote() aufgerufen. 
%%Der ggT-Prozess übergeht in den Vote-Modus.
loop(Mi, ID, Nameservice, Coordinator, NBors, AllIDData, WorkTime,TermTime,LogFile,2,Quota,Timer)  ->
	%%Startet über multicast ein Voting({From,{multicast,vote,meinname}}).
	%%Sequenzdiagramm: 9
	Nameservice ! {erlang:self(),{multicast,vote,ID}},
	log(ID, t_s(ID) ++ "Zeit abgelaufen! ABSTIMMUNG!"),
	vote(Mi, ID, Nameservice, Coordinator, NBors, AllIDData, WorkTime,TermTime,LogFile,0,Quota,Timer, 0);
%%Der ggT-Prozess erwartet {sendy,Y}, wobei Y der Mi-Wert von anderem Prozess ist. 
%%Erhält er diesen, so wird die Berechnung ausgeführt(calc(Y,Mi)). Entsprechend dem Ergebnis wird eine Nachricht an die Nachbarn gesendet ({sendy,Y}) und der Koordinator informiert({briefmi,{Clientname,CMi,CZeit}}).
loop(Mi, ID, Nameservice, Coordinator, NBors, AllIDData, WorkTime,TermTime,LogFile,VoteFlag,Quota,Timer) ->
	receive
		{setpm,MiNeu} ->
			%%Timeout zurücksetzen
			TimerNew = werkzeug:reset_timer(Timer, trunc(TermTime/2), vote),
			log(ID, t_s(ID) ++ "Mi wurde neu gesetzt: " ++ t_s(MiNeu)),
			loop(MiNeu, ID, Nameservice, Coordinator, NBors, AllIDData,WorkTime, TermTime,LogFile,0,Quota,TimerNew);
		%%Sequenzdiagramm: 8
		{sendy,Y} ->
			%%Timeout zurücksetzen
			TimerNew = werkzeug:reset_timer(Timer, trunc(TermTime/2), vote),
			MiNeu = calcNewMi(Y,Mi,Coordinator,NBors,ID,WorkTime),
			loop(MiNeu, ID, Nameservice, Coordinator, NBors, AllIDData,WorkTime, TermTime,LogFile,0,Quota,TimerNew);
		%%Sequenzdiagramm: 10
		{From,{vote,Initiator}} ->
			case VoteFlag of
				%%Erhält der ggT-Prozess eine {From,{vote,Initiator}} guckt er 
				%%nach ob die hälfte des Timeout-Zeit vergangen ist. Ist das der Fall, antwortet er mit {voteYes, Name}. Sonst nichts.
				3 ->
					From ! {voteYes,ID},
					loop(Mi, ID, Nameservice, Coordinator, NBors, AllIDData,WorkTime, TermTime,LogFile,VoteFlag,Quota,Timer);
				1 ->
					%%Sequenzdiagramm: 11
					From ! {voteYes,ID},
					loop(Mi, ID, Nameservice, Coordinator, NBors, AllIDData,WorkTime, TermTime,LogFile,VoteFlag,Quota,Timer);
				_ ->
					loop(Mi, ID, Nameservice, Coordinator, NBors, AllIDData,WorkTime, TermTime,LogFile,VoteFlag,Quota,Timer)
			end;
		{From,tellmi} ->
			From ! {mi,Mi},
			loop(Mi, ID, Nameservice, Coordinator, NBors, AllIDData,WorkTime, TermTime,LogFile,VoteFlag,Quota,Timer);
		{From,pingGGT} ->
			log(ID, "Ping received... sending pong!"),
			From ! {pongGGT, ID},
			loop(Mi, ID, Nameservice, Coordinator, NBors, AllIDData,WorkTime, TermTime,LogFile,VoteFlag,Quota,Timer);
		vote ->
			case VoteFlag of
				1 ->
					loop(Mi, ID, Nameservice, Coordinator, NBors, AllIDData,WorkTime, TermTime,LogFile,2,Quota,Timer);
				0 ->
					TimerNew = werkzeug:reset_timer(Timer, trunc(TermTime/2), vote),
					loop(Mi, ID, Nameservice, Coordinator, NBors, AllIDData,WorkTime, TermTime,LogFile,1,Quota,TimerNew)
			end;			
		kill ->
			kill(Nameservice,ID)
	end.

%%%% vote()
%%Wird die benötigte Quote erreicht, benachrichtigt 
%%den Koordinator({From,briefterm,{Clientname,CMi,CZeit}}).
vote(Mi, ID, Nameservice, Coordinator, NBors, AllIDData, WorkTime,TermTime,LogFile,VoteFlag,Quota,Timer, YesQuota) when Quota == YesQuota ->
	Coordinator ! {erlang:self(),briefterm,{ID,Mi,werkzeug:timeMilliSecond()}},
	log(ID, t_s(ID) ++ " ABSTIMMUNG ERFOLGREICH"),
	loop(Mi, ID, Nameservice, Coordinator, NBors, AllIDData, WorkTime,TermTime,LogFile,3,Quota,Timer);
vote(Mi, ID, Nameservice, Coordinator, NBors, AllIDData, WorkTime,TermTime,LogFile,VoteFlag,Quota,Timer, YesQuota) ->
	%%Wartet auf die Antworten({voteYes,Name}).
	receive
		{voteYes, CName} ->
			log(ID, "ABSTIMMUNG bei " ++ t_s(ID) ++ ":" ++ t_s(CName) ++ ": stimmt ab  mit >JA<! Quota bei " ++ t_s(YesQuota+1) ++ " UM:" ++ t_s(werkzeug:timeMilliSecond())),
			vote(Mi, ID, Nameservice, Coordinator, NBors, AllIDData, WorkTime,TermTime,LogFile,VoteFlag,Quota,Timer, YesQuota+1);
		{From,{vote,Initiator}} ->
			From ! {voteYes, ID},
			vote(Mi, ID, Nameservice, Coordinator, NBors, AllIDData, WorkTime,TermTime,LogFile,VoteFlag,Quota,Timer, YesQuota);
		kill ->
			kill(Nameservice,ID)
	end.
%%%% kill()
kill(Nameservice,ID) ->
	Nameservice ! {erlang:self(),{unbind,ID}},
	erlang:unregister(ID),
	log(ID, t_s(ID) ++ " hat sich beendet!"),
	erlang:exit(erlang:self(),normal).
%%HILFSMETHODEN%%

%%Der ggT-Prozess registriert sich von Namensdienst({From,{unbind,meindienst}}) und Erlang-Node(unregister(Name)) ab.
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
	log(ID, "Y erhalten: " ++ t_s(Y)),
	NewMi = calc(Y,Mi),
	%%Um die Berechnung zu simulieren wird nach 
	%%der Erhalt von sendy eine bestimmte Zeit abgewartet.
	timer:sleep(WorkTime),
	case NewMi of
		noop ->
			log(ID, "Mi wurde nicht geaendert: " ++ t_s(Mi)),
			Mi;
		_ ->
			log(ID, "Mi wurde berechnet: " ++ t_s(NewMi)),
			newMiSend(NewMi, Coordinator, NBors, ID),
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

log(ID, Message) ->
	[_|[NodeName]] = string:tokens(lists:concat([erlang:node()]), "@"),
	werkzeug:logging(erlang:list_to_atom(lists:concat([?LOG, "GGTP_",ID,"@",NodeName, '.log'])), Message++"\n").

t_s(ToS) ->
	werkzeug:to_String(ToS).