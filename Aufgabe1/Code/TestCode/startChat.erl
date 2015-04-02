-module (startChat).
-export ([start/1]).
-import (chatSen, [startS/1]).
-import (chatRec, [startR/0]).

start(Node) ->
	spawn(chatRec,startR,[]),
	spawn(chatSen,startS,[Node]).