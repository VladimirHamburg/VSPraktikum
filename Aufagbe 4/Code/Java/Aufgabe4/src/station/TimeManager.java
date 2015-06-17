package station;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class TimeManager {
	
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
	
	private final Long SENDING_TIME = 0L;
	
	

	public TimeManager(Long startDeviation) {
		this.startDeviation = startDeviation;
		this.deviation = 0L;
		times = new ArrayList<>();
		workStart = (new Date().getTime()/1000L)*1000L;
	}
	
//	@Override
//	public void run() {
//		workStart = (new Date().getTime()/1000L)*1000L;
//		while(work_flag){
//			calcFrameNum(new Date().getTime()+startDeviation + deviation);
//			if(oldFrame == frameNum-1){
//				oldFrame++;
//				calcTime();
//				times = new ArrayList<>();
//			}
//		}
//		
//	}
	
	public void setTime(char statTyp, Long time){
		if(statTyp == 'A'){ 
			Long ntime = (new Date().getTime()+startDeviation) - (time+SENDING_TIME+SLOT_OFFSET_TIME);
			times.add(ntime);
		}
	}
	
	public Long getDelayNextSlot(){
		Long workTime = (((new Date().getTime()+startDeviation + deviation)%FRIME_TIME)%SLOT_TIME);
		if(workTime == 0L) return 0L;
		return  SLOT_TIME-workTime;
	}
	
	public Long getDelayNextFrame(){
		Long workTime = (((new Date().getTime()+startDeviation + deviation)%FRIME_TIME));
		if(workTime == 0L) return 0L;
		return  FRIME_TIME-workTime;
	}
	
	public int getFrameNum() {
		calcFrameNum(new Date().getTime()+startDeviation + deviation);
		return frameNum;
	}
	
	public void stop() {
		work_flag = false;
	}
	
	public Long getTimestamp() {
		//System.out.println(startDeviation + " : " + deviation);
		//System.out.println(new Date().getTime());
		return new Date().getTime() + startDeviation + deviation;
	}
	

	private void calcFrameNum(Long time){
//		if((time - (workStart)%1000 == 0)){
//			return;
//		}
		frameNum = (int) ((time - (workStart))/1000L);
	}
	
	
	
	private void calcTime(){
		Long workDev = 0L;
		for (Long timeUnit : times) {
			workDev += timeUnit;
		}
		if(times.size() == 0) return;
		deviation = (workDev/times.size());
		//deviation = 0L;
		//System.out.println(deviation);
	}
	
	public void nextFrame(){
		calcTime();
		times = new ArrayList<>();
	}
	
	
}
