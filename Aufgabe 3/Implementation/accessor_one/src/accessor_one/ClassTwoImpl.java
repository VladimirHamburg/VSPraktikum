package accessor_one;

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

public class ClassTwoImpl extends ClassTwoImplBase {
	
	private String name;
	private String host;
	private int port;
	
	ClassTwoImpl(String[] splitData) {
		if (splitData.length != 3) {
			throw new InvalidParameterException("Invalid raw object");
		}
		name = splitData[0];
		host = splitData[1];
		port = Integer.parseInt(splitData[2]);
	}
	@Override
	public int methodOne(double param1) throws SomeException110 {
		String[] result = sendReceive(name + ":methodOne:"  + param1).split(":");
		String type = result[0]; 
		String msg = result[1];
		if (type == "result") {
			Integer returnValue = Integer.parseInt(msg);
			writeLog("accessor_one.ClassTwoImpl.methodOne:" + name + ":" + param1 + " return:" + returnValue.toString());
			return Integer.parseInt(msg);
		}
		writeLog("accessor_one.ClassTwoImpl.methodOne.SomeException110: " + msg); 
		throw new SomeException110(msg);
	}

	@Override
	public double methodTwo() throws SomeException112 {
		String[] result = sendReceive("methodTwo:" + name).split(":");
		String type = result[0]; 
		String msg = result[1];
		if (type == "result") {
			Double returnValue = Double.parseDouble(msg);
			writeLog("accessor_one.ClassTwoImpl.methodTwo:" + name +  " return:" + returnValue.toString());
			return Double.parseDouble(msg);
		}	
		writeLog("accessor_one.ClassTwoImpl.methodTwo.SomeException112: " + msg); 
		throw new SomeException112(msg);
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
	   	try(PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter("accessor_one_" + hostName + ".log", true)))) {
	   	    out.println(sdf.format(new Date()) +  message);
	   	}catch (IOException e) {
	   	    //exception handling left as an exercise for the reader
	   	}
	   }
}
