-module (multicastSend).

-export ([send/3]).

send(Addr,Port,IAddr) ->
   Socket = werkzeug:openSeA(Addr,Port),
   gen_udp:controlling_process(Socket, self()),
   P = "Hello WORLD",
   gen_udp:send(Socket,IAddr,Port,P),
   gen_udp:close(Socket).