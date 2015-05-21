Das Projekt liegt im Ordner "Code".
Info: Die Ordnerstruktur von "bin", "log", und "source" muss beibehalten werden.

Vorbereiten:
1. Compilescript Ausführen: cAll.cmd ausführen. Dies erstellt alle beam Dateien.
2. Ins "bin" Verzeichnis wechseln.
3. ggt.cfg und koordinator.cfg das "nameservice" Feld entsprechend anpassen.

Starten:
4. Namensdienst Konsole starten ( werl -name ns -setcookie zummsel )
	4.1 Namensdienst starten ( nameservice:start() )

5. Koordinator Konsole starten ( werl -name chef -setcookie zummsel )
	5.1 Koordinator starten ( koordinator:start() ) 

6. KoordinatorSteuerung Konsole starten ( werl -name chefc -setcookie zummsel )
	6.1 KoordinatorSteuerung starten ( koordinatorSteuerung:start(X))
		Wobei X = der Name des KoordinatorNodes in einfachen Anführungzeichen (bsp: 'chef@Notebook.HAW.1X')

7. Starter Konsole starten ( werl -name starterX -setcookie zummsel )
	Wobei X = die fortlaufenden Nummer des Starters (z.B. 1)
	7.1 Starter starten (starter:start(X))
		Wobei X = die fortlaufenden Nummer des Starters (z.B. 1)

Verwendung:
9. In der Steuerungskonsole können nun die gewünschen Befehle eingegeben werden ohne Zusätzliche Zeichen.
	(z.B. step prompt kill nudge). Wird calc eingegeben, erscheint eine weitere Eingabe für den WunschGGT.
	Die Logs der GGTs befinden sich im "log" Verzeichnis.