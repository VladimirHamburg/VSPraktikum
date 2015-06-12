// http://examples.javacodegeeks.com/core-java/net/multicastsocket-net/java-net-multicastsocket-example/

/* Auf dem Loopback-Interface "lo" sollte die Firewall kein Problem sein.
 * Ansonsten koennen unter Linux mit "iptables" die Pakete durch die Firewall
 * gelassen werden.
 *
 * Regel aktivieren:
 *   iptables -I INPUT 1 -s 141.22.0.0/16 -d 225.10.1.2 -m pkttype --pkt-type multicast --protocol udp -j ACCEPT
 *
 * Regel wieder loeschen:
 *   iptables -D INPUT -s 141.22.0.0/16 -d 225.10.1.2 -m pkttype --pkt-type multicast --protocol udp -j ACCEPT
 * Achtung: Mehrmals aktivierte Regeln muessen auch mehrmals geloescht werden.
 */

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.InetAddress;
import java.net.MulticastSocket;
import java.net.NetworkInterface;
import java.net.UnknownHostException;



public class MulticastSocketClient {
	final static String INET_ADDR = "225.10.1.2";
	final static String IF_NAME = "lo";
	final static int PORT = 15011;
	
	public static void main(String[] args) throws UnknownHostException {
		// Get the address that we are going to connect to.
		InetAddress address = InetAddress.getByName(INET_ADDR);
		
		// Create a buffer of bytes, which will be used to store
		// the incoming bytes containing the information from the server.
		// Since the message is small here, 256 bytes should be enough.
		byte[] buf = new byte[256];
		
		// Create a new Multicast socket (that will allow other sockets/programs
		// to join it as well.
		try {
			MulticastSocket mSocket = new MulticastSocket(PORT);
			mSocket.setNetworkInterface(NetworkInterface.getByName(IF_NAME));
			
			//Joint the Multicast group.
			mSocket.joinGroup(address);
			
			while (true) {
				// Receive the information and print it.
				DatagramPacket msgPacket = new DatagramPacket(buf, buf.length);
				mSocket.receive(msgPacket);
				
				String msg = new String(buf, 0, buf.length);
				System.out.println("Socket 1 received msg: " + msg);
			}
		} catch (IOException ex) {
			ex.printStackTrace();
		}
	}
}
