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
    
    private int sended = 0;
    private int notSended = 0;

	
	private boolean keepRunning;
	private boolean noCollision;
	
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
			while(keepRunning) {
				// --- Init Phase ---
				// Skip the first broken frame
				Thread.sleep(timeMan.getDelayNextFrame()+5L);
				// Skip the first full frame to check out for free slots
				
				Thread.sleep(timeMan.getDelayNextFrame()+5L);
				// We need the slot number for the CURRENT frame
				notSended += 2;
				int currentSlot = slotMan.getOldSlot();
				// We sleep until we reach our current slot + offset
				Thread.sleep(TimeManager.SLOT_TIME * currentSlot - TimeManager.SLOT_OFFSET_TIME);
				noCollision = true;
				// Now we can send our first packet!
				while (noCollision) {
		            Packet p = pBuf.pop();//Sequenzdiagramm 2
		            currentSlot = slotMan.getSlot(); //Sequenzdiagramm 3
		            if(currentSlot == -1) 
		            {
		            	noCollision = false;
		            	System.out.println("RESTART!");
		            	continue;
		            }
		            p.setSlotNum((byte)currentSlot); // This is the slot for the next frame
		            p.setTimestamp(timeMan.getTimestamp()); // Current time stamp0 //Sequenzdiagramm 4
		            socket.send(new DatagramPacket(p.getRaw(), p.getRaw().length, group, port)); //Sequenzdiagramm 5
		            slotMan.transferSenden = true;
		            sended++;
		            System.out.println("SEND: " + sended + " NOT SEND" + notSended);
		            Thread.sleep(timeMan.getDelayNextFrame());
		            slotMan.transferSenden = false;
		            Thread.sleep((TimeManager.SLOT_TIME * currentSlot) - TimeManager.SLOT_OFFSET_TIME);
				}
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
