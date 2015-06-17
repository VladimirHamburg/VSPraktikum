package station;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

public class TimeManager {
	
	public static final long SLOT_TIME = 40L;
	public static final long SLOT_OFFSET_TIME = 20L;
	public static final long FRIME_TIME = 1000L;
	
	private boolean work_flag = true;
	private int frameNum = 0;
	private Long workStart;
	private List<Long> times;
	private Long startDeviation;
	private Long deviation;
	private char typ;
	
	private final Long SENDING_TIME = 0L;
	
	

	public TimeManager(Long startDeviation, char typ) {
		this.startDeviation = startDeviation;
		this.deviation = 1L;
		this.typ = typ;
		times = new ArrayList<>();
		workStart = (new Date().getTime()/1000L)*1000L;
	}
	



	
	public void setTime(char statTyp, Long time){ //Sequenzdiagramm 10
		if(statTyp == 'A'){ 
			Long ntime = ((time+SENDING_TIME) -(new Date().getTime()+startDeviation));
			times.add(ntime);
		}
	}
	
	public Long getDelayNextSlot(){
		Long workTime = (((new Date().getTime()+startDeviation + deviation)%FRIME_TIME)%SLOT_TIME);
		return  SLOT_TIME-workTime;
	}
	
	public Long getDelayNextFrame(){
		Long workTime = (((new Date().getTime()+startDeviation + deviation)%FRIME_TIME));
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
		return new Date().getTime() + startDeviation + deviation;
	}
	

	private void calcFrameNum(Long time){
		frameNum = (int) ((time - (workStart))/1000L);
	}
	
	public int getSlotNum(Long time){
		return ((int) (((time - (workStart))%1000L)/40L))+1;
		
	}
	
	public Long getDelaySinceFrameStart(){
		return (((new Date().getTime()+startDeviation + deviation)%FRIME_TIME));
	}
	
	
	private void calcTime(){
		Long workDev = 0L;
		if(times.size() == 1 && typ == 'A'){
			return; 
		}else if (times.size() == 0) {
			return;
		}else{
			for (Long timeUnit : times) {
				workDev += timeUnit;
			}
			deviation = deviation/2 + ((workDev/times.size()))/2;
		}		
	}
	
	public void nextFrame(){
		calcTime();
		times.clear();
	}
	
	
}
