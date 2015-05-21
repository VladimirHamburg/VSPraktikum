package mware_lib;

public class ObjectBroker {
	
	private String serviceHost;
	private int listenPort;
	boolean debug;
	
	public ObjectBroker(String serviceHost, int listenPort, boolean debug) {
		this.serviceHost = serviceHost;
		this.listenPort = listenPort;
		this.debug = debug;
	}



	 // Das hier zurückgelieferte Objekt soll der zentrale Einstiegspunkt
	// der Middleware aus Applikationssicht sein.
	// Parameter: Host und Port, bei dem die Dienste (hier: Namensdienst)
	// kontaktiert werden sollen. Mit debug	sollen 	Test-
	// ausgaben der Middleware ein- oder ausgeschaltet 	werden
	// können. 
	public static ObjectBroker init(String serviceHost, int listenPort, boolean debug){
		return new ObjectBroker(serviceHost, listenPort, debug); 
	}
	
	// Liefert den Namensdienst (Stellvetreterobjekt).
	public NameService getNameService(){
		return new NameServiceProxy(serviceHost, listenPort, debug);
	}
	
	// Beendet die Benutzung der Middleware in dieser Anwendung.
    public void shutDown() {
    	
    }
}
