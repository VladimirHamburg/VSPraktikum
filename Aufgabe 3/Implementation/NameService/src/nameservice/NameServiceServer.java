package nameservice;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.UnknownHostException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.concurrent.ConcurrentHashMap;

public class NameServiceServer extends Thread {

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
        ConcurrentHashMap<String, ConnectionData> db  = new ConcurrentHashMap<String, ConnectionData>();
        
        try {
            welcomeSocket = new ServerSocket(port);
            //System.out.println("NameServer: Waiting for connection - listening on TCP port " + port);
            writeLog("NameServer: Waiting for connection - listening on TCP port " + port);
            while (true) {           
                connectionSocket = welcomeSocket.accept();
                connectionSocket.setSoTimeout(SOCKET_TIMEOUT_MS);
                
                currentConnections++;
                if (currentConnections <= maxConnections) { 
                	(new NameServiceWorker(this, ++connectionID, db, connectionSocket)).start();
                } else {
                	//System.out.println("Too many connections! Last connection dropped!");
                	writeLog("Too many connections! Last connection dropped!");
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
	
	private static void writeLog(String message) {
	   	 SimpleDateFormat sdf = new SimpleDateFormat("[yy-MM-dd hh:mm:ss ]");
	   	 System.out.println(sdf.format(new Date()) +  message);
	   	String hostName;
	   	 try {
			hostName = java.net.InetAddress.getLocalHost().getHostName();
		} catch (UnknownHostException e1) {
			hostName = "";
		}
	   	try(PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter("nameservice_" + hostName + ".log", true)))) {
	   	    out.println(sdf.format(new Date()) +  message);
	   	}catch (IOException e) {
	   	    //exception handling left as an exercise for the reader
	   	}
	   }

}
