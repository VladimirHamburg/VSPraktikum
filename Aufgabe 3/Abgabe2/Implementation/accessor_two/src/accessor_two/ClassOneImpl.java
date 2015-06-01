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

import accessor_two.werkzeug;

public class ClassOneImpl extends ClassOneImplBase {
	private String name;
	private String host;
	private int port;
	
	ClassOneImpl(String[] splitData) {
		name = splitData[0];
		host = splitData[1];
		port = Integer.parseInt(splitData[2]);
	}
	
	@Override
	public double methodOne(String param1, double param2)  throws SomeException112 {
		String[] result = sendReceive(name + ":methodOne:" + param1 + ":" + param2).split(":");
		String type = result[0]; 
		String msg = result[1];
		if (type.equals("result")) {
			Double returnValue = Double.parseDouble(msg);
			return Double.parseDouble(msg);
		}
		throw new SomeException112(msg);
	}

	@Override
	public double methodTwo(String param1, double param2) throws SomeException112, SomeException304 {
		String[] result = sendReceive(name +":methodTwo:" + param1 + ":" + param2).split(":");
		String type = result[0]; 
		String msg = result[1];
		if (type.equals("result")) {
			return Double.parseDouble(msg);
		} else if ( type == SomeException112.class.getName()) {	
			throw new SomeException112(msg);
		} else {	
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
	
	
}
