-module (ggT).

start(Namensdienst,KoordName,NummerPgTm,VerzogZeit,TerminZeit,ID,StarterID) ->
	%%Registriert sich an der Erlang-Node.
	erlang:register(ID, erlang:self()),
	%%Registriert sich beim Namensdienst.
	

 ok.

%%Alle Methoden ab hier wurden im Entwurf vorgegebn.

%%%% loop()
%%%% vote()
%%%% kill()

%%HILFSMETHODEN%%

calc(OtherMi,SelfMI) when OtherMi >= SelfMI ->
	noop;
calc(OtherMi,SelfMI) ->
	((SelfMI-1) rem OtherMi) + 1.