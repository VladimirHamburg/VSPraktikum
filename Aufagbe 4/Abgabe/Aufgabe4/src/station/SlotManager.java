package station;


import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.concurrent.CopyOnWriteArrayList;

public class SlotManager{
	Integer[] slots = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25};
	public ArrayList<Integer> workSlotsA = new ArrayList<Integer>();
	CopyOnWriteArrayList<Integer> workSlots = new CopyOnWriteArrayList<Integer>(Arrays.asList(slots));
	CopyOnWriteArrayList<Integer> workSlotsOld = workSlots;
	CopyOnWriteArrayList<Integer> workSlotsOld2 = workSlots;
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
		//System.out.println("ASK NEXT SLOT");
		//System.out.println(workSlotsA.toString());
		if(!resr && send){
			return -1;
		}else{
			return slot;
		}
	}
	
	public  synchronized int getOldSlot(){
		//System.out.println("ASK OLD SLOT : " + workSlotsOld.toString());
		resr = true;
		return (int) workSlotsOld.get(0);
	}
	
	public void setReceivedSlot(int slot){	//Sequenzdiagramm 8
		//System.out.println(" REMOVE " + slot);
		workSlots.remove(new Integer(slot));
	}
	
	public void nextFrame(int frameNum){
		resr = !workSlots.contains(new Integer(slot));
		slot = 0;
		send = wsend;
		wsend = false;
		workSlotsOld2 = workSlotsOld;
		workSlotsOld = workSlots;
		//workSlots = new ArrayList<Integer>(Arrays.asList(slots));
		workSlots = new CopyOnWriteArrayList<Integer>(Arrays.asList(slots));
		workSlotsA = new ArrayList<Integer>();
		Collections.shuffle(workSlots);
		Collections.shuffle(workSlotsOld);
		this.frameNum = frameNum;
		System.out.println("-------------NEXT FRAME----------------");
	}

	public void setKol(){
		wsend = true;
	}
	

	
}
