package mware_lib;

import java.io.*;
import java.net.Inet4Address;
import java.net.InetAddress;
import java.net.Socket;
import java.net.UnknownHostException;
import java.util.concurrent.ConcurrentHashMap;

public class NameServiceProxy extends NameService {
	
	private String serviceHost;
	private int listenPort;
	private String imcHost;
	private int imcPort;
	private ConcurrentHashMap<String, Object> db;
	boolean debug; 
	
	int intID = 0;
	
	public NameServiceProxy(String serviceHost, int listenPort, String imcHost, int imcPort, ConcurrentHashMap<String, Object> db, boolean debug) {
		this.serviceHost = serviceHost;
		this.listenPort = listenPort;
		this.imcHost = imcHost;
		this.imcPort = imcPort;
		this.db = db;
		this.debug = debug;
	}

	@Override
	public void rebind(Object servant, String name) {
		onlySend("rebind:"+ imcHost +":" + imcPort + ":" + name);
		db.put(name, servant);
	}
	
	@Override
	public Object resolve(String name) {
		return sendReceive("resolve:"+name).split(":");
	}
	
	private void onlySend(String message){
		try {
			// Open
			Socket socket = new Socket(serviceHost, listenPort);
			DataOutputStream outToServer = new DataOutputStream(socket.getOutputStream());
			
			// Send
			outToServer.writeBytes(message+"\n");
			outToServer.writeBytes("close\n");
			
			// Close
			socket.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	private String sendReceive(String message){
		String result = "";
		try {
			// Open
			Socket socket = new Socket(serviceHost, listenPort);
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
