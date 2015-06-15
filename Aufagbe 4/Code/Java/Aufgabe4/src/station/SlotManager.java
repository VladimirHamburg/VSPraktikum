package station;


import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;

public class SlotManager {
	private long seed = System.nanoTime();
	Integer[] slots = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25};
	ArrayList<Integer> workSlots = new ArrayList<Integer>(Arrays.asList(slots)); 
	
	
	private int one_random_slot(){
		Collections.shuffle(workSlots);
		return (int) workSlots.get(0);
	}
}
