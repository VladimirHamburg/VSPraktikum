package mware_lib;

import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.concurrent.ConcurrentHashMap;

public class ObjectBroker {
	
	boolean debug;
	private NameService ns;
	private InvokationServer imc;
	private ConcurrentHashMap<String, Object> db;
	
	public static ObjectBroker init(String serviceHost, int listenPort, boolean debug) throws UnknownHostException{	
		return new ObjectBroker(serviceHost, listenPort, debug); 
	}
	
	private ObjectBroker(String serviceHost, int listenPort, boolean debug) throws UnknownHostException {		
		this.debug = debug;
		this.db = new ConcurrentHashMap<String, Object>();
		this.imc = new InvokationServer(db);
		
		String imcHost = InetAddress.getLocalHost().getHostName();
		int imcPort = imc.getPort();
		
		this.ns = new NameServiceProxy(serviceHost, listenPort, imcHost, imcPort, db, debug);
		
		this.imc.start();
	}
	
	// Liefert den Namensdienst (Stellvetreterobjekt).
	public NameService getNameService(){
		return ns;
	}
	
	// Beendet die Benutzung der Middleware in dieser Anwendung.
    public void shutDown() {
    	
    }
}
