package nameservice;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.concurrent.ConcurrentHashMap;

public class NameServiceServer  extends Thread {

	private static final int SOCKET_TIMEOUT_MS = 10000;
	
    private int port;   
    private int maxConnections;
    
    private volatile int currentConnections; 
    
    private ServerSocket welcomeSocket;
    private Socket connectionSocket;
    
    public NameServiceServer(int port, int maxConnections) {
        this.port = port;
        this.maxConnections = maxConnections;
    }
	
	@Override
    public void run() {
        int connectionID = 0;
        ConcurrentHashMap<String, String> db  = new ConcurrentHashMap<String, String>();
        
        try {
            welcomeSocket = new ServerSocket(port);
            System.out.println("NameServer: Waiting for connection - listening on TCP port " + port);
            while (true) {           
                connectionSocket = welcomeSocket.accept();
                connectionSocket.setSoTimeout(SOCKET_TIMEOUT_MS);
                
                currentConnections++;
                if (currentConnections <= maxConnections) { 
                	(new NameServiceWorker(this, ++connectionID, db, connectionSocket)).start();
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

}
