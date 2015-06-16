package station;

import java.io.IOException;
import java.net.InetAddress;
import java.net.MulticastSocket;
import java.net.NetworkInterface;
import java.nio.ByteBuffer;

public class Sender implements Runnable {

	public static final int TTL = 1;
	
	private PacketBuffer pBuf;
	private SlotManager slotMan;
	private TimeManager timeMan;
	
	private MulticastSocket socket;
	
	private boolean keepRunning;
	
	public Sender(PacketBuffer pBuf, SlotManager slotMan, TimeManager timeMan, String netAddress, int port, String netInterfaceName) throws IOException {
		this.pBuf = pBuf;
		this.slotMan = slotMan;
		this.timeMan = timeMan;
		this.socket = new MulticastSocket();
		socket.setNetworkInterface(NetworkInterface.getByName(netInterfaceName));
		socket.setTimeToLive(TTL);
		InetAddress group = InetAddress.getByName(netAddress);
		socket.joinGroup(group);
	}
	
	@Override
	public void run() {
		keepRunning = true;
		
		// --- Init Phase ---
		// Skip the first broken frame
		try {
			Thread.sleep(timeMan.getDelayNextFrame());

		// Skip the first full frame to check out for free slots
		Thread.sleep(timeMan.getDelayNextFrame());
		// We need the slot number for the CURRENT frame
		int currentSlot = slotMan.getOldSlot();
		// We sleep until we reach our current slot + offset
		Thread.sleep(timeMan.SLOT_TIME * currentSlot + timeMan.SLOT_OFFSET_TIME);
		// Now we can send our first packet!
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		while (keepRunning) {
			Packet p = pBuf.pop();
			
			
			p.setSlotNum(ByteBuffer.allocate(1).putInt(slotMan.getSlot()).get());
			p.setTimestamp(timeMan.getTimestamp());
			
			
		}
	}
	
	public void shutDown() {
		
	}
	
	public void wakeOnNextFrame() {
		Thread.currentThread();
	}

}
