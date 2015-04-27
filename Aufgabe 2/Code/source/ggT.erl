-module (ggT).

start(Namensdienst,KoordName,NummerPgTm,VerzogZeit,TerminZeit,ID,StarterID) ->
 ok.

%%HILFSMETHODEN%%

calc(OtherMi,SelfMI) when OtherMi >= SelfMI ->
	noop;
calc(OtherMi,SelfMI) ->
	((SelfMI-1) rem OtherMi) + 1.