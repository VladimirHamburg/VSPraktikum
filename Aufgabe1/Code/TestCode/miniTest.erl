-module (miniTest).
-export ([print/1,read/0,sortin/2]).
print(Msg) ->
	io:fwrite("~p~n", [Msg]).

read() ->
	Msg = io:get_line("Prompt> "),
	print(Msg),
	read().

sortin([NNr,Msg],MsgList) ->
	[[WLNNr,WLMsg]|| [WLNNr,WLMsg] <- MsgList,WLNNr =< NNr] ++ [[NNr,Msg]] ++ [[WRNNr,WRMsg]|| [WRNNr,WRMsg] <- MsgList,WRNNr > NNr].
