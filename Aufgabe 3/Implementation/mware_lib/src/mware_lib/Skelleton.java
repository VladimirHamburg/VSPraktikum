package mware_lib;

import java.io.*;
import java.net.Socket;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.concurrent.ConcurrentHashMap;

public class Skelleton extends Thread {

	private InvokationServer server;
    private int connectionID;
    private ConcurrentHashMap<String, Object> db;
    private Socket socket;
    
    private BufferedReader inFromClient;
    private DataOutputStream outToClient;
    
    boolean serviceRequested = true;
    
    public Skelleton(InvokationServer server, int connectionID, ConcurrentHashMap<String, Object> db, Socket socket) {
    	this.server = server;
        this.connectionID = connectionID;
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
		if (splitData.length < 2) {
			writeLog("Received bad request!");
			return;
		}

		String name = splitData[0];
		if (!db.contains(name)) {
			writeLog("Invalid name");
		}
		
		Object obj = db.get(name);
		if ( obj instanceof accessor_one.ClassOneImplBase ) {
			invokeAccessor_oneClassOneImplBase((accessor_one.ClassOneImplBase)obj, splitData);
		} else if ( obj instanceof accessor_one.ClassTwoImplBase ) {
			invokeAccessor_oneClassTwoImplBase((accessor_one.ClassTwoImplBase)obj, splitData);
		} else if ( obj instanceof accessor_two.ClassOneImplBase ) {
			invokeAccessor_twoClassOneImplBase((accessor_two.ClassOneImplBase)obj, splitData);
		}
	}
    
    //------------- INVOKES -------------

    public void invokeAccessor_oneClassOneImplBase(accessor_one.ClassOneImplBase obj, String[] splitData) throws IOException {    	
    	String methodName = splitData[1];
    	String param1 = splitData[2];
    	int param2 = Integer.parseInt(splitData[3]);
    	
    	if (methodName != "methodOne") {
	    	try {
	    		String result = obj.methodOne(param1, param2);
	    		outToClient.writeBytes("result:"+result+"\n");
	    	} catch (accessor_one.SomeException112 ex) {
	    		outToClient.writeBytes("SomeException112:"+ex.getMessage()+"\n"); 
	    	}
    	} else {
    		writeLog("unknown method name: " + methodName);
    	}
    }
    
    public void invokeAccessor_oneClassTwoImplBase(accessor_one.ClassTwoImplBase obj, String[] splitData) throws IOException {  	
    	String methodName = splitData[1];
    	double param1 = Double.parseDouble(splitData[2]);
    	
    	if (methodName == "methodOne") {
        	try {
        		Integer result = obj.methodOne(param1);
        		outToClient.writeBytes("result:"+result.toString()+"\n");
        	} catch (accessor_one.SomeException110 ex) {
        		outToClient.writeBytes("SomeException110:"+ex.getMessage()+"\n");
        	}
    	} else if (methodName == "methodTwo") {
        	try {
        		Double result = obj.methodTwo();
        		outToClient.writeBytes("result:"+result.toString()+"\n");
        	} catch (accessor_one.SomeException112 ex) {
        		outToClient.writeBytes("SomeException112:"+ex.getMessage()+"\n");
        	}
    	} else {
    		writeLog("unknown method name: " + methodName);
    	}
    }
    
    public void invokeAccessor_twoClassOneImplBase(accessor_two.ClassOneImplBase obj, String[] splitData) throws IOException {
    	String methodName = splitData[1];
    	String param1 = splitData[2];
    	double param2 = Double.parseDouble(splitData[3]);
    	
    	if (methodName == "methodOne") {
        	try {
        		Double result = obj.methodOne(param1, param2);
        		outToClient.writeBytes("result:"+result.toString()+"\n");
        	} catch (accessor_two.SomeException112 ex) {
        		outToClient.writeBytes("SomeException112:"+ex.getMessage()+"\n");
        	}
    	} else if (methodName == "methodTwo") {
        	try {
        		Double result = obj.methodTwo(param1, param2);
        		outToClient.writeBytes("result:"+result.toString()+"\n");
        	} catch (accessor_two.SomeException112 ex) {
        		outToClient.writeBytes("SomeException112:"+ex.getMessage()+"\n");
        	} catch (accessor_two.SomeException304 ex) {
        		outToClient.writeBytes("SomeException304:"+ex.getMessage()+"\n");
        	}
    	} else {
    		writeLog("unknown method name: " + methodName);
    	}
    }
    
    private void writeLog(String message) {
   	 SimpleDateFormat sdf = new SimpleDateFormat("[yy-MM-dd hh:mm:ss "+connectionID+"] ");
   	 System.out.println(sdf.format(new Date()) +  message);
    }
}
