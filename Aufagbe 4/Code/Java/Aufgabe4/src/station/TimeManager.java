package station;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class TimeManager implements Runnable {
	
	public static final long SLOT_TIME = 40L;
	public static final long SLOT_OFFSET_TIME = 20L;
	public static final long FRIME_TIME = 1000L;
	
	private boolean work_flag = true;
	private int frameNum = 0;
	private int oldFrame = 0;
	private Long workStart;
	private List<Long> times;
	private Long startDeviation;
	private Long deviation;
	
	private final Long SENDING_TIME = 1L;
	
	

	public TimeManager(Long startDeviation) {
		this.startDeviation = startDeviation;
		this.deviation = 0L;
		times = new ArrayList<>();
	}
	
	@Override
	public void run() {
		workStart = new Date().getTime();
		while(work_flag){
			calcFrameNum(new Date().getTime());
			if(oldFrame == frameNum-1){
				oldFrame++;
				calcTime();
				times = new ArrayList<>();
			}
		}
		
	}
	
	public void setTime(char statTyp, Long time){
		if(statTyp == "A".charAt(0)){ 
			Long ntime = (time+SENDING_TIME) - (new Date().getTime()+startDeviation);
			times.add(ntime);
		}
	}
	
	public Long getDelayNextSlot(){
		return  SLOT_TIME-(((new Date().getTime()+startDeviation + deviation)%FRIME_TIME)%SLOT_TIME);
	}
	
	public Long getDelayNextFrame(){
		return  FRIME_TIME-(((new Date().getTime()+startDeviation + deviation)%FRIME_TIME));
	}
	
	public int getFrameNum() {
		return frameNum;
	}
	
	public void stop() {
		work_flag = false;
	}
	
	public Long getTimestamp() {
		return new Date().getTime() + startDeviation + deviation;
	}
	

	private void calcFrameNum(Long time){
		frameNum = (int) ((time - workStart)/1000L);
	}
	
	
	
	private void calcTime(){
		Long workDev = 0L;
		for (Long timeUnit : times) {
			workDev += timeUnit;
		}
		if(times.size() == 0) return;
		deviation = workDev/times.size();
	}
	
}
