-module (cmem).
-export ([initCMEM/2,updateClient/4,getClientNNr/2,delExpiredCl/2]).

initCMEM(RemTime,_) ->
	{RemTime,[]}.

updateClient({RemTime,ClientList},ClientID,NNr,_) ->
	{RemTime,updateClient_(ClientList,ClientID,NNr)}.


getClientNNr({RemTime,ClientList},ClientID) ->
	WList=[{SavedID,NNr,TimeStamp} || {SavedID,NNr,TimeStamp} <- ClientList, SavedID == ClientID],
	getClientNNr_(WList,RemTime).

delExpiredCl({RemTime,ClientList},_) ->
	{RemTime,[{ClientID,NNr,TimeStamp} || {ClientID,NNr,TimeStamp} <- ClientList, checkTime(RemTime,TimeStamp)]}.

%%%%%%%%%%%%Hielfsmethoden, nicht in der Dokumentation beschrieben
updateClient_([],ClientID,NNr) ->
	[{ClientID,NNr,erlang:now()}];
updateClient_([{SavedID,_,_}|T],ClientID,NNr) when SavedID == ClientID ->
	[{SavedID,NNr,erlang:now()}] ++ T;
updateClient_([{SavedID,WNNr,TStamp}|T],ClientID,NNr) ->
	[{SavedID,WNNr,TStamp}] ++ updateClient_(T,ClientID,NNr).	
	
checkTime(RemTime,TimeStamp) ->
	(werkzeug:now2UTC(erlang:now()) - werkzeug:now2UTC(TimeStamp)) < RemTime*1000.

getClientNNr_([],_) ->
	1;
getClientNNr_([{_,WNNr,WorkStamp}|[]],RemTime) ->
	Flag = checkTime(RemTime,WorkStamp),
	case Flag of
		true ->
			WNNr+1;
		false ->
			1
	end;
getClientNNr_([_|_],_) ->
	error_gclnnr.