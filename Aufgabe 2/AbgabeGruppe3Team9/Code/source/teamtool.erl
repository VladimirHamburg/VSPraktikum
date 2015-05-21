-module(teamtool).

% Exportierte Funktionen
-export([
			nl/0,
			toStr/1,
			nodeWOQuote/0,
			nodeWOQuote/1,
			getAddr/2,
			getNSRealAddr/1
			%timestamp/1
		]).




nl() -> io_lib:format("~n", []).

toStr(Obj) ->
	lists:flatten(io_lib:format("~w", [Obj]))
.

nodeWOQuote() ->
	nodeWOQuote(node())
.

nodeWOQuote(Node) ->
	lists:flatten(io_lib:format("~s", [Node]))
.

getAddr(NSAddr, Name) ->
	NSRealAddr = getNSRealAddr(NSAddr),
	NSRealAddr ! {self(), {lookup, Name}},
	receive
		{pin,{Name,Node}} ->
			Result = {Name, Node}
		;
		not_found ->
			Result = not_found
	end,
	Result
.

getNSRealAddr(NSAddr) ->
	{NSName, NSNode} = NSAddr,
	net_adm:ping(NSNode),
	case global:whereis_name(NSName) of
		'undefined' ->
			NSRealAddr = NSAddr
		;
		NSAddrFound ->
			NSRealAddr = NSAddrFound
	end,
	NSRealAddr
.

%timestamp({Mega, Secs, Micro}) ->
%	Mega*1000*1000*1000*1000 + Secs * 1000 * 1000 + Micro
%.
