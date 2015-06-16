package station;

import java.net.DatagramPacket;
import java.util.ArrayList;
import java.util.List;

public class DataExchange {
	private SlotManager slotMan;
	private TimeManager timeMan;
	private List<Packet> buffer;
	
	public DataExchange(SlotManager slotMan, TimeManager timeMan) {
		this.slotMan = slotMan;
		this.timeMan = timeMan;
	}
	
	public void storePacket(DatagramPacket packet){
		buffer.add(new Packet(packet.getData()));
	}
	
	public void proceed(int frameN){
		if(buffer.size() == 1&& frameN != 1){
			Packet workPacket = buffer.get(0);
			System.out.println(workPacket.getPayload());
			timeMan.setTime(workPacket.getStation(), workPacket.getTimestamp());
			slotMan.setReceivedSlot(timeMan.getFrameNum(), workPacket.getSlotNum());
		}else{
			buffer = new ArrayList<>();
		}
	}
}
