package station;


import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;

public class SlotManager implements Runnable{
	private long seed = System.nanoTime();
	Integer[] slots = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25};
	ArrayList<Integer> workSlots = new ArrayList<Integer>(Arrays.asList(slots)); 
	private int frameNum = 0;
	private int slot = 1;
	private boolean init = true;
	private boolean resr = false;
	private TimeManager timeMan;
	
	
	
	public int oneRrandoSslot(){
		Collections.shuffle(workSlots);
		slot = (int) workSlots.get(0);
		return slot;
	}
	
	public void setSlot(int frameNum, int slot){
		if(this.frameNum+1 == frameNum){
			this.frameNum = frameNum;
			// TODO: wenn resr == false, dann Panik!!!!!!!!!!!!!
			resr = false; 
			workSlots = new ArrayList<Integer>(Arrays.asList(slots));
		}
		resr = resr||(this.slot == slot);
		workSlots.remove(new Integer(slot));
	}

	@Override
	public void run() {
		int startSlot = timeMan.getFrameNum();
		while(init){
			if(timeMan.getFrameNum() == startSlot+1){
				init = false;
			}
		}
		
		// TODO: Sender starten
		
	}
	
}
