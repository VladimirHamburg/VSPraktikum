package mware_lib;

import java.io.IOException;
import java.net.*;
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;

public class InvokationServer extends Thread {
	
	private static final int SYS_MAX_PORT_NUMBER = 65536;
	private static final int SYS_MIN_PORT_NUMBER = 1;
	private static final int MIN_PORT = 40000;
	private static final int MAX_PORT = 65000;
	
	private static final int SOCKET_TIMEOUT_MS = 10000;
	private static final int MAX_CONNECTIONS = 100;
	
	private int port;   
	private ConcurrentHashMap<String, Invokeable> db;
    
    private volatile int currentConnections; 
    
    private ServerSocket welcomeSocket;
    private Socket connectionSocket;
   
    private boolean work = true;
    private boolean debug = false;
    
    public InvokationServer(ConcurrentHashMap<String, Invokeable> db, boolean debug) {
		port = getFreePort();
		this.db = db;
		this.debug = debug;
	}
	
	@Override
	public void run() {
		int connectionID = 0;      
        try {
            welcomeSocket = new ServerSocket(port);
            System.out.println("IMC: Waiting for connection - listening on TCP port " + port);
            while (work) {           
                connectionSocket = welcomeSocket.accept();
                connectionSocket.setSoTimeout(SOCKET_TIMEOUT_MS);
                
                currentConnections++;
                if (currentConnections <= MAX_CONNECTIONS) { 
                	(new Skelleton(this, ++connectionID, db, connectionSocket,debug)).start();
                } else {
                	System.out.println("Too many connections! Last connection dropped!");
                	connectionSocket.close();
                	ConnectionClosed();
                }
            }
        } catch (IOException e) {
            System.err.println(e.toString());
        }
	}
	
	/**
	 * Notifies the server thread that a client connection has been closed
	 */
	public void ConnectionClosed() {
		currentConnections--;
	}
	
	/**
	 * Tries to occupy a random port
	 * @return A port that is available
	 */
	private int getFreePort() {
		Random rand = new Random();
		
		int port;
		do {
			port = rand.nextInt(MAX_PORT - MIN_PORT) + MIN_PORT;
		} while(!available(port));
		
		return port;
	}

	/**
	 * Checks to see if a specific port is available.
	 * @param port the port to check for availability
	 */
	private boolean available(int port) {
	    if (port < SYS_MIN_PORT_NUMBER || port > SYS_MAX_PORT_NUMBER) {
	        throw new IllegalArgumentException("Invalid start port: " + port);
	    }

	    ServerSocket ss = null;
	    DatagramSocket ds = null;
	    try {
	        ss = new ServerSocket(port);
	        ss.setReuseAddress(true);
	        ds = new DatagramSocket(port);
	        ds.setReuseAddress(true);
	        return true;
	    } catch (IOException e) {
	    } finally {
	        if (ds != null) {
	            ds.close();
	        }

	        if (ss != null) {
	            try {
	                ss.close();
	            } catch (IOException e) {
	                /* should not be thrown */
	            }
	        }
	    }

	    return false;
	}
	
	public int getPort() {
		return port;
	}
	
	public void stopWork(){
		work = false;
	}
}
