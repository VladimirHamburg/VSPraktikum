package station;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.InetAddress;
import java.net.MulticastSocket;
import java.net.NetworkInterface;
import java.net.UnknownHostException;
import java.sql.Time;

public class Receiver implements Runnable {
	private String ipAddress = "225.10.1.2";
	private String adapter = "lo";
	private int port = 15011;
	private byte[] buffer;
	private InetAddress real_address;
	private Boolean work_flag = true;
	private SlotManager slotMan;
	private TimeManager timeMan;
	

	public Receiver(String ipAddress, String adapter, int port, SlotManager slotMan, TimeManager timeMan) {
		this.ipAddress = ipAddress;
		this.adapter = adapter;
		this.port = port;
		this.slotMan = slotMan;
		this.timeMan = timeMan;
		buffer = new byte[34];
		try {
			real_address = InetAddress.getByName(this.ipAddress);
		} catch (UnknownHostException e) {
			// TODO Auto-generated catch block
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
				mSocket.receive(msgPacket);
				
				// TODO Daten weiterleitung
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
