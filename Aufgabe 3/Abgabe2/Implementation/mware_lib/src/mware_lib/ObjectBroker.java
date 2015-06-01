package mware_lib;

import java.io.DataOutputStream;
import java.io.IOException;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.UnknownHostException;
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;

public class ObjectBroker {
	
	private static final int SYS_MAX_PORT_NUMBER = 65536;
	private static final int SYS_MIN_PORT_NUMBER = 1;
	
	private static final int MIN_PORT = 40000;
	private static final int MAX_PORT = 65000;
	
	boolean debug;
	private NameService ns;
	private InvokationServer imc;
	private ConcurrentHashMap<String, Invokeable> db;
	
	public static ObjectBroker init(String serviceHost, int listenPort, boolean debug) throws UnknownHostException{	
		return new ObjectBroker(serviceHost, listenPort, debug); 
	}
	
	private ObjectBroker(String serviceHost, int listenPort, boolean debug) throws UnknownHostException {		
		this.debug = debug;
		this.db = new ConcurrentHashMap<String, Invokeable>();
		this.imc = new InvokationServer(db, debug);
		
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
    public void shutDown() throws UnknownHostException {
    	imc.stopWork();
    	String imcHost = InetAddress.getLocalHost().getHostName();
		int imcPort = imc.getPort();
		onlySend("close", imcHost, imcPort);
    }
    
    
	private void onlySend(String message, String serviceHost, int listenPort){
		try {
			// Open
			Socket socket = new Socket(serviceHost, listenPort);
			DataOutputStream outToServer = new DataOutputStream(socket.getOutputStream());
			
			// Send
			outToServer.writeBytes(message+"\n");
			outToServer.writeBytes("close\n");
			
			// Close
			socket.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
}
