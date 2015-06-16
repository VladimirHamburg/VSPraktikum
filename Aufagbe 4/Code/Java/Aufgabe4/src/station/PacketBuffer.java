package station;

import java.io.*;
import java.util.Arrays;
import java.util.Iterator;
import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedQueue;

public class PacketBuffer implements Runnable {
	
	
	private char classType;
	private Queue<Packet> packetQ;
	
	public PacketBuffer(char classType) {
		this.classType = classType;
		this.packetQ = new ConcurrentLinkedQueue<Packet>();
	}


	@Override
	public void run() {
		int numBytes = 0;
		byte[] data = new byte[24];
		while (true) {
		    try {
				data[numBytes++] = (byte)System.in.read();
				if (numBytes == Packet.PAYLOAD_SIZE) {
					//System.out.println(new String(Arrays.copyOfRange(data, 0, 0 + 7), "UTF-8"));
					System.out.println(new Packet(classType, data));
					//
					numBytes = 0;
				}
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}		
	}
	
	public Packet Pop()
	{
		Packet p = packetQ.poll();
		if (p == null) {
			System.out.println("ERROR: packet queue is empty!");
		}
		return p;
	}
}
