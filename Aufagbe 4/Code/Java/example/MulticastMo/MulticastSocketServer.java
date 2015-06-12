// http://examples.javacodegeeks.com/core-java/net/multicastsocket-net/java-net-multicastsocket-example/

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.InetAddress;
import java.net.MulticastSocket;
import java.net.NetworkInterface;
import java.net.UnknownHostException;



public class MulticastSocketServer {
	final static String INET_ADDR = "225.10.1.2";
	final static String IF_NAME = "lo";
	final static int PORT = 15011;
	
	public static void main(String[] args) throws UnknownHostException, InterruptedException {
		// Get the address that we are going to connect to.
		InetAddress address = InetAddress.getByName(INET_ADDR);
		
		// Open a new DatagramSocket, which will be used to send the data.
		try {
			MulticastSocket mSocket = new MulticastSocket();
			mSocket.setTimeToLive(1);
			mSocket.setNetworkInterface(NetworkInterface.getByName(IF_NAME));
			
			for (int i = 0; i < 5; i++) {
				String msg = "Sent message no " + i;
				
				// Create a packet that will contain the data
				// (in the form of bytes) and send it.
				DatagramPacket msgPacket = new DatagramPacket(msg.getBytes(),
						msg.getBytes().length, address, PORT);
				mSocket.send(msgPacket);
				
				System.out.println("Server sent packet with msg: " + msg);
				Thread.sleep(500);
			}
		} catch (IOException ex) {
			ex.printStackTrace();
		}
	}
}
