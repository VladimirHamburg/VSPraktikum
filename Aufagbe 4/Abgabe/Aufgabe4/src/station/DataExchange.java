package station;

import java.net.DatagramPacket;
import java.util.ArrayList;
import java.util.List;

public class DataExchange {
	private SlotManager slotMan;
	private TimeManager timeMan;
	private List<Packet> buffer;
	private Long timeIn;
	private int slot = 0;
	
	public DataExchange(SlotManager slotMan, TimeManager timeMan) {
		this.slotMan = slotMan;
		this.timeMan = timeMan;
		this.buffer = new ArrayList<Packet>();
	}
	
	public void storePacket(DatagramPacket packet){
		buffer.add(new Packet(packet.getData()));
		timeIn = timeMan.getTimestamp();
	}
	
	public void proceed(int frameN){
		if(buffer.size() == 1){
			Packet workPacket = buffer.get(0);
			//Sequenzdiagramm 9
			timeMan.setTime(workPacket.getStation(), workPacket.getTimestamp()+(timeMan.getTimestamp()-timeIn));
			//Sequenzdiagramm 8
			//System.out.println(workPacket.getSlotNum() + " in frame " + timeMan.getFrameNumUTC() + " in slot " + timeMan.getSlotNum(timeMan.getTimestamp()));
			slotMan.setReceivedSlot(workPacket.getSlotNum());
			slotMan.workSlotsA.add(new Integer(workPacket.getSlotNum()));
			slotMan.transferSenden = false;
			buffer = new ArrayList<>();
		}
		if(buffer.size() >= 2){//Sequenzdiagramm 13
			System.out.println("KOLLISION " + frameN);
			if(slotMan.transferSenden){
				System.out.println("STATION SENDED TOO");
				slot = 0;
			}
			slotMan.transferSenden = false;
			slotMan.setKol();
			for (int i = 0; i < buffer.size(); i++) {
				System.out.println(buffer.get(i));
			}
			buffer = new ArrayList<>();
			}
		buffer = new ArrayList<>();
	}
	
	
	
}
