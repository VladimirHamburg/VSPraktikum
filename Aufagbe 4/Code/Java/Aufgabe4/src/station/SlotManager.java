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
	private boolean resr = false;
	
	public SlotManager() {
		// TODO Auto-generated constructor stub
	}
	
	
	public int getSlot(){
		Collections.shuffle(workSlots);
		slot = (int) workSlots.get(0);
		if(!resr) return -1;
		return slot;
	}
	
	public int getOldSlot(){
		Collections.shuffle(workSlotsOld);
		resr = true;
		return (int) workSlotsOld.get(0);
	}
	
	public void setReceivedSlot(int frameNum, int slot){
		System.out.println(frameNum - this.frameNum);
		if(this.frameNum+1 == frameNum){
			this.frameNum = frameNum;
			resr = false; 
			workSlotsOld = workSlots;
			workSlots = new ArrayList<Integer>(Arrays.asList(slots));
		}
		if(this.slot == slot) resr = true;		
		workSlots.remove(new Integer(slot));
	}

	
}
