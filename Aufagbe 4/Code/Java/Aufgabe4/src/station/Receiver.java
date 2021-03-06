package station;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.InetAddress;
import java.net.MulticastSocket;
import java.net.NetworkInterface;
import java.net.UnknownHostException;
import java.sql.Time;

public class Receiver implements Runnable {
	private String ipAddress;
	private String adapter;
	private int port;
	private byte[] buffer;
	private InetAddress real_address;
	private Boolean work_flag = true;
	private DataExchange dataEx;
	

	public Receiver(String ipAddress, String adapter, int port, DataExchange dataEx) {
		this.ipAddress = ipAddress;
		this.adapter = adapter;
		this.port = port;
		this.dataEx = dataEx;
		buffer = new byte[34];
		try {
			real_address = InetAddress.getByName(this.ipAddress);
		} catch (UnknownHostException e) {
			e.printStackTrace();
		}
	}

	@Override
	public void run() {
		MulticastSocket mSocket = null;
		try {
			mSocket = new MulticastSocket(port);
			mSocket.setNetworkInterface(NetworkInterface.getByName(adapter));
			
			mSocket.joinGroup(real_address);
			
			while (work_flag) {
				DatagramPacket msgPacket = new DatagramPacket(buffer, buffer.length);
				mSocket.receive(msgPacket);//Sequenzdiagramm 6
				dataEx.storePacket(msgPacket);
				
			}
			
		} catch (IOException ex) {
			ex.printStackTrace();
		}
		
		if(mSocket != null) mSocket.close();
		
	}
	
	public void setWork_flag(Boolean work_flag) {
		this.work_flag = work_flag;
	}

}
