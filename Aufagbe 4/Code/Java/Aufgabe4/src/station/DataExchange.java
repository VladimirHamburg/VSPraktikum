package station;

import java.net.DatagramPacket;
import java.util.ArrayList;
import java.util.List;

public class DataExchange {
	private SlotManager slotMan;
	private TimeManager timeMan;
	private List<Packet> buffer;
	private Long timeIn;
	
	public DataExchange(SlotManager slotMan, TimeManager timeMan) {
		this.slotMan = slotMan;
		this.timeMan = timeMan;
		this.buffer = new ArrayList<Packet>();
	}
	
	public void storePacket(DatagramPacket packet){
		//System.out.println(timeMan.getFrameNum() + " INSERT!");
		//System.out.println(new Packet(packet.getData()).toString());
		buffer.add(new Packet(packet.getData()));
		timeIn = timeMan.getTimestamp();
	}
	
	public void proceed(int frameN){
		//if(timeMan.getTimestamp()%1000L == 0) frameN--;
		if(buffer.size() == 1){
			//System.out.println(frameN + " bei " + timeMan.getTimestamp());
			Packet workPacket = buffer.get(0);
			//System.out.println(workPacket.toString());
			timeMan.setTime(workPacket.getStation(), workPacket.getTimestamp()+(timeMan.getTimestamp()-timeIn));
			slotMan.setReceivedSlot(workPacket.getSlotNum());
			
		}
		if(buffer.size() >= 2){
			System.out.println("KOLLISION " + frameN);
			for (int i = 0; i < buffer.size(); i++) {
				System.out.println(buffer.get(i));
			}
			}
		buffer = new ArrayList<>();
	}
}
