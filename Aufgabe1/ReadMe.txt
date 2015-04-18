FÜR WINDOWS:
	1. Variante:
	createConfigs.cmd ausführen //Erstellt passende Configs mit den Rechnernamen
	compile.cmd ausführen. //Kompiliert alle .erl-Dateien.
	startAll.cmd ausführen. //Startet passende .beam-Dateien in der richtigen Reihenfolge.

	2.Variante:
	Kofigurationsdateien anpassen.
	Um die Konfigurationsdatein zu erstellen sind serverExample und clientExample 
	zu verwenden. Die Konfiguratinsdateien müssen
	client.cfg
	server.cfg
	heißen.
	Um das System richtig zu starten soll die Reihnfolge beachtet werden.

	Zuerst wird HBQ gestartet.(Kompieliren nicht vergessen!)
	Dafür wird ein neuer Erlang-Node mit folgenden Befehl aufgemacht:
	werl -name <NAME DES NODES> -setcookie <NAME DER COOKIE>
	In der erlang-Konsole wird Befehl:
	hbq:start()
	ausgeführt.

	Nun wird Server gestartet.(Kompieliren nicht vergessen!)
	Dafür wird ein neuer Erlang-Node mit folgenden Befehl aufgemacht:
	werl -name <NAME DES NODES> -setcookie <NAME DER COOKIE>
	In der erlang-Konsole wird Befehl:
	server:start()
	ausgeführt.

	Dannach werden Clients gestartet.(Kompieliren nicht vergessen!)
	Dafür wird ein neuer Erlang-Node mit folgenden Befehl aufgemacht:
	werl -name <NAME DES NODES> -setcookie <NAME DER COOKIE>
	In der erlang-Konsole wird Befehl:
	client:start()
	ausgeführt.




FÜR LINUX:
	Wie bei Windows(2. Variante). Die  werl-Aufruf muss durch erl ersetzt werden.



