package nameservice;

import java.io.*;
import java.net.*;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.concurrent.ConcurrentHashMap;

import javax.print.attribute.standard.DateTimeAtCompleted;

public class NameServiceWorker extends Thread  {

	private NameServiceServer server;
    private int connectionID;
    private ConcurrentHashMap<String, ConnectionData> db;
    private Socket socket;
    
    private BufferedReader inFromClient;
    private DataOutputStream outToClient;
	
    boolean serviceRequested = true;
    
    public NameServiceWorker(NameServiceServer server, int connectionID, ConcurrentHashMap<String, ConnectionData> db, Socket socket) {
    	this.server = server;
        this.connectionID = connectionID;
        this.db = db;
        this.socket = socket;
    }
	
	@Override
    public void run() {
		writeLog("connetion opened");
        try {
            inFromClient = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            outToClient = new DataOutputStream(socket.getOutputStream());
            
            while (serviceRequested) {
            	String rawData  = inFromClient.readLine();
            	writeLog("RAW INCOMING: " + rawData);
            	String[] splitData = rawData.split(":");
            	parseRequest(splitData);       	
            }
            
            socket.close();
            writeLog("connection closed");
            server.ConnectionClosed();
        } catch (IOException e) {
        	writeLog("connection lost!");
            server.ConnectionClosed();
        }
        
    }
	
	private void parseRequest(String[] splitData) throws IOException {
		String command = splitData[0];
		
		if (command.equals("rebind")) {
			commandRebind(splitData);
		} else if (command.equals("resolve")) {
			commandResolve(splitData);
		} else if (command.equals("close")) {
			commandClose();
		} else {
			writeLog("Invalid command param: "+command);
		}
	}
	
	private void commandRebind(String[] splitData) {
		String host = splitData[1];
		String port = splitData[2];
		String name = splitData[3];
		
		db.put(name, new ConnectionData(host, port));
		writeLog("rebind Name:" + name + " @ " + host + ":" + port);
	}
	
	private void commandResolve(String[] splitData) throws IOException {
		String name = splitData[1];
		
		if (!db.containsKey(name)) {		
			writeLog("resolve Name:"+name+" failed!");
			outToClient.writeBytes("null\n");
			return;
		}
		
		ConnectionData entry = db.get(name);
		writeLog("resolve Name:" + name + " @ " + entry.Host + ":" + entry.Port);
		outToClient.writeBytes(name + ":" + entry.Host + ":" + entry.Port + "\n");
	}
	
	private void commandClose() {
		writeLog("Close...");
		serviceRequested = false;
	}
    
	private void writeLog(String message) {
	   	SimpleDateFormat sdf = new SimpleDateFormat("[yy-MM-dd hh:mm:ss ");
	   	String logEntry = sdf.format(new Date()) + connectionID + " ] " +  message;
	   	System.out.println(logEntry);
	   	String hostName;
	   	
	   	try {
			hostName = java.net.InetAddress.getLocalHost().getHostName();
		} catch (UnknownHostException e1) {
			hostName = "";
		}

	   	try(PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter("nameservice_" + hostName + ".log", true)))) {
	   	    out.println(logEntry);
	   	}catch (IOException e) {
	   	    //exception handling left as an exercise for the reader
	   	}
   }
}
