package station;


import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;

public class SlotManager{
	Integer[] slots = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25};
	ArrayList<Integer> workSlots = new ArrayList<Integer>(Arrays.asList(slots));
	ArrayList<Integer> workSlotsOld = workSlots;
	private int frameNum = 1;
	private int slot = 0;
	private boolean wsend = false;
	private boolean resr = false;
	
	public boolean transferSenden;
	
	private boolean send = false;
	
	public SlotManager() {
		// TODO Auto-generated constructor stub
	}
	
	
	public int getSlot(){
		slot = (int) workSlots.get(0);
		if(!resr && send){
			return -1;
		}else{
			return slot;
		}
	}
	
	public int getOldSlot(){
		Collections.shuffle(workSlotsOld);
		resr = true;
		return (int) workSlotsOld.get(0);
	}
	
	public synchronized void setReceivedSlot(int slot){	//Sequenzdiagramm 8
		workSlots.remove(new Integer(slot));
	}
	
	public void nextFrame(int frameNum){
		resr = !workSlots.contains(new Integer(slot));
		slot = 0;
		send = wsend;
		wsend = false;
		workSlotsOld = workSlots;
		workSlots = new ArrayList<Integer>(Arrays.asList(slots));
		Collections.shuffle(workSlots);
		this.frameNum = frameNum;
	}

	public void setKol(){
		wsend = true;
	}
	

	
}
