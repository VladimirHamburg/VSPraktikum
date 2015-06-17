package sniffer;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.InetAddress;
import java.net.MulticastSocket;
import java.net.NetworkInterface;
import java.net.UnknownHostException;
import station.Packet;

public class ReceiverSniff {

	public static void main(String[] args) {
		String ipAddress = "225.10.1.2";
		String adapter = "eth0";
		int port = 15009;
		byte[] buffer = new byte[34];
		InetAddress real_address = null;
		try {
			real_address = InetAddress.getByName(ipAddress);
		} catch (UnknownHostException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		MulticastSocket mSocket = null;
		try {
			mSocket = new MulticastSocket(port);
			mSocket.setNetworkInterface(NetworkInterface.getByName(adapter));
			
			mSocket.joinGroup(real_address);
			
			while (true) {
				DatagramPacket msgPacket = new DatagramPacket(buffer, buffer.length);
				mSocket.receive(msgPacket);
				System.out.println(new Packet(msgPacket.getData()).toString());
				
			}
			
		} catch (IOException ex) {
			ex.printStackTrace();
		}
		
		
	}

}
