package station;

import java.net.DatagramPacket;
import java.util.ArrayList;
import java.util.List;

public class DataExchange {
	private SlotManager slotMan;
	private TimeManager timeMan;
	private List<DatagramPacket> buffer;
	
	public DataExchange(SlotManager slotMan, TimeManager timeMan) {
		this.slotMan = slotMan;
		this.timeMan = timeMan;
	}
	
	public void storePacket(DatagramPacket packet){
		buffer.add(packet);
	}
	
	public void proceed(int frameN){
		if(buffer.size() == 1){
			// TODO: Datenweiterleiten
		}else{
			buffer = new ArrayList<>();
		}
	}
}
