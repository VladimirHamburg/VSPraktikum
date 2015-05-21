package mware_lib;

import java.io.BufferedWriter;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.net.Inet4Address;
import java.net.Socket;

public class NameServiceProxy extends NameService {
	
	private String serviceHost;
	private int listenPort;
	boolean debug; 
	int intID = 0;

	
	public NameServiceProxy(String serviceHost, int listenPort, boolean debug) {
		this.serviceHost = serviceHost;
		this.listenPort = listenPort;
		this.debug = debug;
	}

	@Override
	public void rebind(Object servant, String name) {
		String id = new Integer(intID).toString();
		intID++;
		id = id + servant.getClass().getName();
		onlySend("rebind:" + id + ":" + name);
		
	}

	@Override
	public Object resolve(String name) {
		return null;
	}
	
	private void onlySend(String message){
		try {
			Socket socket = new Socket(serviceHost, listenPort);
			BufferedWriter out = new BufferedWriter(new OutputStreamWriter(socket.getOutputStream()));
			out.write(message);
			out.newLine();
			out.flush();
			out.close();
			socket.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	private String send_recive(String message){
		return null;
	}
	
	public int myRandom(int low, int high) {
        return (int) (Math.random() * (high - low) + low);
    }

}
