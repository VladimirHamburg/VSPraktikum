package accessor_two;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.DataOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.net.UnknownHostException;
import java.security.InvalidParameterException;
import java.text.SimpleDateFormat;
import java.util.Date;

public class ClassOneImpl extends ClassOneImplBase {
	private String name;
	private String host;
	private int port;
	
	ClassOneImpl(String[] splitData) {
		if (splitData.length != 3) {
			writeLog("accessor_two.ClassOneImplBase: Invalid raw object");
			throw new InvalidParameterException("Invalid raw object");
		}
		name = splitData[0];
		host = splitData[1];
		port = Integer.parseInt(splitData[2]);
		writeLog("accessor_two.ClassOneImplBase (\"" + name + "\")" );
	}
	
	@Override
	public double methodOne(String param1, double param2)  throws SomeException112 {
		String[] result = sendReceive(name + ":methodOne:" + param1 + ":" + param2).split(":");
		String type = result[0]; 
		String msg = result[1];
		if (type == "result") {
			Double returnValue = Double.parseDouble(msg);
			writeLog("accessor_two.ClassOneImpl.methodOne:" + name + ":" + param1 + ":" + param2 + " return:" + returnValue.toString());
			return Double.parseDouble(msg);
		}	
		writeLog("accessor_two.ClassOneImpl.methodOne.SomeException112:" +msg);
		throw new SomeException112(msg);
	}

	@Override
	public double methodTwo(String param1, double param2) throws SomeException112, SomeException304 {
		String[] result = sendReceive(name +":methodTwo:" + param1 + ":" + param2).split(":");
		String type = result[0]; 
		String msg = result[1];
		if (type == "result") {
			Double returnValue = Double.parseDouble(msg);
			writeLog("accessor_two.ClassOneImpl.methodOne:" + name + ":" + param1 + ":" + param2 + " return:" + returnValue.toString());
			return Double.parseDouble(msg);
		} else if ( type == SomeException112.class.getName()) {	
			writeLog("accessor_two.ClassOneImpl.methodTwo.SomeException112:" + msg);
			throw new SomeException112(msg);
		} else {	
			writeLog("accessor_two.ClassOneImpl.methodTwo.SomeException304:" + msg);
			throw new SomeException304(msg);
		}
	}

	private String sendReceive(String message){
		String result = "";
		try {
			// Open
			Socket socket = new Socket(host, port);
			BufferedReader inFromServer = new BufferedReader(new InputStreamReader(socket.getInputStream()));
			DataOutputStream outToServer = new DataOutputStream(socket.getOutputStream());
			
			// Send receive
			outToServer.writeBytes(message+"\n");
			result = inFromServer.readLine();
			outToServer.writeBytes("close\n");
			
			// Close
			socket.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return result;
	}
	
	private void writeLog(String message) {
	   	 SimpleDateFormat sdf = new SimpleDateFormat("[yy-MM-dd hh:mm:ss]");
	   	 System.out.println(sdf.format(new Date()) +  message);
	   	String hostName;
	   	 try {
			hostName = java.net.InetAddress.getLocalHost().getHostName();
		} catch (UnknownHostException e1) {
			hostName = "";
		}
	   	 System.out.println(hostName);
	   	try(PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter("accessor_two_" + hostName + ".log", true)))) {
	   	    out.println(sdf.format(new Date()) +  message);
	   	}catch (IOException e) {
	   	    //exception handling left as an exercise for the reader
	   	}
	   }
}
