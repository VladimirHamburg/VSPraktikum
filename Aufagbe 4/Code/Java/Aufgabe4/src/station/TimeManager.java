package station;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class TimeManager implements Runnable {
	private boolean work_flag = true;
	private int frameNum = 0;
	private int oldFrame = 0;
	private Long workStart;
	private List<Long> times;
	private Long startDeviation;
	private Long deviation;
	private Date ts;
	

	public TimeManager(Long startDeviation) {
		this.startDeviation = startDeviation;
		this.deviation = 0L;
		times = new ArrayList<>();
		ts = new Date();
	}
	
	@Override
	public void run() {
		ts = new Date();
		workStart = ts.getTime();
		while(work_flag){
			ts = new Date();
			calcFrameNum(ts.getTime());
			if(oldFrame == frameNum-1){
				oldFrame++;
				calcTime();
				times = new ArrayList<>();
			}
		}
		
	}
	
	public void setTime(String statTyp, Long time){
		if(statTyp.equals("A")) times.add(time);
	}
	
	public Long getDelayNextSlot(){
		ts = new Date();
		return  (((ts.getTime()+startDeviation + deviation)%1000L)%25L);
	}
	
	public int getFrameNum() {
		return frameNum;
	}
	
	public void stop() {
		work_flag = false;
	}
	
	public Long get() {
		ts = new Date();
		return ts.getTime() + startDeviation + deviation;
	}
	
	private void calcFrameNum(Long time){
		frameNum = (int) ((time - workStart)/1000L);
	}
	
	
	private void calcTime(){
		deviation = 0L;
	}
	
}
