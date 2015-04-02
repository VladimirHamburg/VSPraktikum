-module (cmem).
-export ([initCMEM/2,updateClient/4,getClientNNr/2,delExpiredCl/2]).

initCMEM(RemTime,Datei) ->
	{RemTime,[]}.

updateClient({RemTime,CLientList},ClientID,NNr,Datei) ->
	not_impl.

getClientNNr(CMEM,CLientID) ->
	not_impl.

delExpiredCl(CMEM,Clientlifetime) ->
	not_impl.