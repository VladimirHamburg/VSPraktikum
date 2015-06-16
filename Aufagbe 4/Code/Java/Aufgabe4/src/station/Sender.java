package station;

import java.io.IOException;
import java.net.DatagramPacket;
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
    private InetAddress group;
    private int port;

	
	private boolean keepRunning;
	
	public Sender(PacketBuffer pBuf, SlotManager slotMan, TimeManager timeMan, String netAddress, int port, String netInterfaceName) throws IOException {
		this.pBuf = pBuf;
		this.slotMan = slotMan;
		this.timeMan = timeMan;
        this.socket = new MulticastSocket(port);
        this.port = port;
		socket.setNetworkInterface(NetworkInterface.getByName(netInterfaceName));
		socket.setTimeToLive(TTL);
        group = InetAddress.getByName(netAddress);
		socket.joinGroup(group);
	}
	
	@Override
	public void run() {
		try {
			keepRunning = true;		
			// --- Init Phase ---
			// Skip the first broken frame
			Thread.sleep(timeMan.getDelayNextFrame());
			// Skip the first full frame to check out for free slots
			Thread.sleep(timeMan.getDelayNextFrame());
			// We need the slot number for the CURRENT frame
			int currentSlot = slotMan.getOldSlot();
			// We sleep until we reach our current slot + offset
			Thread.sleep(TimeManager.SLOT_TIME * currentSlot + TimeManager.SLOT_OFFSET_TIME);
			// Now we can send our first packet!
			while (keepRunning) {
	            Packet p = pBuf.pop();
	            p.setSlotNum((byte)slotMan.getSlot()); // This is the slot for the next frame
	            p.setTimestamp(timeMan.getTimestamp()); // Current time stamp
	            socket.send(new DatagramPacket(p.getRaw(), p.getRaw().length, group, port));
	            // Sleep till next frame
	            Thread.sleep(timeMan.getDelayNextFrame());
	            // Sleep till slot, do shit again
	            Thread.sleep(TimeManager.SLOT_TIME * currentSlot + TimeManager.SLOT_OFFSET_TIME);
			}
		} catch (InterruptedException | IOException ex) {
			ex.printStackTrace();
		}
	}
	
	public void shutDown() {
		
	}
	
	public void wakeOnNextFrame() {
		Thread.currentThread();
	}

}
