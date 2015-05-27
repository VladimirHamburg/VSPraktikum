package mware_lib;

import java.io.*;
import java.net.Socket;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.concurrent.ConcurrentHashMap;

public class Skelleton extends Thread {

	private InvokationServer server;
    private int connectionID;
    private ConcurrentHashMap<String, Invokeable> db;
    private Socket socket;
    
    private BufferedReader inFromClient;
    private DataOutputStream outToClient;
    
    boolean serviceRequested = true;
    
    public Skelleton(InvokationServer server, int connectionID, ConcurrentHashMap<String, Invokeable> db, Socket socket) {
    	this.server = server;
        this.connectionID = connectionID;
        this.db = db;
        this.socket = socket;
    }
    
    @Override
    public void run() {
		writeLog("connection opened");
        try {
            inFromClient = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            outToClient = new DataOutputStream(socket.getOutputStream());
            
            while (serviceRequested) {
            	String rawData  = inFromClient.readLine();
            	writeLog("RAW INCOMING: " + rawData);
            	String[] splitData = rawData.split(":");
            	parseInvoke(splitData);    	
            }
            
            socket.close();
            writeLog("connection closed");
            server.ConnectionClosed();
        } catch (IOException e) {
        	writeLog("connection lost!");
            server.ConnectionClosed();
        }
    }
    
    private void parseInvoke(String[] splitData) throws IOException {
    	if (splitData[0].equals("close")) {
    		writeLog("Close...");
    		serviceRequested = false;
    		return;
    	}
    	
    	String name = splitData[0];
    	
		if (!db.containsKey(name)) {
			writeLog("Invalid name " + name + ". DB contains " + db.size() + " entries!");
			serviceRequested = false;
			return;
		}
		
		Invokeable obj = db.get(name);
		outToClient.writeBytes(obj.Invoke(splitData));
	}

    
    private void writeLog(String message) {
    	SimpleDateFormat sdf = new SimpleDateFormat("[yy-MM-dd hh:mm:ss ");
	   	String logEntry = sdf.format(new Date()) + connectionID + " ] " +  message;
	   	System.out.println(logEntry);
    }
}
