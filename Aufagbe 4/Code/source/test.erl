-module (test).

-export ([test/2]).

test(Addr,Port) ->
	{ok, Socket} = gen_udp:open(Port, [binary, {active, false}, {reuseaddr, true}, {ip, Addr}, {multicast_ttl, 1}, inet, {multicast_loop, true}, {multicast_if, Addr},{add_membership, {Addr, {0, 0, 0, 0}}}]),
	io:format("~p~n",[inet:peername(Socket)]).