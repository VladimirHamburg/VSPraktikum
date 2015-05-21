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
    private ConcurrentHashMap<String, String> db;
    private Socket socket;
    
    private BufferedReader inFromClient;
    private DataOutputStream outToClient;
	
    boolean serviceRequested = true;
    
    public NameServiceWorker(NameServiceServer server, int connectionID, ConcurrentHashMap<String, String> db, Socket socket) {
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
            	String[] splitData = rawData.split(":");
            	parseRequest(splitData);       	
            }
            
            socket.close();
            server.ConnectionClosed();
        } catch (IOException e) {
        	writeLog("connection lost!");
            server.ConnectionClosed();
        }
        writeLog("connection closed");
    }
	
	private void parseRequest(String[] splitData) throws IOException {
		if (splitData.length >= 1) {
			writeLog("Received bad request!");
			return;
		}
		
		String command = splitData[0];
		
		if (command == "rebind") {
			commandRebind(splitData);
		} else if (command == "resolve") {
			commandResolve(splitData);
		} else if (command == "close") {
			commandClose();
		} else {
			writeLog("Invalid command param: "+command);
		}
	}
	
	private void commandRebind(String[] splitData) {
		if (splitData.length != 3) {
			writeLog("Received bad request!");
		}
		
		String name = splitData[1];
		String id = splitData[2];
		
		db.put(name, id);
		writeLog("rebind Name:"+name+" ID:"+id);
	}
	
	private void commandResolve(String[] splitData) throws IOException {
		if (splitData.length != 2) {
			writeLog("Received bad request!");
		}
		
		String name = splitData[1];
		
		if (!db.contains(name)) {
			writeLog("resolve Name:"+name+" failed!");
			outToClient.writeBytes("null\n");
		}
		String id = db.get(name);
		writeLog("resolve Name:"+name+" ID:"+id);
		outToClient.writeBytes(id + "\n");
	}
	
	private void commandClose() {
		writeLog("Close...");
		serviceRequested = false;
	}
    
    private void writeLog(String message) {
    	 SimpleDateFormat sdf = new SimpleDateFormat("[yy-MM-dd hh:mm:ss "+connectionID+"] ");
    	 System.out.println(sdf.format(new Date()) +  message);
    }
}
